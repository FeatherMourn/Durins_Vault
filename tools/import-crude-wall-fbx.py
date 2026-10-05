import unreal

files = [
    r"F:\DurinsVault Authoring\DurinsVault_Auth\Content\Durins_Vault\Building\Meshes\Source\Crude_Wall_3x1.fbx",
    r"F:\DurinsVault Authoring\DurinsVault_Auth\Content\Durins_Vault\Building\Meshes\Source\Crude_Wall_3x3.fbx",
]

tasks = []
for filename in files:
    options = unreal.FbxImportUI()
    options.import_mesh = True
    options.import_as_skeletal = False
    options.import_materials = False
    options.import_textures = False
    options.static_mesh_import_data.combine_meshes = True
    task = unreal.AssetImportTask()
    task.filename = filename
    task.destination_path = "/Game/Durins_Vault/Building/Meshes"
    task.automated = True
    task.replace_existing = True
    task.save = True
    task.options = options
    tasks.append(task)

unreal.AssetToolsHelpers.get_asset_tools().import_asset_tasks(tasks)
unreal.log("Durin's Vault FBX import complete")
