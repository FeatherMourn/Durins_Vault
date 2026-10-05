import unreal

blueprint_path = "/Game/Durins_Vault/Building/Blueprints/BP_Crude_Wall_Variant"
blueprint = unreal.EditorAssetLibrary.load_asset(blueprint_path)
mesh = unreal.EditorAssetLibrary.load_asset("/Game/Durins_Vault/Building/Meshes/Source/Crude_Wall_3x1")
if not blueprint or not mesh:
    raise RuntimeError("Blueprint or mesh asset could not be loaded")
blueprint_class = unreal.EditorAssetLibrary.load_blueprint_class(blueprint_path)
if not blueprint_class:
    raise RuntimeError("Blueprint generated class could not be loaded")
components = unreal.get_default_object(blueprint_class).get_components_by_class(unreal.StaticMeshComponent)
if not components:
    raise RuntimeError("ConstructionMesh component was not found")
components[0].set_editor_property("static_mesh", mesh)
unreal.EditorAssetLibrary.save_loaded_asset(blueprint)
unreal.log("Assigned Crude_Wall_3x1 to BP_Crude_Wall_Variant")
