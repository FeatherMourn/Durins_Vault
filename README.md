# Durin's Vault

Development workspace for a reusable Return to Moria modding platform. Building-system research and future custom construction content are its first major application.

## Current milestone

Establish a reproducible research-to-content pipeline: inspect existing pieces
with native UE4SS tooling, index IoStore building assets, validate catalog
records, and protect the active UE4SS profile before deployment work begins.

See [docs/setup.md](docs/setup.md) for local setup and validation, and [docs/roadmap.md](docs/roadmap.md) for the staged plan.

The consolidated entry point is `tools/durins-vault.ps1`:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\durins-vault.ps1 -Command status
powershell -ExecutionPolicy Bypass -File .\tools\durins-vault.ps1 -Command validate
powershell -ExecutionPolicy Bypass -File .\tools\durins-vault.ps1 -Command plan
```

These commands report status, run the complete safety validation, or create a
review-only profile deployment plan. None of them installs or modifies a mod.

The platform configuration contract is [durins-vault.project.json](durins-vault.project.json).

The mod package contract is documented in [docs/mod-definition.md](docs/mod-definition.md), with a starter package in [mods/example-wall/mod.json](mods/example-wall/mod.json).

Building-piece research is tracked separately in [docs/building-toolkit.md](docs/building-toolkit.md).
