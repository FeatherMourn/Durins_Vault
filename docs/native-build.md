# Native UE4SS build gate

`runtime/DurinsVaultInspector` is the native runtime extension point for
Durin's Vault. It deliberately uses the public UE4SS C++ mod shape, but the
repository does not vendor UE4SS source or headers.

Run the gate from the repository root:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\check-native-build.ps1
```

The gate requires these headers under the supplied UE4SS source directory:

- `include/DynamicOutput/Output.hpp`
- `include/Mod/CppUserModBase.hpp`
- `include/Unreal/UObjectGlobals.hpp`
- `include/Unreal/UObject.hpp`

The installed runtime is sufficient for Lua modules, but the local reference
checkout currently provides only part of the native include surface. In
particular, `CppUserModBase.hpp` is present in the MoriaAdvancedBuilder
reference, while the Unreal reflection and DynamicOutput headers are absent.
That result is recorded as `SOURCE_HEADERS_REQUIRED`, not as a failed game
installation or a failed mod design.

When a complete, license-compatible UE4SS developer source tree is available,
pass it explicitly with `-UE4SSSource` and then configure the CMake project.
The source tree should remain external to this repository; only the module
source and build instructions belong here.

The local MoriaAdvancedBuilder reference contains a complete CMake dependency
tree under `RE-UE4SS`, so it can be used as an external build input for
experimentation. From a Visual Studio developer shell:

```powershell
cmake -S .\runtime -B .\working\build\native `
  -DUE4SS_SOURCE='I:\My Drive\Mines of Moria Mods\work\reference\MoriaAdvancedBuilder\RE-UE4SS'
cmake --build .\working\build\native --config Release --target DurinsVaultInspector
```

The UE4SS reference currently uses the `Game__Shipping__Win64` configuration.
The resulting module is deployed as `ue4ss/Mods/DurinsVaultInspector/dlls/main.dll`.
After launching a world, press `F3` while aiming at an object. The native
inspector logs the hit actor and component full names to `UE4SS.log`.
The JSONL research record is written relative to the game working directory at
`Mods/DurinsVaultInspector/inspection.jsonl` and includes reflected property
names and offsets for the hit actor class.

To stage a rebuilt DLL with a backup of the previous installation:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\stage-native-inspector.ps1 `
  -BuildDll 'C:\path\to\DurinsVaultInspector.dll' `
  -GameRoot 'H:\SteamLibrary\steamapps\common\The Lord of the Rings Return to Moria™'
```
