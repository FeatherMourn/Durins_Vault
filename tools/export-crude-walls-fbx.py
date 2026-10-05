import bpy
from pathlib import Path

blend = Path(r"F:\DurinsVault Authoring\Converted\crude_walls_imported.blend")
output = Path(r"F:\DurinsVault Authoring\Converted\fbx")
output.mkdir(parents=True, exist_ok=True)
bpy.ops.wm.open_mainfile(filepath=str(blend))

for name in ("Crude_Wall_3x1_LOD0", "Crude_Wall_3x3_LOD0"):
    obj = bpy.data.objects.get(name)
    if not obj:
        raise RuntimeError("Missing imported mesh: " + name)
    bpy.ops.object.select_all(action="DESELECT")
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    bpy.ops.export_scene.fbx(
        filepath=str(output / (name.replace("_LOD0", "") + ".fbx")),
        use_selection=True,
        object_types={"MESH"},
        apply_unit_scale=True,
        bake_space_transform=False,
        path_mode="AUTO",
    )
print("DurinsVault FBX export complete")
