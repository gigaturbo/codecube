Write a program in Lua and watch a drone build it. Codecube gives you an editor
inside the game and a world made of nothing but what your code puts there: learn
to code, or give your inner computer artist somewhere to play.

## Features

- **A world with nothing in it.** Flat and clean, no caves, no ores, no biomes,
  no decorations — nothing to clear before you start, and nothing to lose behind
  what you build.
- **Edges you can see.** A see-through wall stands around the world and a bedrock
  floor under it, so you always know where you are and you cannot fall out. The
  drone shares the same edge, so it never builds where you cannot walk.
- **Permanent noon.** No night, no sun, no moon, no clouds, and one flat colour
  of sky, so what you build is lit the same at every hour.
- **Nothing breakable.** You cannot dig, nothing drops and the inventory will not
  open — every block in the world was put there by a program and nothing else.
- **Its own blocks.** Thirty-five named colours, each as a solid block, a glass
  and a lamp: a hundred and five in all, and the only blocks a program places.
- **An editor in the game.** A per-player program list, create, edit and save,
  and helpers beside the code for when you forget a command or a block name.
- **A large API.** Shapes, maths and conveniences: cubes, spheres, domes and
  cylinders, a random colour, and named checkpoints the drone can return to.
- **Real Lua.** Loops, functions, recursion and maths, everything in a sandbox
  that cannot harm the server.
- **Example programs to discover.** Spirals, fractals, 3D plots and other more
  artistic examples. Open one and change a number to see what happens.
- **A control panel.** Every limit with what your program has spent beside it,
  and pause, resume and stop controls on the drone.
- **Per-player limits** an administrator can tune, so the game is usable on a
  public server and not only in singleplayer.
- **Ready the moment it opens.** Creative mode, damage off, the world's own
  numbers and the look of every panel are all chosen for you, so a new world
  needs nothing configured.

## Quick start

1. Create a world and enter it. Run `/codeblock tools` to be given the **Drone
   placer** and the **Drone setter**.
2. **Right click a block with the Drone placer.** A list of programs appears,
   pick `stairs.lua`.
3. **Left click with the Drone placer.** The drone builds the staircase in front
   of you.

To change what it builds:

4. **Right click with the Drone setter** to open the editor. Open `stairs.lua`,
   change the number of stairs, click *Load and close*.
5. Place a drone and left click again.

Experiment and discover with the other examples, or write your own!

## Important notes

- **Every player has a `codelevel`**, and it bounds what one program may spend of
  the server: how long it runs, how many blocks it writes, how much of the map it
  holds at once. If a program stops early, that is usually why, and the chat says
  which limit it hit.
- **At codelevels 1 and 2 the drone builds slowly on purpose**, so a beginner can
  watch a loop happen. Levels 3 and 4 do not wait. A single player starts at 3;
  on a server a new player starts at 2 and an administrator raises it.
- **One setting sizes the world, and it bounds every axis.** By default the wall
  stands about four thousand nodes out in every direction — a field 8080 nodes on
  a side — and the ceiling is just as far up. Raise it and you get both, a wider
  world and a higher one.
- **A world you played before this release only changes where it has not been
  generated.** The new edge applies at once, but the wall, the floor and the
  deeper ground are written as the world generates, so where you have already
  walked the ground simply stops as it did before.

## Recent changes

**This release needs Luanti 5.9 or newer**, and it breaks saved programs and
changes worlds you have already played in.

- The world is now bounded and much bigger: a see-through wall all the way round
  it, a bedrock floor underneath, and 128 nodes of ground between you and that
  floor where there used to be 8. It is about 8080 nodes on a side, roughly twice
  what it was. You cannot fall out of it any more, and if a program digs the floor
  from under you, you are put back on the spot rather than sent to spawn.
- The blocks a program places are the **CodeBlock** mod's own — 35 colours in
  solid, glass and lamp — so the game no longer bundles Minetest Game's `default`,
  `wool` and `dye`. A program naming an old block places nothing. The ground is
  the game's own too: grass over dirt.
- Some API names are gone with no replacement, so a saved program using one stops
  on that line: the whole `table` namespace, `random.block`, `random.plant`,
  `random.wool`, `table.randomizer` and the per-category colour ramps.
- The drone's limits were rewritten around what a program costs the server —
  running time, blocks written, map held — instead of counts of calls. Nothing
  bounds a shape's size or how far the drone may fly from home any more.
- The two lowest codelevels now pace the drone so a beginner can watch a loop
  happen. A single player starts at codelevel 3 and a new player on a server at 2,
  where everyone used to start at 4.
- Every drone limit and both of the world's numbers are settings.
- The world no longer changes on its own: no grass spreading over what you built,
  no saplings growing through it.
- Fixed the crack animation on blocks that cannot be broken, the sun showing at
  dawn and dusk, and a bookshelf that let you drag your own tools out of reach.

The drone, the editor, the sandbox and the API are the **CodeBlock** mod, which
this game bundles. Install that on its own if you want them in a world of your
own making.

Inspired by Gnancraft, ComputerCraft, Visual Bots, TurtleMiner and basic_robot.
