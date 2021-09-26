# Custom Splits Feature

The UnMetal autosplitter provides many pre-defined split points, usually at key events in each stage.

You may however, have a particular point in the game where you want to split, that isn't provided in the Stage Events.

You can do this with the Custom Splits feature. This uses a customised text file, where you list important locations in your route using their X and Y coordinates.

## Getting Started
* Create a new text file `UnMetal.Route.txt` in your LiveSplit install directory (or copy the [example file](UnMetal.Route.txt) here).
* In the Scriptable Auto Splitter settings, enable the setting `Custom Splits`.

## Using Alternative Route Files
If you run different categories, your custom splits may be different between categories.

You can create up to 3 extra route files, and select which one you want to use in the settings:
* Create `UnMetal.Route.A.txt` for route ALPHA, `UnMetal.Route.B.txt` for route BRAVO, or `UnMetal.Route.C.txt` for route CHARLIE.
* In the Scriptable Auto Splitter settings, enable the setting under `Custom Splits` for the route you want to use, and make sure the other two routes are disabled.
* If no routes are selected, the base route file (see Getting Started) will be used.

## Coding Your Route File
Each line in a route file contains an instruction.

Each stage has its own route, so let's start by declaring the start of the Stage 1 route:

`Stage 1`

From here, each line defines a particular area in the stage. Each area has its own X and Y coordinate - for example, here's Stage 1:

![Coordinates for areas in Stage 1](Stage%201%20Map.png)

### Simple example: First time entering an area
Let's say we want to split at the start of the RNG-heavy area with the guards telling jokes. That's area `1,1`.

To tell the autosplitter to split, we add an exclamation mark at the end:

`1,1!`

This will now split the first time we enter that area.

### Adding more detail: Areas as pre-requisites for a split
In Stage 2...

`Stage 2`

...we have a somewhat difficult sequence break skipping the Raw Meat. Maybe we want to split after getting past the dog the first time:

`4,8!`

and also split after getting past the second time:

`2,8!`

The autosplitter treats each line as a part of the route that you have to go through in order. So the second split (at `2,8`) won't happen, until you've already been in `4,8`.

But let's say that we want to make sure we've given Robert the radio, before we do that second split.

We can do this adding a pre-requisite area beforehand - for example, the supplies room with the encryption circuit (`3,9`).

```
3,9
2,8!
```

By not adding the exclamation point, we say that this is a required part of the route, but that we don't want to split there.

So, in total, we can define these two "raw meat skip" splits, with:

```
4,8!
3,9
2,8!
```

You may also need to use pre-requisite areas in other situations - say, if you want to split somewhere, but it's not the first time you've been there.
