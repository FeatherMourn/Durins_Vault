# Durin's Vault mod manifest

Every distributable mod has a `mod.json` at its root. The normative contract is
[`data/mod/mod.schema.json`](../data/mod/mod.schema.json), and the PowerShell
validator checks the parts that affect safe project deployment.

## Layers

- `runtime`: UE4SS modules or scripts.
- `cooked_content`: `.pak`, `.utoc`, `.ucas`, or other packaged content.
- `data_tables`: explicit table replacements or patches.
- `research`: relative paths to evidence used to build the mod; these are not deployed.

Each deployable artifact declares a project-relative `source`, a destination
relative to the game root (or using `${game_root}`), and an optional integer
`load_order`. A manifest may declare dependency IDs and required versions, but
dependency installation is intentionally outside the review-only planner until a
package index exists.

Validate an example manifest from the repository root:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\validate-mod.ps1 `
  -Manifest .\mods\example-wall\mod.json
```

Validate the complete local mod set before creating a profile or deployment plan:

```powershell
powershell -ExecutionPolicy Bypass -File .\\tools\\validate-mod-set.ps1 `
  -ModsRoot .\\mods
```

The mod-set check rejects duplicate IDs, unavailable dependencies, and cyclic
dependency graphs. It does not install dependencies or modify the game.
