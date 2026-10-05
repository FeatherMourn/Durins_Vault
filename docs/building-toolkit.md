# Building-content toolkit

The building toolkit starts with a catalog of observed construction pieces. A
catalog record is not yet a deployable mod: it separates what we know about an
existing piece from the future asset duplication and recipe-generation steps.

The record format is defined by
[building-piece.schema.json](../data/building/building-piece.schema.json).

The first catalog entry is [crude-wall-3x4-a.json](../data/building/crude-wall-3x4-a.json).
It was captured through the native MoriaAdvancedBuilder target inspector and
records a buildable Blueprint class and recipe identifier. Mesh, material, snap,
stability, and dimensions remain explicitly unknown instead of being guessed.
The Blueprint package path is now confirmed separately by the IoStore manifest:
`/Game/LevelDesign/Architecture/Suburbs/BP_Crude_Wall_3x4_A`.

The first asset-family fixture is
[blockout-asset-families.json](../data/building/blockout-asset-families.json).
It records twelve representative floor, foundation, stair, and wall paths
found in the main IoStore container. These are references only; no game asset
binary is bundled.

The research-backed construction field and DataTable hints are recorded in
[construction-reflection.json](../data/research/construction-reflection.json).
These names come from the existing native research code; they are guidance for
future inspection, not permission to assume current offsets or serialized row
types.

This gives the eventual building editor a truthful workflow:

1. inspect an existing piece;
2. enrich the record with asset metadata;
3. validate dependencies and construction behavior;
4. generate a new content definition;
5. package and test it in an isolated profile.

## Validate a piece

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\validate-building-piece.ps1 `
  -Record .\data\building\crude-wall-3x4-a.json
```

The validator checks the record identity, source provenance, referenced source
file, and any known dimensions. Unknown research fields are allowed; invented
values are not required to make a record pass.

The IoStore-backed asset catalog can be checked against the generated retoc
index with:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\validate-building-assets.ps1
```

This verifies every curated path is present in the current package scan before
asset metadata is used by a future building generator.
