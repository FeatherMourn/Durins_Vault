#include "Modules/ModuleManager.h"
#include "Engine/Blueprint.h"
#include "Engine/SimpleConstructionScript.h"
#include "Engine/SCS_Node.h"
#include "Components/StaticMeshComponent.h"
#include "EditorAssetLibrary.h"
#include "Kismet2/BlueprintEditorUtils.h"
#include "Kismet2/KismetEditorUtilities.h"
#include "HAL/IConsoleManager.h"
#include "Misc/CoreDelegates.h"
#include "Containers/Ticker.h"

class FDurinsVaultEditorModule final : public IModuleInterface
{
public:
    virtual void StartupModule() override
    {
        Command = MakeUnique<FAutoConsoleCommand>(TEXT("DurinsVault.AssignCrudeWall"), TEXT("Assign the imported crude wall mesh."), FConsoleCommandDelegate::CreateRaw(this, &FDurinsVaultEditorModule::AssignCrudeWall));
        UE_LOG(LogTemp, Display, TEXT("DurinsVault: Editor module loaded."));
        InitHandle = FTicker::GetCoreTicker().AddTicker(FTickerDelegate::CreateRaw(this, &FDurinsVaultEditorModule::RunInitialAssignment), 3.0f);
    }
    virtual void ShutdownModule() override { FTicker::GetCoreTicker().RemoveTicker(InitHandle); Command.Reset(); }

private:
    bool RunInitialAssignment(float)
    {
        AssignCrudeWall();
        return false;
    }

    void AssignCrudeWall()
    {
        const FString BlueprintPath = TEXT("/Game/Durins_Vault/Building/Blueprints/BP_Crude_Wall_Variant");
        const FString MeshPath = TEXT("/Game/Durins_Vault/Building/Meshes/Source/Crude_Wall_3x1");
        UBlueprint* Blueprint = Cast<UBlueprint>(UEditorAssetLibrary::LoadAsset(BlueprintPath));
        UStaticMesh* Mesh = Cast<UStaticMesh>(UEditorAssetLibrary::LoadAsset(MeshPath));
        if (!Blueprint || !Mesh || !Blueprint->SimpleConstructionScript)
        {
            UE_LOG(LogTemp, Error, TEXT("DurinsVault: Blueprint, mesh, or construction script unavailable."));
            return;
        }
        bool bAssigned = false;
        UStaticMeshComponent* FallbackComponent = nullptr;
        for (USCS_Node* Node : Blueprint->SimpleConstructionScript->GetAllNodes())
        {
            UStaticMeshComponent* Component = Node && Node->ComponentTemplate ? Cast<UStaticMeshComponent>(Node->ComponentTemplate) : nullptr;
            if (Component && !FallbackComponent) FallbackComponent = Component;
            if (Component && Node->GetVariableName() == TEXT("ConstructionMesh"))
            {
                FallbackComponent = Component;
                break;
            }
        }
        if (FallbackComponent)
        {
            FallbackComponent->Modify();
            FallbackComponent->SetStaticMesh(Mesh);
            bAssigned = true;
        }
        if (!bAssigned)
        {
            UE_LOG(LogTemp, Error, TEXT("DurinsVault: ConstructionMesh node not found."));
            return;
        }
        FBlueprintEditorUtils::MarkBlueprintAsStructurallyModified(Blueprint);
        FKismetEditorUtilities::CompileBlueprint(Blueprint);
        UEditorAssetLibrary::SaveAsset(BlueprintPath, false);
        UE_LOG(LogTemp, Display, TEXT("DurinsVault: Assigned Crude_Wall_3x1 and saved Blueprint."));
    }
    TUniquePtr<FAutoConsoleCommand> Command;
    FDelegateHandle InitHandle;
};

IMPLEMENT_MODULE(FDurinsVaultEditorModule, DurinsVaultEditor)
