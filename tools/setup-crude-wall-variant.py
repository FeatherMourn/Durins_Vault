"""UE4.27 editor script for the Durin's Vault prototype shell.

Run this from Unreal Editor after enabling the Python Editor Script Plugin.
It only changes the separate authoring project and never touches the game.
"""
import unreal

BLUEPRINT_PATH = "/Game/Durins_Vault/Building/Blueprints/BP_Crude_Wall_Variant"

blueprint = unreal.EditorAssetLibrary.load_asset(BLUEPRINT_PATH)
if not blueprint:
    raise RuntimeError("Blueprint not found: " + BLUEPRINT_PATH)

library = getattr(unreal, "BlueprintEditorLibrary", None)
add_component = getattr(library, "add_component", None) if library else None
if not add_component:
    unreal.log_warning("UE4.27 does not expose add_component; add ConstructionMesh and ConstructionBounds manually.")
else:
    for class_name, component_name in (("StaticMeshComponent", "ConstructionMesh"), ("BoxComponent", "ConstructionBounds")):
        component_class = getattr(unreal, class_name)
        created = add_component(blueprint, component_class)
        if created:
            created.set_editor_property("variable_name", component_name)

unreal.KismetEditorUtilities.compile_blueprint(blueprint)
unreal.EditorAssetLibrary.save_loaded_asset(blueprint)
unreal.log("Durin's Vault prototype shell saved: " + BLUEPRINT_PATH)
