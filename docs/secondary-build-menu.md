# Secondary build menu

The next building-toolkit experiment is a Durin's Vault menu that presents
custom entries without adding rows to Moria's native BuildPicker.

## Why this route

Runtime construction and recipe rows can be inserted into the live tables and
discovery caches, but the native BuildPicker applies an additional eligibility
filter before creating its item widgets. A separate menu avoids depending on
that opaque filter while preserving the game's own placement and ghost logic.

## Proof-of-concept boundary

The first prototype will contain one existing, verified construction: the
Crude Wall. It will:

1. open from a Durin's Vault input action;
2. display one selectable entry;
3. select the construction through the existing build-tab selection path;
4. hand control back to Moria's normal placement/ghost system;
5. close safely after placement or cancellation.

The current native research code already provides the relevant placement
handles and a tested `blockSelectedEvent` path. The prototype must reuse those
handles rather than manually spawning construction actors or copying widgets.

## Expansion path

After the one-item proof succeeds, entries become data-driven records containing
display name, icon, construction row, recipe row, and compatibility metadata.
Categories, scrolling, custom assets, and multiple building families can then
be added without changing the placement bridge.

## Safety requirements

- keep the native BuildPicker injection experiment disabled;
- do not manually attach cloned widgets to the game's scroll box;
- preserve the existing placement and multiplayer guards;
- back up the runtime DLL before each test deployment;
- require a normal game exit and log verification after every prototype change.
