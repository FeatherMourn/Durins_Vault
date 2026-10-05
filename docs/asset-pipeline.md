# Asset pipeline status

Return to Moria uses cooked IoStore content. The local installation currently
contains the primary `.pak`, `.ucas`, and `.utoc` files, but no extraction tool
is configured in the Durin's Vault project yet.

The first reproducible pipeline fixture is therefore a research asset catalog,
not a copied game asset. [game-asset-references.json](../data/research/game-asset-references.json)
records paths identified by the MoriaAdvancedBuilder project and explicitly
marks them as non-bundled references.

This distinction matters: game assets remain the user's installed content and
are not redistributed by this repository. Once FModel or an equivalent reader
is configured, the catalog can drive existence checks and metadata exports.

## Current local package evidence

The Steam installation has:

- `Moria-WindowsNoEditor.pak`
- `Moria-WindowsNoEditor.ucas`
- `Moria-WindowsNoEditor.utoc`
- `global.ucas`
- `global.utoc`

FModel is now installed in the external tool cache at
`I:/My Drive/Mines of Moria Mods/tools/FModel/app/FModel.exe` and recorded in
the project manifest. The next pipeline task is to configure it against those
files, then export one small, versioned metadata fixture—preferably a
building-related Blueprint or DataTable—without committing the original binary
asset.
