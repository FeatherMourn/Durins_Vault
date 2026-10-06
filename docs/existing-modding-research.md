# Return to Moria Modding Research Audit

**Date:** 2026-10-05  
**Purpose:** Stop duplicating existing work and identify mechanisms Durin's Vault can reuse.

## Scope and confidence

This audit covers the public GitHub projects and documentation currently available for Return to Moria modding. It includes source trees cloned locally where possible, README/wiki material, and the public UE4SS ecosystem. Public repositories do not represent private Discord work or unreleased local projects, so this is a broad public-source audit rather than a claim that every experiment in the community is visible.

Facts marked as verified below come from source or repository documentation inspected during this audit. Capability claims from project documentation are treated as claims until reproduced against the installed Steam build.

## Projects that matter to Durin's Vault

| Project | What it has already solved | Reuse value |
|---|---|---|
| [MoriaAdvancedBuilder](https://github.com/jbowensii/MoriaAdvancedBuilder) | Native UE4SS C++ runtime, Quick-Build slots, overlay, definition packs, reflection-based DataTable work, configuration UI | **Highest.** Its Quick-Build selection and placement bridge are the proven path we should adapt. |
| [MoriaModCreator](https://github.com/jbowensii/MoriaModCreator) | GUI around FModel, UAssetGUI, retoc, ZenTools, JSON conversion, `.def` files, construction editing and packaging | Reuse definition formats, import flow, and packaging conventions instead of inventing another editor pipeline. |
| [RtoM-ArmorBuildings-Mod](https://github.com/TobiIchiro/RtoM-ArmorBuildings-Mod) | Real construction/armor content changes using legacy conversion, JSON edits, and IoStore repacking | Strong evidence for the cooked-content route and construction row structure. Its [construction documentation](https://github.com/TobiIchiro/RtoM-ArmorBuildings-Mod/wiki/Construction-Files-Documentation) is especially useful. |
| [Moria-WorldGen-Editor](https://github.com/jbowensii/Moria-WorldGen-Editor) | UE4.27 DataTable round-trip, row CRUD, IoStore packaging, and a substantial crash-oriented validator | Reuse validator ideas, NameMap/counter checks, cross-table reference checks, and build gating. |
| [MoriaManager](https://github.com/jbowensii/MoriaManager) | Save backup and mod installation/removal for Steam and Epic | Reuse deployment and rollback conventions, not construction logic. |
| [Moria-Replication](https://github.com/jbowensii/Moria-Replication) | Parent research/toolchain referenced by the WorldGen editor | Useful upstream source for legacy assets and broader reconstruction research; inspect before implementing world-generation features. |
| [Secrets-of-Khazad-dum-replication](https://github.com/TobiIchiro/Secrets-of-Khazad-dum-replication) | Public project documentation describes Blueprint decompilation, JsonAsAsset, Blender/FBX conversion, and world reconstruction | Useful as a research lead, but the repository URL was unavailable during this audit, so its claims are not yet source-verified. |
| [RE-UE4SS](https://github.com/UE4SS-RE/RE-UE4SS) | Runtime loading, reflection, C++/Lua mod support, and Unreal object/function access | Foundation only; it does not solve Moria's construction eligibility rules by itself. |

Several other public repositories found in searches are dedicated-server managers or deployment projects. They are not evidence for custom construction menus and should not drive our content architecture.

## The most important finding

AdvancedBuilder already contains the mechanism we were trying to recreate: saved Quick-Build recipe slots that open the native build flow and select an existing recipe. Its documentation describes eight persistent slots, icon handling, an overlay, configurable key bindings, and a native placement workflow. The source is organized around a native quick-build state machine, overlay management, and game-thread Unreal access.

That changes our direction:

> Durin's Vault should treat AdvancedBuilder's Quick-Build path as the placement adapter. The secondary menu should choose or configure a valid existing slot, then delegate to the game's own build flow. It should not manually create BuildPicker widgets or repeatedly inject a brand-new recipe into the hidden eligibility pipeline.

## What the other projects prove

### 1. Cooked content is the scalable asset layer

The Armor/Buildings project and MoriaModCreator demonstrate a repeatable content pipeline:

1. Extract assets with FModel.
2. Convert legacy/Zen assets with UAssetGUI and retoc as appropriate.
3. Modify JSON or definition inputs.
4. Repackage cooked content as IoStore files.
5. Install with backup and rollback.

This is suitable for many meshes, materials, Blueprints, icons, and data changes. The WorldGen editor shows how to make this safe with validation before launch.

### 2. Construction rows are multi-part data, not one table row

The Armor/Buildings export contains both construction definitions and recipe definitions. The recipe structure includes a construction row handle and unlock/requirement fields. Therefore a new selectable item generally needs consistent construction and recipe data, plus valid Blueprint, icon, category, discovery, and cache relationships. Our earlier row-only experiments were incomplete by design.

### 3. Runtime reflection is valuable, but not a substitute for established game flow

AdvancedBuilder's runtime reflection is appropriate for inspection, diagnostics, and controlled changes. It is not evidence that arbitrary new recipes will be accepted by every cached consumer. The BuildPicker and discovery behavior we observed confirms that adding rows to a live DataTable is insufficient.

### 4. Validation is a first-class tool

WorldGen Editor's validator checks duplicate rows, NameMap completeness, counter synchronization, cross-DataTable references, enabled state, orphan data, and structural hazards. Durin's Vault should apply the same principle to construction records and generated packages before any game launch.

## What we should stop duplicating

- Do not continue manual cloned-widget insertion. It already produced unstable behavior and a crash.
- Do not keep cycling native DataTable injection variants without first proving the exact consumer path from existing source.
- Do not build a second placement engine when AdvancedBuilder already has a working native handoff.
- Do not treat a package mounting successfully as proof that a menu entry is eligible.
- Do not copy upstream code wholesale. Preserve license, attribution, source revision, and the smallest reusable adapter surface.

## Revised Durin's Vault plan

### Phase 1 — Source audit (this milestone)

- Preserve this report and the local upstream research clones.
- Create a file-level map of AdvancedBuilder's Quick-Build, overlay, input, and placement functions.
- Record the exact source revision used for any adaptation.

### Phase 2 — Quick-Build adapter

- Replace the current experimental slot seeding with a thin adapter around the proven Quick-Build state machine.
- Select an already-valid Stone Wall recipe first.
- Verify the secondary menu can invoke that recipe and place/cancel normally.
- Keep the custom recipe injector disabled during this proof.

### Phase 3 — Content variants

- Use the MoriaModCreator/ArmorBuildings-style pipeline to produce a cooked mesh/Blueprint variant.
- Validate all construction and recipe references before packaging.
- Use an existing valid recipe slot as the first content delivery mechanism.

### Phase 4 — Scale

- Add a catalog of many variants behind the secondary menu.
- Reuse the same placement adapter for walls, floors, doors, roofs, and decorations.
- Add icons, categories, and search only after the placement path is stable.

### Phase 5 — New native menu entries (optional research track)

Only after the scalable slot-based system works should we revisit brand-new native BuildPicker entries. That work should begin by locating an existing upstream implementation or a complete consumer-side acceptance path, not by repeating the prior blind injection experiments.

## Practical conclusion

The work already done on inspection, asset provenance, packaging, backups, and the overlay is reusable. The part that needs realignment is the menu/placement strategy. The public research strongly supports building a secondary catalog that delegates to AdvancedBuilder's proven Quick-Build placement path, while treating native new-recipe registration as a later, separate reverse-engineering project.

## Source links

- [MoriaAdvancedBuilder](https://github.com/jbowensii/MoriaAdvancedBuilder)
- [MoriaModCreator](https://github.com/jbowensii/MoriaModCreator)
- [RtoM-ArmorBuildings-Mod](https://github.com/TobiIchiro/RtoM-ArmorBuildings-Mod)
- [Construction Files Documentation](https://github.com/TobiIchiro/RtoM-ArmorBuildings-Mod/wiki/Construction-Files-Documentation)
- [Moria-WorldGen-Editor](https://github.com/jbowensii/Moria-WorldGen-Editor)
- [MoriaManager](https://github.com/jbowensii/MoriaManager)
- [Moria-Replication](https://github.com/jbowensii/Moria-Replication)
- [Secrets-of-Khazad-dum-replication](https://github.com/TobiIchiro/Secrets-of-Khazad-dum-replication)
- [RE-UE4SS](https://github.com/UE4SS-RE/RE-UE4SS)
