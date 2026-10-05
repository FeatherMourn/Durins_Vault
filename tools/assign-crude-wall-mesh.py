import unreal

blueprint_path = "/Game/Durins_Vault/Building/Blueprints/BP_Crude_Wall_Variant"
blueprint = unreal.EditorAssetLibrary.load_asset(blueprint_path)
mesh = unreal.EditorAssetLibrary.load_asset("/Game/Durins_Vault/Building/Meshes/Source/Crude_Wall_3x1")
if not blueprint or not mesh:
    raise RuntimeError("Blueprint or mesh asset could not be loaded")
scs = blueprint.get_editor_property("simple_construction_script")
if not scs:
    raise RuntimeError("Blueprint Simple Construction Script was not available")
get_nodes = getattr(scs, "get_all_nodes", None)
if not get_nodes:
    raise RuntimeError("UE4.27 Python binding does not expose Simple Construction Script nodes")
nodes = get_nodes()
assigned = False
for node in nodes:
    name = str(node.get_editor_property("internal_variable_name"))
    template = node.get_editor_property("component_template")
    if name == "ConstructionMesh" and isinstance(template, unreal.StaticMeshComponent):
        template.set_editor_property("static_mesh", mesh)
        assigned = True
        break
if not assigned:
    raise RuntimeError("ConstructionMesh SCS node was not found")
blueprint.mark_package_dirty()
unreal.EditorAssetLibrary.save_loaded_asset(blueprint)
unreal.log("Assigned Crude_Wall_3x1 to BP_Crude_Wall_Variant")
