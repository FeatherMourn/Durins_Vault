# Runtime modules

`DurinsVaultInspector` is the first native UE4SS module. It verifies that
Durin's Vault can load after Unreal reflection initialization and records the
aimed-at actor, hit component, and reflected property names and offsets.

The module follows the public UE4SS C++ mod shape used by the local
MoriaAdvancedBuilder reference project. UE4SS itself is not vendored here.

Run `tools/check-native-build.ps1` before configuring CMake. The currently
installed UE4SS developer archive contains runtime binaries but not the SDK
headers required by this source tree, so the native module is intentionally not
claimed to be buildable until those headers are supplied.

Native inspection exports are stored as discovery records under
`data/discoveries` and checked with `tools/validate-discovery.ps1` before they
are promoted into building-piece or mod-definition data.

The current runtime milestone prints the target actor and class to the UE4SS
log. Structured file output is deferred until the base F3 path is confirmed.

UE4SS Lua discovery uses the `enabled.txt` marker beside the `Scripts` folder;
the inspector package includes that marker explicitly.

After an in-game F3 inspection, validate the log before using it as research:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\validate-inspection-log.ps1 `
  -Log 'H:\SteamLibrary\steamapps\common\The Lord of the Rings Return to Moria™\Moria\Saved\DurinsVault-inspections.jsonl'
```

After validation, ingest the log into an ignored research catalog:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\ingest-inspection-log.ps1 `
  -Log 'H:\SteamLibrary\steamapps\common\The Lord of the Rings Return to Moria™\Moria\Saved\DurinsVault-inspections.jsonl'
```

The catalog intentionally does not claim recipe, buildability, or asset data;
those fields require separate evidence.
