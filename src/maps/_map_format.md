**subject to change**

*Local* maps contain both tile layout, and some metadata.

The purpose of this is to seamlessly display maps larger than 127x127 bytes (or a combination thereof).

All local maps will be stored in a bank greater than $100 (decimal 256+). The maximum size of a map is 16129 tiles, or 127 x 127.

Local map format:
```
    1 byte - x dimension of the map
    1 byte - y dimension of the map
    1 byte - Tileset
    1 byte - Out-of-Dimension Tile
    24 bytes - Surrounding maps (8 at 3 bytes apiece)
    224 bytes - warp designators (32 at 7 bytes apiece)
    16129 bytes - Map Tile Data (127x127 tiles, or 16129 tiles)
    2 bytes - unused
```

*X Dimension* is one byte, $00 to $FF. X * Y cannot be greater than 16129.

*Y Dimension* is one byte, $00 to $FF. X * Y cannot be greater than 16129.

*Tileset* is one byte, and indicates the tileset

*Out-of-Dimension Tile* is one byte, and indicates the tile the background should show if outside of XY and there's no adjacent map.

*Surrounding maps* are what maps are around the current map. X/Y dimensions, tileset, and the out-of-dimension tile must match. The first entry will be the map to the top-left, and subsequent entries will go clockwise, for a total of 8 possible maps. If no map is found in a direction, then the destination map bank should be $00

Surrounding map format:
```
    $bb aaaa
    bb - the destination map bank (1 byte)
    aaaa - the destination map address (2 bytes)
```
    

*Warp Designators* are to indicate where a warp (door, etc) will warp too. If no warp tile is wanted/needed, fill it with zeros.

Warp Designator format:
```
    $x1 y1 bb aaaa x2 y2 (7 bytes)
    x1 - the x location in the original map of the warp tile (1 byte)
    y1 - the y location in the original map of the warp tile (1 byte)
    bb - the destination map bank (1 byte)
    aaaa - the destination map address (2 bytes)
    x2 - the destination x coordinate (1 byte)
    y2 - the destination y coordinate (1 byte)
```

