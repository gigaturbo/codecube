Write a program in Lua and watch your drone build it! Codecube gives you a code editor
inside Luanti and a flat empty world as a playground: learn to code or give your inner computer artist somewhere to play!

## Features

- **A flat clean world.** No caves, no ores, no biomes, no decorations, only what you build.
- **An editor in the game.** A per-player program list with create/edit/save functions. Helpers beside the code for when you forget a command or a block name.
- **A large API with real Lua.** Shapes, maths and conveniences: cubes, spheres, domes and cylinders, a random colour, named checkpoints the drone can return to, loops, functions and recursion. Everything is in a sandbox
  so the server cannot be hurt.
- **Example programs to discover.** Spirals, fractals, 3D plots and other more artistic examples. Open one and change a number to see what happens.
- **A control panel.** Every limit with what your program has spent beside it, and pause, resume and stop controls on the drone.
- **Custom blocks.** Thousands of colours, chosen by name, hex or RGB, and thirty-five named colours as bricks, glass and lamps.
- **World limits.** A see-through wall around the world and a bedrock floor with fall protection.
- **Always day.** No day-night cycle and a clean uniform sky.
- **Programming only.** Digging and inventory are disabled: every new block in the world was put there by a program.
- **Per-player limits.** Tunable by administrators so the game is usable on a public server.

## Quick start

1. Create a world and enter it. Run `/codeblock tools` to be given the **Drone placer** and the **Drone setter** items.
2. **Right click a block with the Drone placer.** A list of programs appears, pick `stairs.lua`.
3. **Left click with the Drone placer.** The drone builds the staircase in front of you.

To change what it builds:

4. **Right click with the Drone setter** to open the editor. Open `stairs.lua`, change the number of stairs, click *Load and close*.
5. Place a drone and left click again.

Experiment and discover with the other examples, or write your own!

## Important notes

- **Every player has a `codelevel`**, and it bounds what one program may spend of the server. If a program stops early, that is usually why, and the chat says which limit it hit.
- **At codelevels 1 and 2 the drone builds slowly on purpose**, so a beginner can watch a loop happen. Levels 3 and 4 do not wait. A single player starts at 3; on a server a new player starts at 2 and an administrator raises it.
- **One setting sizes the world, and it bounds every axis.** By default the wall stands ~4000 nodes in every direction.

## Recent changes

**This release breaks some saved programs.** A colour name now builds the nearest of 3930 colours, and a block name that does not exist stops the program on its line.

- 3930 colours, chosen by name, hex or RGB, and the 35 named colours as bricks beside glass and lamps. Old solid blocks in a world turn into the nearest colour as their area loads.
- `/codecube newplace` moves you to a fresh place to build.
- `/codecube saveme` gets you out when a build has walled you in.
- `/codecube spreadplayers` sends a class to plots of their own, never handed out twice.
- `/codecube speed` lets an admin set how fast a player moves. Everyone moves faster by default.
- A player who falls out of the world lands on a build nearby.
- Drones build several times faster and no longer stall the server.
- The bundled **CodeBlock** mod is adopted at its 2.0.0 release.

The drone, the editor, the sandbox and the API are the **CodeBlock** mod, which this game bundles. Install that on its own if you want them in a world of your own making.

Inspired by Gnancraft, ComputerCraft, Visual Bots, TurtleMiner and basic_robot.
