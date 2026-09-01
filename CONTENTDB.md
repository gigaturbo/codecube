A world made for writing code. You program a drone in Lua, from an editor inside
the game, and watch it build what you wrote — a staircase, a spiral, a fractal,
a plot of a function you just made up.

The programming itself is the **CodeBlock** mod, which this game bundles: the
drone, the in-game editor, the Lua sandbox and the API. What the game adds is
somewhere worth building.

## What the game gives you

- **A flat, clean world.** No caves, no dungeons, no ores, no biomes, no
  decorations — nothing to clear before you start, and nothing to lose behind
  what you build.
- **Permanent daylight.** No sun, no moon, no stars, no clouds, no night. Your
  structure is lit the same at every hour and there is nothing to look away for.
- **Nothing to break.** No node is diggable, blocks never drop as items, the
  inventory is empty and knockback is off. Every block that appears was placed
  by a program, so the world always shows what your code did and nothing else.
- **Set up to be played, not configured.** Creative mode, damage off, and the
  server settings a drone wants, chosen so that a new world is ready the moment
  it opens.

## Getting started

1. Create a new world and enter it. You are given two tools: the **Drone
   placer** and the **Drone setter**.
2. **Right click a block with the Drone placer.** A list of programs appears —
   pick `stairs.lua`.
3. **Left click with the Drone placer.** The drone builds the staircase in front
   of you.

To change what it builds, **right click with the Drone setter** to open the
editor, open `stairs.lua`, change the number of stairs and click *Load and
close*. Then place a drone and left click again.

There are more examples than the staircase — spirals, fractals, 3D plots — and
opening one and changing a number is the fastest way to learn what the API does.
When you want your own, create a file in the editor and write it there.

## Worth knowing

- **Every player has a `codelevel`**, and it bounds what one program may spend of
  the server: how long it runs, how many blocks it writes, how much of the map it
  holds at once. If a program stops early, the chat says which limit it hit.
- **At codelevels 1 and 2 the drone builds slowly on purpose**, so a beginner can
  watch a loop happen. Levels 3 and 4 do not wait.
- A single player starts high enough not to wait. On a server, a new player
  starts lower and an administrator raises it.
- Every one of those limits is a setting, so the game runs on a public server and
  not only in singleplayer.

The commands, the block lists and what each `codelevel` allows are documented
with the CodeBlock mod, and the same reference is available in the editor beside
your code.

Inspired by Gnancraft, ComputerCraft, Visual Bots, TurtleMiner and basic_robot.
