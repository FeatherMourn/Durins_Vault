# Contributing to Durin's Vault

Durin's Vault is a research and tooling platform. Contributions should make
the workflow more reproducible for the next mod author.

## Add a mod

1. Create a directory under `mods/<mod-id>/`.
2. Add a `mod.json` using the `durins-vault.mod/v1` contract.
3. Keep runtime, cooked-content, and DataTable artifacts declared in their
   corresponding layer; do not rely on undeclared files in a package.
4. Run `tools/validate-mod.ps1` and `tools/validate-mod-set.ps1`.
5. Generate a review-only profile plan and package before deployment.

## Add research

Research records belong under `data/discoveries` or `data/research`. Include
the game version, tool/source provenance, and uncertainty explicitly. Do not
commit extracted game binaries, proprietary SDKs, or raw exports unless their
license permits redistribution.

## Add building content

Start with `tools/new-building-piece.ps1` when evidence is incomplete. A piece
must remain `buildable: false` until its Blueprint, recipe, and required asset
references have been verified. Existing game assets should be referenced by
path; they should not be copied into this repository.

## Before submitting changes

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\durins-vault.ps1 -Command validate
git diff --check
```

Changes that affect deployment should also be tested through the dry-run
planner. Applying changes to a local game is a separate, explicit step.
