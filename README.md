Codecube
=========================

[![CI](https://github.com/gigaturbo/codecube/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/gigaturbo/codecube/actions/workflows/ci.yml)
![License](https://img.shields.io/badge/code-AGPL--3.0--only-blue.svg)
![Media license](https://img.shields.io/badge/media-CC%20BY--SA%204.0-blue.svg)
[![ContentDB](https://content.luanti.org/packages/giga-turbo/codecube/shields/downloads/)](https://content.luanti.org/packages/giga-turbo/codecube/)

**Codecube allows to use `lua` code in Luanti to build anything you want**

The programming itself — the drone, the in-game Lua editor, the sandbox and the API — is the [CodeBlock](https://content.luanti.org/packages/giga-turbo/codeblock/) mod, which Codecube bundles. What the game adds is a place to build: a flat, clean world, permanent daylight, build restrictions, and settings tuned so that writing code is the point.

**For the Lua API, the drone commands, the block lists and the `codelevel` limits, read the [CodeBlock documentation](https://github.com/gigaturbo/codeblock/blob/master/doc/api.md#lua-api)** — it is the reference, and it is generated from the mod's own source. This page stays general.

**License:** code AGPL-3.0-only, media CC BY-SA 4.0 — see [`THIRD-PARTY-LICENSES.md`](THIRD-PARTY-LICENSES.md)   
**Credits:** inspired by [Gnancraft](http://gnancraft.net/), [ComputerCraft](http://www.computercraft.info/), [Visual Bots](https://content.luanti.org/packages/Nigel/vbots/), [TurtleMiner](https://content.luanti.org/packages/BirgitLachner/turtleminer/), [basic_robot](https://github.com/ac-minetest/basic_robot)

![screenshot](https://raw.githubusercontent.com/gigaturbo/codecube/main/screenshot.png)

## The world

Codecube generates one world and it is the same every time: **flat, clean and
finite**. No caves, no ores, no biomes, no decorations, no night, and nothing
that changes on its own — every block you see after the ground was placed by a
program.

- **It is a tray you build in, 2048 nodes across by default.** Each edge carries
  a wall standing the full height of the world. The wall is translucent, so the
  edge reads as a limit you can see past rather than the inside of a box; it
  still stops you and it cannot be dug.
- **Underneath is a bedrock floor at `y = 0`, and nothing is generated below
  it.** You cannot fall out of the world: if a program removes a floor tile and
  you drop through it, you are put back into your own column, on the first free
  space in it, rather than sent to the spawn point.
- **The surface stands 128 nodes above that floor**, and the whole of it is
  stone. So the world is something to dig down into as well as to build up from,
  and you meet the floor only where a program has cleared a shaft to it.
- **The drone shares the same edge**, so it can never build where you cannot
  walk.

Codecube requires **Luanti 5.9 or newer**: the floor and the walls are written
on the engine's mapgen threads, and the call that does it does not exist before
5.9.

## Settings

A server owner can change both of the world's numbers from the main menu, under
**Content: Games → Codecube**, or in `minetest.conf`.

| Setting | Default | What it does |
|---|---|---|
| `mapgen_limit` | `1024` | Half the world's width. The walls stand at ±this on both horizontal axes, and it is the drone's bound too |
| `mgflat_ground_level` | `128` | How far the stone surface is above the bedrock floor. The floor itself stays at `y = 0` whatever this is |

Both are forced onto a world when it opens, so changing one re-bounds a world
you have already played — though only ground that has not been generated yet
comes in at the new size or the new height.

Every limit on what a program may spend — how long it runs, how many blocks it
writes, how much map it holds — is a CodeBlock setting and lives under
**Mods → codeblock**.

## Quick start

### Run your first program

1. Install the game and create a new world
2. Right click with ![drone_poser](https://raw.githubusercontent.com/gigaturbo/codeblock/master/doc/dp.png) tool on a block to place the drone, choose `stairs.lua` then left click with ![drone_poser](https://raw.githubusercontent.com/gigaturbo/codeblock/master/doc/dp.png) to start the drone

### Write your first program

1. Right click with ![drone_setter](https://raw.githubusercontent.com/gigaturbo/codeblock/master/doc/ds.png) tool to open the `lua` editor
2. Create a new file with the `new file` field and write some code on the main window
3. Click `load and exit` to load your code in the drone
4. Right click with ![drone_poser](https://raw.githubusercontent.com/gigaturbo/codeblock/master/doc/dp.png) tool on a block and run the code with a left click on ![drone_poser](https://raw.githubusercontent.com/gigaturbo/codeblock/master/doc/dp.png)
5. Read the [Lua API](https://github.com/gigaturbo/codeblock/blob/master/doc/api.md#lua-api) in `doc/api.md` to know which commands and blocks you can use

### Explore and tweak

- More built-in examples are available, just open the editor and choose an example to run
- User `codelevel` can be adjusted to tweak drone performance and capacities, see [permisisons](https://github.com/gigaturbo/codeblock/blob/master/doc/api.md#codelevel) and [chat commands](https://github.com/gigaturbo/codeblock/blob/master/doc/api.md#chat-commands)