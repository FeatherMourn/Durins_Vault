# Durin's Vault project format

`durins-vault.project.json` is the shared configuration contract for the
platform. Tools should read this file rather than embedding machine-specific
paths.

## Path rules

- Use forward slashes in stored paths.
- `${game_root}` resolves to the selected game installation.
- Relative working and backup paths resolve from the project root.
- Tool paths remain unset until verified on the current machine.

## Profile rules

A profile describes one game installation and deployment target. The initial
`steam-local` profile targets the installed Steam copy and uses profiled
deployment so generated files can be backed up and rolled back.

## Module identifiers

- `runtime` — UE4SS/native runtime integration.
- `research` — object, Blueprint, DataTable, and asset discovery.
- `content` — extraction, conversion, dependency tracking, and IoStore output.
- `building` — construction definitions, validation, and generation.
