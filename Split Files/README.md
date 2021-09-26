# UnMetal Split Files
These are pre-made LSS split files for LiveSplit that you can use and edit.

If you add or remove split points in the autosplitter settings or through the Custom Splits feature, or if you take a different route, you must reflect those changes in the split file or your live splits will go out of sync!

## Stages Only
* This split file contains a single split at the very end of each stage.
* In the Scriptable Auto Splitter settings, make sure the category `Split Events` is not enabled.

## Default Events
* These files have splits at the end of each stage, and also splits for key events during stages.
* No settings changes are needed.

### About Subsplits
In your LiveSplit layout, you have the option of a `Splits` or a `Subsplits` component, to display your list of splits.

Most of these split files are designed for the simpler Splits component, which just shows each split, one after another.

The split files with `(Subsplits)` in the name are designed for the Subsplits component.
* The list of splits is the same as in the corresponding non-Subsplits file.
* The split names contain extra code that lets LiveSplit organise the splits into "sections", one for each stage.
* The Subsplits component is highly flexible and customisable, but more complicated to get working well.
* These files do not work well with a regular Splits layout! You'll see lots of unwanted symbols and text.
