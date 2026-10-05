# FModel setup for Return to Moria

FModel is an external reader. It is not copied into this repository and it
must not write into the Steam installation.

## Configure the archive directory

Open the configured FModel executable and choose:

```text
H:\SteamLibrary\steamapps\common\The Lord of the Rings Return to Moria™\Moria\Content\Paks
```

FModel should then show the main `Moria-WindowsNoEditor` IoStore container and
the `global` container. Keep the output directory outside the game directory,
preferably under the external tool cache or a project `working` directory.

## Recommended first exports

Export properties as JSON for these packages:

- `/Game/LevelDesign/Architecture/Suburbs/BP_Crude_Wall_3x4_A`
- `/Game/Tech/Data/Building/DT_Constructions`
- `/Game/Tech/Data/Building/DT_ConstructionRecipes`

Save exports under ignored `working/reports/fmodel/`. Do not commit exported
game binaries or bulk data. The JSON exports can be reviewed and converted into
small, source-attributed research records.

## Evidence boundary

Package names from retoc prove that a path exists in the IoStore directory; they
do not prove Blueprint properties or DataTable row schemas. Those details must
come from a FModel property export or a native runtime inspection record.
