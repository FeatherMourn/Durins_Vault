# Durin's Vault Research Integration Roadmap

**Purpose:** Use the public Return to Moria modding ecosystem to strengthen Durin's Vault while preserving attribution, licenses, and independent implementation.

## Guiding rules

1. Reuse MIT-licensed code only with its copyright and license notice preserved.
2. Treat projects without a clear license as research references, not code or asset sources.
3. Keep third-party dependencies separate and preserve their individual notices.
4. Reproduce workflows and technical ideas independently rather than copying substantial documentation or source.
5. Record upstream project, URL, revision, license, reused files, and changes in the attribution manifest for every integration.

## Integration map

| Project | Role in Durin's Vault | Treatment |
|---|---|---|
| [MoriaAdvancedBuilder](https://github.com/jbowensii/MoriaAdvancedBuilder) | Quick-Build placement, native hooks, overlay, input, configuration, logging | Reuse selected MIT code with attribution; adapt behind a Durin's Vault interface. |
| [MoriaModCreator](https://github.com/jbowensii/MoriaModCreator) | Definition editor, import flow, construction tooling, packaging workflow | Reuse MIT-licensed patterns or selected code only after file-level review; preserve notices. |
| [Moria-WorldGen-Editor](https://github.com/jbowensii/Moria-WorldGen-Editor) | Validation, rollback, DataTable editing, IoStore build gates | Reuse MIT-licensed validator ideas and selected utilities with attribution. |
| [RE-UE4SS](https://github.com/UE4SS-RE/RE-UE4SS) | Runtime loader and Unreal reflection foundation | Use as a separately documented MIT-licensed dependency; preserve dependency notices. |
| [RtoM-ArmorBuildings-Mod](https://github.com/TobiIchiro/RtoM-ArmorBuildings-Mod) | Construction/recipe workflow and packaging research | Research reference only until the author provides a license or permission. |
| [MoriaManager](https://github.com/jbowensii/MoriaManager) | Deployment, backups, profiles, and installation workflow | Research reference until its license is verified. |
| [Moria-Replication](https://github.com/jbowensii/Moria-Replication) | Asset and world reconstruction research | Research reference; inspect licenses before code reuse. |

## Development phases

### Phase 1 — Attribution and compliance foundation

- Add `THIRD_PARTY_NOTICES.md`.
- Add an attribution manifest recording project, URL, revision, license, files, and modifications.
- Copy required MIT notices into the distribution package.
- Record separate notices for RE-UE4SS and all bundled dependencies.
- Mark unlicensed projects as research-only.

### Phase 2 — Runtime foundation

- Extract only the AdvancedBuilder Quick-Build and required overlay/input pieces.
- Keep the adapter boundary small and documented.
- Remove experimental direct-widget and blind recipe-injection paths from the active build.
- Prove selection and placement using an existing Stone Wall recipe.
- Verify placement, cancellation, rotation, save/reload, and normal shutdown.

### Phase 3 — Authoring pipeline

- Build a repeatable FModel → Blender/FBX → UE4.27 → cooked-package workflow.
- Add asset provenance to every imported mesh, Blueprint, icon, and material.
- Use MoriaModCreator and ArmorBuildings as workflow references, not copied assets.
- Create a standard content manifest for each building piece.

### Phase 4 — Validation and packaging

- Adapt WorldGen Editor’s validator approach to construction content.
- Check duplicate rows, missing references, invalid package paths, missing dependencies, stale manifests, and incompatible versions.
- Build packages only after validation passes.
- Install with backup, hash verification, rollback, and an uninstall manifest.

### Phase 5 — Durin’s Vault catalog and secondary menu

- Define a versioned catalog schema for names, categories, icons, Blueprints, meshes, recipe sources, and compatibility.
- Have the secondary menu select valid Quick-Build entries through the adapter.
- Add categories and search in Durin’s Vault without trying to replace the native BuildPicker.
- Add content packs that can be installed independently.

### Phase 6 — Expansion and optional research

- Add walls, floors, doors, roofs, decorations, and themed material sets.
- Add authoring helpers for other modders.
- Add profile support for different mod collections and worlds.
- Revisit native new-recipe registration only if an existing public implementation or a complete consumer-side path is identified.

## Definition of success

Durin's Vault succeeds when a new building piece can be added by following one documented workflow:

1. import or create the asset;
2. create its Blueprint and metadata;
3. validate references and provenance;
4. package it with preserved licenses;
5. install it with rollback protection;
6. select it from the Durin's Vault menu;
7. place and remove it through the game's stable placement path.

The result should be reproducible for one piece or hundreds of pieces without reopening the hidden native BuildPicker reverse-engineering problem each time.
