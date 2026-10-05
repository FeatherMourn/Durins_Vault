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
