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

## Current authoring boundary

The local `tools/UnrealEngine-4.27` checkout is source-only. It does not
contain `UnrealEditor.exe`, `UE4Editor.exe`, or a built UnrealBuildTool. It is
therefore useful as a reference for engine version and source research, but it
is not yet a usable replacement for the developer's content-authoring tools.
The current toolkit stops at evidence-backed records and packaging scaffolds
until a compatible editor/build environment is available.

## Validate a piece

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\validate-building-piece.ps1 `
  -Record .\data\building\crude-wall-3x4-a.json
```

The validator checks the record identity, source provenance, referenced source
file, declared Blueprint package path, and any known dimensions. Unknown
research fields are allowed; invented values are not required to make a record
pass.

The IoStore-backed asset catalog can be checked against the generated retoc
index with:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\validate-building-assets.ps1
```

This verifies every curated path is present in the current package scan before
asset metadata is used by a future building generator.

## Create an authoring scaffold

The platform can create a truthful, non-deployable building-piece scaffold
without inventing Blueprint, mesh, snap, or stability data:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\new-building-piece.ps1 `
  -Id community.my-wall `
  -DisplayName 'My Wall' `
  -RecipeId My_Wall `
  -Output .\working\authoring\my-wall.json
```

Scaffolds are marked `buildable: false` and use manual provenance until native
inspection and asset evidence have been attached. This makes the authoring
workflow usable now while preventing an incomplete record from being mistaken
for a deployable custom building piece.

## Promote verified evidence

Once a Blueprint summary and a matching construction-table summary exist, join
them into a validated research record:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\promote-building-piece.ps1 `
  -BlueprintSummary .\data\research\crude-wall-blueprint-export.json `
  -DataTableSummary .\data\research\construction-datatable-export.json `
  -Output .\working\authoring\crude-wall-promoted.json
```

Promotion intentionally leaves `buildable: false`; it organizes verified
evidence but does not claim that a new cooked asset or runtime-created piece is
deployable.

## Summarize observed construction properties

After ingesting native inspection records, generate a grouped property index:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\summarize-construction-properties.ps1
```

The report records only actor classes, property names, offsets, and observation
timestamps. It deliberately does not infer property types, values, recipes, or
buildability; those claims require separate verified runtime or asset evidence.
