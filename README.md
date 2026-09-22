Codecube
=========================

[![CI](https://github.com/gigaturbo/codecube/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/gigaturbo/codecube/actions/workflows/ci.yml)
![License](https://img.shields.io/badge/code-AGPL--3.0--only-blue.svg)
![Media license](https://img.shields.io/badge/media-CC%20BY--SA%204.0-blue.svg)
[![ContentDB](https://content.luanti.org/packages/giga-turbo/codecube/shields/downloads/)](https://content.luanti.org/packages/giga-turbo/codecube/)

**Write `lua` code in Luanti and watch a drone build whatever you imagine**

Codecube is a Luanti game built around one idea: everything you see was placed by a program. The programming itself is the [CodeBlock](https://content.luanti.org/packages/giga-turbo/codeblock/) mod, which the game bundles — a drone, an editor inside the game, a sandbox and a large API. What the game adds is somewhere worth building: a flat clean world with nothing to clear, bounded by a wall you can see through and a floor you cannot fall past, held at permanent noon, where nothing is breakable and the settings a drone wants are already set. Every panel and the hotbar are drawn in the game's own colours too, so the interface and the world read as one thing. It needs **Luanti 5.9 or newer**, because the floor and the wall are written on the engine's mapgen threads. The Lua and block reference is CodeBlock's, at [`doc/api.md`](https://github.com/gigaturbo/codeblock/blob/master/doc/api.md#lua-api).

**License:** code AGPL-3.0-only, media CC BY-SA 4.0 — see [`THIRD-PARTY-LICENSES.md`](THIRD-PARTY-LICENSES.md)   
**Credits:** inspired by [Gnancraft](http://gnancraft.net/), [ComputerCraft](http://www.computercraft.info/), [Visual Bots](https://content.luanti.org/packages/Nigel/vbots/), [TurtleMiner](https://content.luanti.org/packages/BirgitLachner/turtleminer/), [basic_robot](https://github.com/ac-minetest/basic_robot)

![screenshot](https://raw.githubusercontent.com/gigaturbo/codecube/main/screenshot.png)

## Quick start

### Run your first program

1. Install the game from [ContentDB](https://content.luanti.org/packages/giga-turbo/codecube/) and create a world — there is nothing to configure and no mod to enable
2. Run the `/codeblock tools` command to be given the two drone tools
3. Right click with ![drone_placer](https://raw.githubusercontent.com/gigaturbo/codeblock/master/doc/drone_poser.png) tool on a block to place the drone, choose `stairs.lua` then left click with ![drone_placer](https://raw.githubusercontent.com/gigaturbo/codeblock/master/doc/drone_poser.png) to start the drone

### Write your first program

1. Right click with ![drone_setter](https://raw.githubusercontent.com/gigaturbo/codeblock/master/doc/drone_setter.png) tool to open the `lua` editor
2. Type a name in the `New file:` field and click `+` beside it, then write some code in the main window
3. Click `Load and close` to load your code in the drone
4. Right click with ![drone_placer](https://raw.githubusercontent.com/gigaturbo/codeblock/master/doc/drone_poser.png) tool on a block and run the code with a left click on ![drone_placer](https://raw.githubusercontent.com/gigaturbo/codeblock/master/doc/drone_poser.png)
5. Read the [Lua API](https://github.com/gigaturbo/codeblock/blob/master/doc/api.md#lua-api) to know which commands and blocks you can use

### Explore and tweak

- More built-in examples are available, just open the editor and choose an example to run
- The world's size is one setting, `mapgen_limit`, under **Content: Games → Codecube** in the main menu. It bounds every axis, so raising it gives you a wider world *and* a higher ceiling; at the default of 4096 the wall stands at -4032 and 4047, a field 8080 nodes on a side rather than 8192, because only whole mapchunks inside the limit are generated
- User `codelevel` can be adjusted to tweak drone performance and capacities, see [permissions](https://github.com/gigaturbo/codeblock/blob/master/doc/api.md#codelevel) and [chat commands](https://github.com/gigaturbo/codeblock/blob/master/doc/api.md#chat-commands)
