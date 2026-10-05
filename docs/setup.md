# Durin's Vault development setup

## Game installation

The current Steam installation is:

`H:\SteamLibrary\steamapps\common\The Lord of the Rings Return to Moria™`

The Unreal game executable is under `Moria\Binaries\Win64`.

## Development safety

- Use a separate test world and back up saves before every cooked-content test.
- Do not edit the original game files.
- Keep generated assets and extracted game data outside the repository unless they are small, redistributable research fixtures.
- Test multiplayer and save/reload behavior before treating a building experiment as successful.

## Tool roles

- UE4SS: runtime inspection and diagnostic hooks.
- FModel: browse and export game assets.
- retoc: convert and package IoStore content.
- UAssetGUI: inspect and round-trip UE4.27 assets/DataTables.

## First milestone

The first diagnostic build should target an existing placed wall or floor and record:

- object/class path;
- construction or recipe identifier;
- Blueprint and mesh references;
- icon reference;
- snap/placement properties;
- stability-related components or properties;
- game version and test-world context.

## Environment validation

Run the read-only validator from the project root:

`powershell -ExecutionPolicy Bypass -File tools/validate-project.ps1`

It checks the selected profile, game installation, UE4SS root, Content root,
and pak root. Optional tools are reported as `UNCONFIGURED` until their paths
are deliberately added to the project manifest.

## Native module build

The native inspector uses the UE4SS C++ API and must be built against the same
UE4SS SDK/API version installed in the game. The local MoriaAdvancedBuilder
checkout under `work/reference/` is a reference only; it is not part of the
Durin's Vault source tree.

The first source skeleton is in `runtime/DurinsVaultInspector`. It currently
verifies module loading and Unreal reflection initialization. Do not copy a
compiled DLL into the game until the module has been built and tested.
# Local setup

The project is intentionally configured around the Steam installation currently
used for testing. The game itself remains outside the repository; the manifest
only records where it can be found.

## Validate the environment

From the project root, run:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\validate-project.ps1
```

The validator checks the project manifest, game installation, UE4SS paths, the
content and pak directories, configured external tools, and the installed
MoriaCppMod native research module. It is read-only unless `-JsonOutput` is
provided, in which case it writes a report inside the project:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\validate-project.ps1 `
  -JsonOutput working\reports\environment.json
```

`MoriaCppMod` is currently the native inspection reference implementation. Its
presence is required for the runtime-research milestone, but the project does
not copy or redistribute its binary.

## Validate the complete workspace

Run the aggregate health check from the project root:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\validate-all.ps1
```

This runs the environment, example mod-definition, and building-record checks
as one gate. A nonzero result means the workspace is not ready for the next
pipeline step.

## Optional Unreal source access

Epic/GitHub source access is not required for the current workflow. The project
uses the shipped game and prebuilt UE4SS/MoriaCppMod while research is being
collected. Unreal source may be added later as an external developer tool if we
need to build UE4SS or investigate engine internals.
