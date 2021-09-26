# livesplit_asl_misc
Miscellaneous LiveSplit Scriptable Autosplitters. See the [master branch](https://github.com/bmn/livesplit_asl_misc) for more details.

# UnMetal (PC) LiveSplit Autosplitter

## Getting Started
* Download the autosplitter using the green `Code` button, and the `Download ZIP` link, in the top right of this page.
* Extract the zip contents to any location.
* In LiveSplit, add a `Control/Scriptable Auto Splitter` component to your layout, and open the component settings.
* In the SAS settings, browse to `UnMetal.asl`. The autosplitter settings should appear.

## Selecting Split Points
There are two main approaches to making a split list:
* Split at the end of each stage.
* Also split at key moments ("events") during the stage.
 
By default, the autosplitter does both, but chooses a sensible set of event splits instead of using all of them.

You can enable/disable specific event splits under the `Stage Events` category of the settings.

To disable events (i.e. to only split at the end of a stage), uncheck the `Stage Events` settings category.

## Pre-made Split Files
A collection of LSS split files for LiveSplit, designed for this autosplitter, are available.

See [Split Files](.Split%20Files) for more details.

## Custom Split Points
The Custom Splits feature lets you choose extra places to split, triggered when you reach particular room coordinates.

See [Custom Splits](./Custom%20Splits) for more details.

## ASL Var Viewer Support
The LiveSplit component [ASL Var Viewer](https://github.com/hawkerm/LiveSplit.ASLVarViewer) by hawkerm, allows you to add certain pieces of information about the run to your LiveSplit layout.

To get started:
* [Download ASL Var Viewer](https://github.com/hawkerm/LiveSplit.ASLVarViewer/releases/download/1.1/LiveSplit.ASLVarViewer.UI.zip) and extract it to your `LiveSplit/Components` directory.
* Restart LiveSplit if the component is newly-installed.
* Make sure you already have a Scriptable Auto Splitter, pointed at the UnMetal autosplitter, in LiveSplit.
* Add one or more `Information/ASL Var Viewer` components to your layout, and open the component settings.
* Select either `Current State` (data taken directly from the game) or `Variables` (data created by the autosplitter).
* Choose your desired variable from the dropdown menu.

The `Dead Time` variables provide a running timer of how much "dead time" (time spent unable to directly control Jesse) you've had. It can be useful for analysing different approaches to menuing, for example.
* `DeadTimeIngame` includes cutscenes, decision points, and time spent walking through doors.
* `DeadTimeInventory` includes time spent in the inventory/missions menu.
* `DeadTimeMenu` includes time spent in the pause menu.
* `DeadTime` is a single timer that includes all of the other timers, added together.
