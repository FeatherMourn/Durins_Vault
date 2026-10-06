# Native research source state

Durin's Vault builds its native runtime module against the external
MoriaAdvancedBuilder/RE-UE4SS checkout. The checkout must remain external;
this repository owns the Durin's Vault design, manifests, validation, and
deployment tooling rather than vendoring the full UE4SS dependency tree.

The current research build was verified against reference checkout commit
`bba9708030b770c362fe8b5a0b72317cbf58e223`. The MoriaCppMod working tree has
local research changes in:

- `MyCPPMods/MoriaCppMod/src/dllmain.cpp`
- `MyCPPMods/MoriaCppMod/src/moria_DefinitionProcessing.inl`
- `MyCPPMods/MoriaCppMod/src/moria_unlock.inl`

Those changes include the native inspection record writer, construction-row
and discovery-state diagnostics, and BuildPicker eligibility diagnostics.
They currently compile and load in the Steam installation. The latest runtime
evidence proves that the injected rows reach the live tables and discovery
caches, but the BuildPicker filter rejects the new recipe before card creation.

Before a release build, export or commit the external source changes through
the reference repository and record its resulting commit here. Do not treat a
game-install DLL as the source of truth.
