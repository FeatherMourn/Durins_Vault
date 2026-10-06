using UnrealBuildTool;

public class DurinsVaultEditor : ModuleRules
{
    public DurinsVaultEditor(ReadOnlyTargetRules Target) : base(Target)
    {
        PrivateDependencyModuleNames.AddRange(new string[] { "Core", "CoreUObject", "Engine", "UnrealEd", "EditorScriptingUtilities", "Slate", "SlateCore" });
    }
}
