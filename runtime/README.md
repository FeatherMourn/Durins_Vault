# Runtime modules

`DurinsVaultInspector` is the first native UE4SS module. It is intentionally
small: the initial build only verifies that Durin's Vault can load after Unreal
reflection initialization. Construction inspection will be added after the
module build is verified.

The module follows the public UE4SS C++ mod shape used by the local
MoriaAdvancedBuilder reference project. UE4SS itself is not vendored here.

Run `tools/check-native-build.ps1` before configuring CMake. The currently
installed UE4SS developer archive contains runtime binaries but not the SDK
headers required by this source tree, so the native module is intentionally not
claimed to be buildable until those headers are supplied.

Native inspection exports are stored as discovery records under
`data/discoveries` and checked with `tools/validate-discovery.ps1` before they
are promoted into building-piece or mod-definition data.

The Lua inspector also appends structured hit records to
`Moria/Saved/DurinsVault/inspections.jsonl`. Each line contains an ISO-8601 UTC
timestamp, the target actor full name, and its class full name. This file is a
runtime evidence handoff; it is not automatically committed to the repository
because it is generated from the user's game session.

After an in-game F3 inspection, validate the log before using it as research:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\validate-inspection-log.ps1 `
  -Log 'H:\SteamLibrary\steamapps\common\The Lord of the Rings Return to Moria™\Moria\Saved\DurinsVault\inspections.jsonl'
```
