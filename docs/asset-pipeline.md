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

FModel is installed in the external tool cache at
`I:/My Drive/Mines of Moria Mods/tools/FModel/app/FModel.exe` and recorded in
the project manifest. retoc `v0.1.5` is also installed at
`I:/My Drive/Mines of Moria Mods/tools/retoc/app/retoc.exe` and successfully
read the installed `global.utoc` container. Its reported container has three
chunks and zero packages; the main game container remains the next target for
inspection.

UAssetGUI's current experimental build is installed at
`I:/My Drive/Mines of Moria Mods/tools/UAssetGUI/UAssetGUI.exe`. It is reserved
for examining exported `.uasset` properties after retoc or FModel produces a
working asset file; it is not pointed at the original IoStore container.

The next pipeline task is to configure FModel against the game archives, then
export one small, versioned metadata fixture—preferably a building-related
Blueprint or DataTable—without committing the original binary asset.

## Generate a building asset index

The main IoStore directory can already be indexed without extracting or
redistributing game files:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\generate-iostore-building-index.ps1
```

The generated report is placed under `working/reports` and is ignored by Git.
It records package paths only. The first scan identified 5,208 construction-
related names using a broad search; the generator narrows this to the
`/Game/Art/Assets/Blockout/SM_AR_...` floor, foundation, stair, and wall
families that are useful for building research.

The first DataTable candidates are recorded in
[building-datatables.json](../data/research/building-datatables.json). The
IoStore index confirms the package paths for construction recipes, all recipes,
item recipes, and recipe bundles. Their row schemas remain unverified until a
reader exports properties; the catalog intentionally does not guess them.

The DataTable index is generated with
`tools/generate-datatable-index.ps1` and checked with
`tools/validate-building-datatables.ps1`. retoc's standalone asset-registry
reader cannot be used here because the game container does not expose a
separate `AssetRegistry.bin`; the package manifest is the current authoritative
path-level evidence.

## Metadata export contract

When FModel or another reader produces a property export, record the verified
metadata using [asset-export.schema.json](../data/research/asset-export.schema.json).
The contract requires the game asset path, asset kind, reader and version, source
container, and export date. It permits reader-specific properties and DataTable
rows while keeping the original cooked asset outside the repository.

Validate an export against the package manifest with:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\validate-asset-export.ps1 `
  -Export .\working\authoring\asset-export.json `
  -Index .\working\iostore-manifest\pakstore.json
```

For a raw FModel properties export, use the importer first:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\import-fmodel-export.ps1 `
  -Export 'I:\path\to\FModel\Output\Exports\Moria\Content\Tech\Data\Building\DT_Constructions.json' `
  -AssetKind datatable `
  -Output .\working\authoring\asset-export-dt-constructions.json
```

The importer writes the standard contract and invokes validation automatically.
