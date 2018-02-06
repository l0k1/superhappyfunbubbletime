**subject to change**

There are two levels of maps, internally, *local* and *regional*.

*Local* maps contain both tile layout, and some metadata.

*Regional* maps show how local maps interact.

The purpose of this is to seamlessly display maps larger than 127x127 bytes (or a combination thereof).

All local maps will be stored in a bank greater than $100 (decimal 256+).

Local map format:
```
    $xx   - X Dimension (max 127)
    $xx   - Y Dimension (max 127)
    $xx   - Out-of-Dimension Tile
    Up to 40 warp designators @ 6 bytes apiece(discussed below)
    Map Tile Data (127x127 tiles, or 16129 tiles)
    11 unused bytes
```

*Warp Designators* are to indicate where a warp (door, etc) will warp too. If no warp tile is wanted/needed, fill it with zeros.

Warp Designator format:
```
    %x1y1rrbbx2y2
    x1 - the x location in the original map of the warp tile
    y1 - the y location in the original map of the warp tile
    rr - the destination region map
    bb - the destination local map
    x2 - the destination x coordinate
    y2 - the destination y coordinate
```

Regional Maps show how local maps interact. Regional maps dictate the tileset. Regional maps have a directory indicating which ID goes to which bank, and the address of the map in that bank.

Directory format:
```
    $id bank adds <- Map ID, Bank #, Address location in bank
```

Regional map format:
```
    $xx <- regional map ID
    $xx <- X dimensions
    $xx <- Y dimensions
    Map Data
```

Map Data format, where $bk is the MSB of the bank number for the map:
```
    ($bank of $00 indicates no map)
    $bk $bk $bk...
```
