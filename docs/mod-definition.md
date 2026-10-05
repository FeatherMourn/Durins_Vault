# Durin's Vault mod definition

Durin's Vault treats a mod as a declared package rather than a collection of
files copied directly into the game. This lets the platform validate
compatibility, dependencies, load order, and deployment targets before making
changes to a game installation.

The machine-readable contract is [mod-definition.schema.json](mod-definition.schema.json).

## Layers

- `runtime`: UE4SS Lua or native modules.
- `cooked_content`: assets that will eventually be packaged into IoStore/Pak
  output.
- `data_tables`: structured edits or additions that require an asset pipeline.
- `research`: optional source findings used while developing a mod; these are
  not deployed as game content.

The first three are deployment layers. A mod may use one or more of them, but
each entry must declare its source, destination, and compatibility scope.

## Example

```json
{
  "schema": "durins-vault.mod/v1",
  "id": "durins-vault.example-wall",
  "name": "Example Wall",
  "version": "0.1.0",
  "game": { "id": "return-to-moria", "engine": "UE4.27" },
  "requires": [],
  "layers": {
    "runtime": [],
    "cooked_content": [],
    "data_tables": [],
    "research": ["data/research/example-wall.json"]
  }
}
```

Research records are deliberately separate from deployable layers so findings
can be shared without accidentally treating an inspection export as a mod.

## Validate a package

From the project root:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\validate-mod.ps1 `
  -Manifest .\mods\example-wall\mod.json
```

The validator is intentionally independent of FModel, retoc, and UAssetGUI.
Those tools produce artifacts consumed by this contract; they are not allowed
to define whether a package is structurally safe to inspect or deploy.

## Preview deployment

Deployment is currently review-only. Generate a plan without copying or
overwriting anything:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\plan-deployment.ps1 `
  -Manifest .\mods\example-wall\mod.json `
  -JsonOutput .\working\reports\example-wall-deployment.json
```

The planner resolves the selected game profile, checks source artifacts, maps
destinations, records whether a destination already exists, and labels every
operation `REVIEW_ONLY`. An apply/deployment command will only be added after
backup and rollback behavior has been implemented and tested.
