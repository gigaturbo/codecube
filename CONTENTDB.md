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
- **A world with edges you can see.** It is a finite tray, 2048 nodes across by
  default, with a wall standing the full height of the world at each edge. The
  wall is translucent, so the limit is something you can see past rather than
  the inside of a box. It still stops you, and it cannot be dug. The drone is
  bounded by the same edge, so it can never build where you cannot walk.
- **A floor you cannot fall through.** Under the world is bedrock at `y = 0`
  with nothing generated below it, and the surface stands 128 nodes above that —
  solid stone the whole way down, so the world is something to dig into as well
  as to build on. If a program removes a floor tile and you drop through it, you
  are put back into your own column on the first free space in it, rather than
  sent to the spawn point. Both numbers are settings a server owner can change,
  under Content: Games → Codecube: `mapgen_limit` is half the world's width, and
  `mgflat_ground_level` is how far the surface stands above the floor.
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

## Recent changes

**v1.0.0 needs Luanti 5.9 or newer**, and it breaks saved programs and changes
worlds you have already played in.

- The world is now a finite tray, 2048 nodes across, with a translucent wall at
  each edge and a bedrock floor 128 nodes beneath the surface. You cannot fall
  out of it. An existing world is re-bounded when you open it, but only ground
  that has not been generated yet gets a wall or the new surface height, so an
  old world has a step where the two meet.
- The drone's limits were rewritten around what a program costs the server —
  running time, blocks written, map held — instead of counts of calls. Nothing
  bounds a shape's size or how far the drone may fly from home any more.
- The two lowest codelevels now pace the drone so a beginner can watch a loop
  happen. On a server, a new player starts at codelevel 2 rather than 4.
- Every drone limit and both of the world's numbers are settings.
- The world no longer changes on its own: no grass spreading over what you
  built, no saplings growing through it.
- Fixed the crack animation on blocks that cannot be broken, the sun showing at
  dawn and dusk, and a bookshelf that let you drag your own tools out of reach.

Inspired by Gnancraft, ComputerCraft, Visual Bots, TurtleMiner and basic_robot.
