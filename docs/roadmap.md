# Durin's Vault platform roadmap

Durin's Vault is a reusable Return to Moria modding platform. Custom building
content is its first major application, not the entire project.

## Phase 0 — Project realignment

- define platform architecture and module boundaries;
- document licensing and contribution rules;
- establish shared data formats and development conventions.

## Phase 1 — Platform foundation

- detect Steam and Epic installations;
- detect UE4SS and supported game versions;
- manage tool paths and mod profiles;
- provide backups, rollback, deployment diagnostics, and centralized logging.

## Phase 2 — Runtime research framework

- integrate native UE4SS capabilities;
- inspect objects, classes, properties, and components;
- discover DataTables and Blueprint references;
- export findings to clipboard and JSON;
- catalog findings by game version.

## Phase 3 — Asset and data pipeline

- integrate FModel, retoc, and UAssetGUI workflows;
- extract and inspect assets;
- round-trip DataTables;
- track dependencies and validate asset paths;
- package reproducible IoStore outputs.

## Phase 4 — Mod definition system

- define a manifest format;
- support runtime, cooked-content, and DataTable changes;
- declare dependencies and compatibility constraints;
- manage load order and profiles.

## Phase 5 — Building toolkit

- catalog construction pieces and recipes;
- represent meshes, materials, snap points, and stability data;
- validate construction references;
- duplicate existing pieces safely;
- generate the first custom building piece.

## Phase 6 — User-facing tools

- create a project and mod manager;
- provide an asset browser and building editor;
- add validation, packaging, deployment, and diagnostics interfaces.

## Phase 7 — Community platform

- provide a plugin/module API;
- publish templates and example mods;
- support shared profiles and documentation;
- establish an optional mod package index.

## Current status

- Phase 0: underway
- Phase 1: initial workspace, profile validation, and UE4SS snapshot tooling complete
- Phase 2: first native wall inspection and building-record validation complete
- Phase 3: IoStore package indexing and building asset catalog validation underway
- Phase 4: initial mod-definition schema and review-only deployment planner complete
- Phase 5 onward: not started
