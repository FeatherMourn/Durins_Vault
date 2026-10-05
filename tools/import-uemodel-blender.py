import bpy
import importlib.util
from pathlib import Path

addon_root = Path(r"I:\My Drive\Mines of Moria Mods\tools\UEFormat\plugins\blender\io_scene_ueformat")
spec = importlib.util.spec_from_file_location("io_scene_ueformat", addon_root / "__init__.py", submodule_search_locations=[str(addon_root)])
addon = importlib.util.module_from_spec(spec)
spec.loader.exec_module(addon)
addon.register()

source_dir = Path(r"I:\My Drive\Mines of Moria Mods\tools\FModel\app\Output\Exports\Moria\Content\Art\Assets\Kits\Architecture\Suburbs")
output_dir = Path(r"F:\DurinsVault Authoring\Converted")
output_dir.mkdir(parents=True, exist_ok=True)

for filename in ("Crude_Wall_3x1.uemodel", "Crude_Wall_3x3.uemodel"):
    path = source_dir / filename
    bpy.ops.uf.import_uemodel(directory=str(source_dir) + "\\", files=[{"name": filename}])

bpy.ops.wm.save_as_mainfile(filepath=str(output_dir / "crude_walls_imported.blend"))
print("DurinsVault UEFormat import complete")
