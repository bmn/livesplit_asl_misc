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

See [Split Files](./Split%20Files) for more details.

## Custom Split Points
The Custom Splits feature lets you choose extra places to split, triggered when you reach particular room coordinates.

See [Custom Splits](./Custom%20Splits) for more details.

## Game Time Support
This autosplitter supports LiveSplit's Game Time feature, allowing it to use the game's official speedrun timer (accessible in-game using the `SPEEDRUN` cheat code).

To switch to Game Time, right click on the LiveSplit window and select `Compare Against/Game Time`.

## ASL Var Viewer Support
The LiveSplit component [ASL Var Viewer](https://github.com/hawkerm/LiveSplit.ASLVarViewer) by hawkerm, allows you to add certain pieces of information about the run to your LiveSplit layout.

To get started:
* [Download ASL Var Viewer](https://github.com/hawkerm/LiveSplit.ASLVarViewer/releases/download/1.1/LiveSplit.ASLVarViewer.UI.zip) and extract it to your `LiveSplit/Components` directory.
* Restart LiveSplit if the component is newly-installed.
* Make sure you already have a Scriptable Auto Splitter, pointed at the UnMetal autosplitter, in LiveSplit.
* Add one or more `Information/ASL Var Viewer` components to your layout, and open the component settings.
* Select either `Current State` (data taken directly from the game - often unsuitable for use) or `Variables` (more friendly data created by the autosplitter).
* Choose your desired variable from the dropdown menu.

### Current State variables
| Variable name           | Useful?          | Note                                                                                             |
|-------------------------|------------------|--------------------------------------------------------------------------------------------------|
| PlayerLevel             | Not really       | Jesse's Level. Is 1 lower than shown in-game.                                                    |
| RoomX                   | Maybe            | The horizontal grid-coordinate of the current area.<br>May be useful for making custom split files. |
| RoomY                   | Maybe            | The vertical grid-cooordinate of the current area.                                               |
| TimerActive             | Not really       | TRUE if the game timer is running.                                                               |
| Attempts                | Maybe            | The number of times a stage has been started since the game launched.                            |
| Stage                   | Not really       | The current stage number.<br>Is 1 lower than shown in-game.                                         |
| GameTime                | Not really       | The current game time, in floating-point seconds.<br>Your LiveSplit timer does this already.        |
| CurrentStageTime        | Maybe            | The current stage's game time, in floating-point seconds.                                        |
| GameState               | Doubt it         | A number representing whether the game is paused or in a menu.                                   |
| InCutscene              | Doubt it         | TRUE if the game is currently in a cutscene.                                                     |
| IronmanEnabled          | Better elsewhere | TRUE if Ironman is active. Also provided as part of `vars.DifficultyLevel`.                      |
| DifficultyLevel         | Better elsewhere | 0 for Easy, 1 for Normal, 2 for Hard. See `vars.DifficultyLevel`.                                |
| PlayerLevelExp          | Better elsewhere | Exp collected since Jesse's last level up. See `vars.PlayerLevelExp`.                            |
| PlayerLevelMaxExp       | Better elsewhere | Total Exp required to level up from Jesse's current level. See `vars.PlayerLevelExp`.            |
| CurrentStageExp         | Better elsewhere | Exp collected in the current stage. See `vars.CurrentStageExp`.                                  |
| CurrentStageMaxExp      | Better elsewhere | Total Exp in the current stage. See `vars.CurrentStageExp`.                                      |
| CurrentStageSecrets     | Better elsewhere | Secrets collected in the current stage. See `vars.CurrentStageSecrets`.                          |
| CurrentStageMaxSecrets  | Better elsewhere | Total Secrets in the current stage. See `vars.CurrentStageSecrets`.                              |
| UnperfectObjectiveCount | Nop              | Number of objectives required for UnPerfect in the current stage.                                |

### Variables variables
| Variable name                                | Useful?           | Note                                                                                                                                                                                                                                                                    |
|----------------------------------------------|-------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| DeadTime                                     | Maybe             | A running timer of "dead time" (time spent unable to directly control Jesse) in the current stage.<br> It can be useful for analysing different approaches to menuing, for example.                                                                                         |
| DeadTimeIngame                               | Maybe             | `DeadTime`, but only for cutscenes, decision points, and time spent walking through doors.                                                                                                                                                                              |
| DeadTimeInventory                            | Maybe             | `DeadTime`, but only for time spent in the inventory/missions menu.                                                                                                                                                                                                     |
| DeadTimeMenu                                 | Maybe             | `DeadTime`, but only for time spent in the pause menu.                                                                                                                                                                                                                  |
| DifficultyLevel                              | Yes               | The current difficulty level (e.g. "Easy"), and Ironman if it is active.                                                                                                                                                                                                |
| CurrentStageExp                              | Perhaps           | The currently collected and max Exp for the current stage (e.g. "4/20"). See `Summary_CurrentStatus`.                                                                                                                                                                   |
| CurrentStageSecrets                          | Perhaps           | The currently collected and max Secrets for the current stage (e.g. "4/20"). See `Summary_CurrentStatus`.                                                                                                                                                               |
| PlayerLevelExp                               | Perhaps           | The currently collected and required Exp in Jesse's current Level (e.g. "4/20"). See `Summary_CurrentStatus`.                                                                                                                                                           |
| Summary_CurrentStatus                        | Yes               | A well-formatted line containing Jesse's current Level, `PlayerLevelExp`, `CurrentStageExp`, and `CurrentStageSecrets`.                                                                                                                                                 |
| Summary_UnPerfect                            | Yes               | A single variable that contains ✔ (good) or ❌ (bad) icons for all of the current stage's UnPerfect objectives.<br>It also shows the description for each objective, toggling between them every 5 seconds.                                                                 |
| Summary_UnPerfect1, Summary_UnPerfect2, etc. | If you have space | Six variables. Each contains a description one of the current stage's UnPerfect objectives, as well as whether it's in a good ✔ or bad ❌ state.<br>If the current stage has less than six objectives, the remaining variables will be empty. |
