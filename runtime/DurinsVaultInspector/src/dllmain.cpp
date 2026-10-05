#include <DynamicOutput/Output.hpp>
#include <Mod/CppUserModBase.hpp>
#include <Unreal/UObjectGlobals.hpp>
#include <Unreal/UObject.hpp>

namespace DurinsVault
{
    using namespace RC;
    using namespace Unreal;

    class DurinsVaultInspector final : public CppUserModBase
    {
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
