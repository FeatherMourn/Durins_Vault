#include <DynamicOutput/Output.hpp>
#include <Mod/CppUserModBase.hpp>
#include <Unreal/UObjectGlobals.hpp>
#include <Unreal/UObject.hpp>
#include <Unreal/UFunction.hpp>
#include <Unreal/FProperty.hpp>
#include <Unreal/FWeakObjectPtr.hpp>

#include <cstring>
#include <chrono>
#include <filesystem>
#include <fstream>
#include <iomanip>
#include <sstream>
#include <vector>

namespace DurinsVault
{
    using namespace RC;
    using namespace Unreal;

    class DurinsVaultInspector final : public CppUserModBase
    {
        struct Vec3
        {
            float x{};
            float y{};
            float z{};
        };

        struct TraceOffsets
        {
            int worldContext{-1};
            int start{-1};
            int end{-1};
            int traceChannel{-1};
            int traceComplex{-1};
            int actorsToIgnore{-1};
            int drawDebugType{-1};
            int outHit{-1};
            int ignoreSelf{-1};
            int returnValue{-1};
            int parameterSize{};
        };

        struct DeprojectOffsets
        {
            int screenX{-1};
            int screenY{-1};
            int worldLocation{-1};
            int worldDirection{-1};
            int returnValue{-1};
            int parameterSize{};
        };

        TraceOffsets m_trace{};
        DeprojectOffsets m_deproject{};

        static auto jsonAscii(std::wstring_view value) -> std::string
        {
            std::string result;
            result.reserve(value.size());
            for (wchar_t character : value)
            {
                switch (character)
                {
                case L'\\': result += "\\\\"; break;
                case L'"': result += "\\\""; break;
                case L'\n': result += "\\n"; break;
                case L'\r': result += "\\r"; break;
                case L'\t': result += "\\t"; break;
                default: result += character >= 0x20 && character < 0x7f ? static_cast<char>(character) : '?'; break;
                }
            }
            return result;
        }

        static auto utcTimestamp() -> std::string
        {
            const auto now = std::chrono::system_clock::now();
            const auto time = std::chrono::system_clock::to_time_t(now);
            std::tm utc{};
            gmtime_s(&utc, &time);
            std::ostringstream stream;
            stream << std::put_time(&utc, "%Y-%m-%dT%H:%M:%SZ");
            return stream.str();
        }

        static auto writeInspectionRecord(RC::Unreal::UObject* actor, RC::Unreal::UObject* component) -> void
        {
            if (!actor || !actor->GetClassPrivate()) return;
            std::filesystem::create_directories("Mods/DurinsVaultInspector");
            std::ofstream output("Mods/DurinsVaultInspector/inspection.jsonl", std::ios::app);
            if (!output) return;
            output << "{\"timestamp\":\"" << utcTimestamp()
                   << "\",\"actor_full_name\":\"" << jsonAscii(actor->GetFullName())
                   << "\",\"class_full_name\":\"" << jsonAscii(actor->GetClassPrivate()->GetName()) << "\"";
            if (component && component->GetClassPrivate())
                output << ",\"component_full_name\":\"" << jsonAscii(component->GetFullName())
                       << "\",\"component_class_full_name\":\""
                       << jsonAscii(component->GetClassPrivate()->GetName()) << "\"";
            output << ",\"properties\":[";
            bool firstProperty = true;
            for (auto* property : actor->GetClassPrivate()->ForEachProperty())
            {
                if (!firstProperty) output << ',';
                firstProperty = false;
                output << "{\"name\":\"" << jsonAscii(property->GetName())
                       << "\",\"offset\":" << property->GetOffset_Internal() << "}";
            }
            output << ']';
            output << "}\n";
        }

        static auto findPropertyOffset(RC::Unreal::UFunction* function, const wchar_t* name) -> int
        {
            for (auto* property : function->ForEachProperty())
            {
                if (property->GetName() == std::wstring_view(name))
                    return property->GetOffset_Internal();
            }
            return -1;
        }

        auto inspectTarget() -> void
        {
            using namespace RC::Unreal;

            std::vector<UObject*> controllers;
            UObjectGlobals::FindAllOf(STR("PlayerController"), controllers);
            if (controllers.empty() || !controllers.front())
            {
                Output::send<LogLevel::Warning>(STR("[DurinsVaultInspector] No PlayerController found.\n"));
                return;
            }
            auto* controller = controllers.front();

            auto* deproject = controller->GetFunctionByNameInChain(
                STR("DeprojectScreenPositionToWorld"));
            auto* traceFunction = UObjectGlobals::StaticFindObject<UFunction*>(
                nullptr, nullptr, STR("/Script/Engine.KismetSystemLibrary:LineTraceSingle"));
            auto* traceLibrary = UObjectGlobals::StaticFindObject<UObject*>(
                nullptr, nullptr, STR("/Script/Engine.Default__KismetSystemLibrary"));
            if (!deproject || !traceFunction || !traceLibrary)
            {
                Output::send<LogLevel::Error>(STR("[DurinsVaultInspector] Trace functions are unavailable.\n"));
                return;
            }

            m_deproject.parameterSize = deproject->GetParmsSize();
            m_deproject.screenX = findPropertyOffset(deproject, L"ScreenX");
            m_deproject.screenY = findPropertyOffset(deproject, L"ScreenY");
            m_deproject.worldLocation = findPropertyOffset(deproject, L"WorldLocation");
            m_deproject.worldDirection = findPropertyOffset(deproject, L"WorldDirection");
            m_deproject.returnValue = findPropertyOffset(deproject, L"ReturnValue");

            std::vector<uint8_t> deprojectParameters(m_deproject.parameterSize);
            float screenX = 960.0f;
            float screenY = 540.0f;
            std::memcpy(deprojectParameters.data() + m_deproject.screenX, &screenX, sizeof(float));
            std::memcpy(deprojectParameters.data() + m_deproject.screenY, &screenY, sizeof(float));
            controller->ProcessEvent(deproject, deprojectParameters.data());

            Vec3 origin{};
            Vec3 direction{};
            std::memcpy(&origin, deprojectParameters.data() + m_deproject.worldLocation, sizeof(Vec3));
            std::memcpy(&direction, deprojectParameters.data() + m_deproject.worldDirection, sizeof(Vec3));

            m_trace.parameterSize = traceFunction->GetParmsSize();
            m_trace.worldContext = findPropertyOffset(traceFunction, L"WorldContextObject");
            m_trace.start = findPropertyOffset(traceFunction, L"Start");
            m_trace.end = findPropertyOffset(traceFunction, L"End");
            m_trace.traceChannel = findPropertyOffset(traceFunction, L"TraceChannel");
            m_trace.traceComplex = findPropertyOffset(traceFunction, L"bTraceComplex");
            m_trace.actorsToIgnore = findPropertyOffset(traceFunction, L"ActorsToIgnore");
            m_trace.drawDebugType = findPropertyOffset(traceFunction, L"DrawDebugType");
            m_trace.outHit = findPropertyOffset(traceFunction, L"OutHit");
            m_trace.ignoreSelf = findPropertyOffset(traceFunction, L"bIgnoreSelf");
            m_trace.returnValue = findPropertyOffset(traceFunction, L"ReturnValue");

            std::vector<uint8_t> traceParameters(m_trace.parameterSize);
            Vec3 end{origin.x + direction.x * 5000.0f,
                     origin.y + direction.y * 5000.0f,
                     origin.z + direction.z * 5000.0f};
            std::memcpy(traceParameters.data() + m_trace.worldContext, &controller, sizeof(controller));
            std::memcpy(traceParameters.data() + m_trace.start, &origin, sizeof(Vec3));
            std::memcpy(traceParameters.data() + m_trace.end, &end, sizeof(Vec3));
            traceParameters[m_trace.traceChannel] = 0;
            traceParameters[m_trace.traceComplex] = 1;
            traceParameters[m_trace.drawDebugType] = 0;
            traceParameters[m_trace.ignoreSelf] = 1;
            traceLibrary->ProcessEvent(traceFunction, traceParameters.data());

            if (traceParameters[m_trace.returnValue] == 0)
            {
                Output::send<LogLevel::Normal>(STR("[DurinsVaultInspector] F3 trace found no hit.\n"));
                return;
            }

            // UE4.27 FHitResult places PhysMaterial at 0x60, Actor at 0x68,
            // and Component at 0x70 within the 0x88-byte result.
            auto* hitActor = reinterpret_cast<const FWeakObjectPtr*>(traceParameters.data() + m_trace.outHit + 0x68)->Get();
            auto* hitComponent = reinterpret_cast<const FWeakObjectPtr*>(traceParameters.data() + m_trace.outHit + 0x70)->Get();
            if (hitActor)
            {
                Output::send<LogLevel::Normal>(STR("[DurinsVaultInspector] F3 hit actor: {} | class: {}\n"),
                    hitActor->GetFullName(), hitActor->GetClassPrivate()->GetName());
            }
            if (hitComponent)
            {
                Output::send<LogLevel::Normal>(STR("[DurinsVaultInspector] F3 hit component: {} | class: {}\n"),
                    hitComponent->GetFullName(), hitComponent->GetClassPrivate()->GetName());
            }
            writeInspectionRecord(hitActor, hitComponent);
        }

    public:
        DurinsVaultInspector()
        {
            ModVersion = STR("0.1.0");
            ModName = STR("DurinsVaultInspector");
            ModAuthors = STR("Durin's Vault");
            ModDescription = STR("Runtime diagnostics for Return to Moria construction objects");

            Output::send<LogLevel::Normal>(
                STR("[DurinsVaultInspector] Loaded. Awaiting construction inspection implementation.\n"));
        }

        ~DurinsVaultInspector() override = default;

        auto on_unreal_init() -> void override
        {
            auto objectClass = UObjectGlobals::StaticFindObject<UObject*>(
                nullptr, nullptr, STR("/Script/CoreUObject.Object"));

            if (objectClass)
            {
                Output::send<LogLevel::Normal>(
                    STR("[DurinsVaultInspector] Unreal reflection initialized: {}\n"),
                    objectClass->GetFullName());
            }
            else
            {
                Output::send<LogLevel::Error>(
                    STR("[DurinsVaultInspector] Reflection initialization check failed.\n"));
            }

            register_keydown_event(Input::Key::F3, [this]() { inspectTarget(); });
            Output::send<LogLevel::Normal>(STR("[DurinsVaultInspector] F3 target inspection registered.\n"));
        }
    };
}

#define MOD_EXPORT __declspec(dllexport)
extern "C"
{
    MOD_EXPORT RC::CppUserModBase* start_mod()
    {
        return new DurinsVault::DurinsVaultInspector();
    }

    MOD_EXPORT void uninstall_mod(RC::CppUserModBase* mod)
    {
        delete mod;
    }
}
