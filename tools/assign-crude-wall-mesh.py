import unreal

blueprint_path = "/Game/Durins_Vault/Building/Blueprints/BP_Crude_Wall_Variant"
blueprint = unreal.EditorAssetLibrary.load_asset(blueprint_path)
mesh = unreal.EditorAssetLibrary.load_asset("/Game/Durins_Vault/Building/Meshes/Source/Crude_Wall_3x1")
if not blueprint or not mesh:
    raise RuntimeError("Blueprint or mesh asset could not be loaded")
templates = blueprint.get_editor_property("component_templates")
assigned = False
for template in templates:
    if isinstance(template, unreal.StaticMeshComponent):
        template.set_editor_property("static_mesh", mesh)
        assigned = True
        break
if not assigned:
    raise RuntimeError("No StaticMesh component template was found")
blueprint.mark_package_dirty()
unreal.EditorAssetLibrary.save_loaded_asset(blueprint)
unreal.log("Assigned Crude_Wall_3x1 to BP_Crude_Wall_Variant")
