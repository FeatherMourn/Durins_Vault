# Runtime modules

`DurinsVaultInspector` is the first native UE4SS module. It is intentionally
small: the initial build only verifies that Durin's Vault can load after Unreal
reflection initialization. Construction inspection will be added after the
module build is verified.

The module follows the public UE4SS C++ mod shape used by the local
MoriaAdvancedBuilder reference project. UE4SS itself is not vendored here.
