#!/usr/bin/env python3
"""Draw the four textures the world is made of, into mods/cc_mapgen/textures/.

    python scripts/gen_textures.py

Dev tooling, and **neither a gate nor something CI runs**: the four PNGs are
committed artefacts, `check_game.sh` does not know about this file and luacheck
does not read Python. Nothing fails if it is never run again. It exists so that
the next iteration on the look costs one edit to the palette table below, and so
that the palettes and the seeds live somewhere they cannot rot.

The style, and why it is not something richer
--------------------------------------------
Following Soothing32: a **flat base colour** plus a **handful of sparse discrete
specks**, three or four colours in the whole tile, and most pixels identical.
Soothing32 is not low-contrast noise. A continuous value-noise field of the same
palette was drawn and rejected in playtest as grain, which is the temptation to
resist here -- adding a per-pixel jitter, or raising `count` until the specks
meet, turns the tile straight back into the thing this replaced.

Two properties are by construction, not by inspection
-----------------------------------------------------
* **Seamless.** Every cell of a speck is placed modulo the tile, so a cluster
  running off one edge reappears on the opposite one and a large flat area of
  the node shows no tiling grid.
* **Specks stay apart.** A speck is refused if any of its cells touches a
  non-base pixel, eight-connected and wrapped. Touching specks accumulate into
  patches, and a field of patches reads as noise again.

Reproducible: each texture draws from its own `random.Random(seed)` over a fixed
call sequence, so two runs produce byte-identical files whatever order the table
is read in. Verified by running twice and diffing, as `gen_reports.py` and
`gen_cdb_json.sh` are.
"""

import random
import struct
import zlib
from collections import Counter
from pathlib import Path

SIZE = 16

# The speck shapes: single pixels weighted heaviest, then pairs and one triple.
# Nothing larger -- a four-pixel cluster reads as a blotch at this scale.
SHAPES = [
    [(0, 0)],
    [(0, 0)],
    [(0, 0)],
    [(0, 0), (1, 0)],
    [(0, 0), (0, 1)],
    [(0, 0), (1, 1)],
    [(0, 0), (1, 0), (0, 1)],
]


def specks(base, accents, count, seed):
    """A flat field of `base` with `count` specks of colours drawn from
    `accents`. Gives up after 4000 rejected placements rather than looping for
    ever, so raising `count` past what the spacing rule allows yields fewer
    specks instead of hanging."""
    rnd = random.Random(seed)
    px = [[base] * SIZE for _ in range(SIZE)]
    placed = 0
    tries = 0
    while placed < count and tries < 4000:
        tries += 1
        shape = SHAPES[rnd.randrange(len(SHAPES))]
        colour = accents[rnd.randrange(len(accents))]
        ox, oy = rnd.randrange(SIZE), rnd.randrange(SIZE)
        cells = [((ox + dx) % SIZE, (oy + dy) % SIZE) for dx, dy in shape]
        touches = any(
            px[(y + ny) % SIZE][(x + nx) % SIZE] != base
            for x, y in cells
            for ny in (-1, 0, 1)
            for nx in (-1, 0, 1)
        )
        if touches:
            continue
        for x, y in cells:
            px[y][x] = colour
        placed += 1
    return px


def border(edge):
    """A one-pixel opaque border of `edge` on a transparent centre, which is
    what plain `glasslike` needs to draw a visible outline per node while the
    wall stays see-through. Flat, and deliberately not dithered: two near-black
    tones eight steps apart are variation no player can see, and one colour is
    the same tiling-by-construction guarantee for free."""
    clear = (0, 0, 0, 0)
    return [
        [edge if x in (0, SIZE - 1) or y in (0, SIZE - 1) else clear
         for x in range(SIZE)]
        for y in range(SIZE)
    ]


def writepng(path, px):
    """Write `px`, a SIZE x SIZE list of rows of RGB or RGBA tuples. The colour
    type follows the tuple width, so an opaque texture stays three channels and
    only the barrier carries an alpha channel."""
    colour_type = 6 if len(px[0][0]) == 4 else 2
    raw = b"".join(
        b"\x00" + bytes(v for pixel in row for v in pixel) for row in px
    )

    def chunk(tag, data):
        return (struct.pack(">I", len(data)) + tag + data
                + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF))

    path.write_bytes(
        b"\x89PNG\r\n\x1a\n"
        + chunk(b"IHDR",
                struct.pack(">IIBBBBB", SIZE, SIZE, 8, colour_type, 0, 0, 0))
        + chunk(b"IDAT", zlib.compress(raw, 9))
        + chunk(b"IEND", b"")
    )


# The palettes and the seeds. A seed is only a label for one arrangement of
# specks: change it and the tile is redrawn, so the four committed PNGs are what
# these values mean.
TEXTURES = {
    # Green, with two darker greens and one that leans towards moss.
    "cc_mapgen_grass.png": specks(
        base=(156, 196, 60),
        accents=[(120, 163, 47), (95, 145, 62), (78, 133, 104)],
        count=8,
        seed=7,
    ),
    # Brown, with one darker brown and one grey pebble tone offered. Five specks
    # over two accents happen to draw only the darker brown, so the tile as
    # printed is two colours and not three; that is the arrangement the author
    # approved, not an accident to correct.
    "cc_mapgen_dirt.png": specks(
        base=(139, 101, 71),
        accents=[(112, 78, 54), (96, 85, 78)],
        count=5,
        seed=23,
    ),
    # Near-black grey, one shade down and one up, so the floor reads as a
    # material rather than as a flat fill.
    "cc_mapgen_bedrock.png": specks(
        base=(40, 40, 45),
        accents=[(28, 28, 32), (60, 60, 68)],
        count=6,
        seed=59,
    ),
    "cc_mapgen_barrier.png": border(edge=(16, 16, 16, 255)),
}

OUT = Path(__file__).resolve().parent.parent / "mods" / "cc_mapgen" / "textures"

for name, pixels in TEXTURES.items():
    writepng(OUT / name, pixels)
    tally = Counter(pixel for row in pixels for pixel in row)
    base, base_count = tally.most_common(1)[0]
    print(f"{name}: {len(tally)} colours, "
          f"{base_count}/{SIZE * SIZE} px are the base {base}")
