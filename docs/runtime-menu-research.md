# Runtime construction-menu research

This note records the current evidence for the first cooked building prototype.

## Verified

- `DT_Constructions` accepts a runtime-added `DurinsVault_Crude_Wall_Variant` row.
- `DT_ConstructionRecipes` accepts a cloned recipe row with the result handle redirected to the new construction row.
- The native module applies both rows before the world UI is opened.
- The build tab creates its normal `UI_WBP_Build_Item_Medium_C` widget population.

## Not yet verified

The new row is not visible in the player-facing build menu. Table insertion and recipe-handle redirection are therefore insufficient evidence of buildability. The remaining investigation is the game's discovery/UI population path: the runtime module now requests discovery for the injected recipe once per world, and the next fresh session must verify whether that changes the widget population.

Until a fresh runtime capture shows the variant in the menu and allows placement, the building record must remain `buildable: false`.

## Safety boundary

The runtime definition pack is a research prototype. It is installed with backups and must not replace the original cooked DataTables. A failed menu test does not establish that the Blueprint, recipe, or construction actor is invalid; it only establishes that menu registration remains unproven.
