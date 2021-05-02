# MasterSuite 5E
This is a suite of extensions created for Fantasy Grounds Unity's 5E ruleset, combining the extensions that I use the most in my games - as well as the games that friends who GM run in our shared Discord server.

The goal was, and still is, to combine these extensions in a seamless way that allowed them to work with each other, as well as ensuring quick debugging and fixing when my players/GMs experience issues.

The following extensions have been included and/or altered with permission from their authors. Full credit of the original extension goes to them and their contributors. See [link](#Credits--Attributions)

## My Own Creations
MasterSuite5E makes a number of changes to included extensions and eventually will become their own thing - if development calls for it. These changes are done as more of an extension of the ruleset rather than "options" provided to other GMs. Why? Because this extension is tailor-made and developed for my own games and those that are run by my friends in our Discord server. We have a close-knit player group, and play in each other's campaigns, so the needs of the extension doesn't vary between us. We all share the same house rule preferences and FG options settings.

## Features
For a full list of features and the intricate uses of them, please refer to the usage guide.

## Credits & Attributions
* **Advanced Effects** by celestian
* **Improved Criticals** by TheoGeek
* **Attunement Tracker** by dmssanctum
* **Height Indicator** originally part of 5E Enhancer by Stymir
	* Currently other version of this extension exists, GKEnialb's is the one that is closest to this project. As a result, I will share some back-and-forth with them if and when I resolve issues and I will include the problems they solve in this extension.

## Changelog
### v2.0.2 - 02-May-2021
* [ADDED] Offsets to height calculations to take into account the physical height of the token in the simulated 3D environment
  * This means that hovering 10ft above the ground next to a Large (10x10x10 ft.) creature still puts the range calculations at 5ft
	* Ensured that when drawing a pointer (free-hand ruler) it does not trigger height calculations and throw an error

### v2.0.1 - 26-Apr-2021
#### HeightManager
* [FIXED] Height now calculating on NPCs larger than "Medium" size, incorporating GKEnialb's work alongside MasterSuite
* [NEW] Leveraging FGU's new `getDistanceBetween` functions

### v2.0.0 - 12-Apr-2021
#### General
* [NEW] Major rewrite of the entire extension
* [NEW] Reworked "override" scripts to reference and call base FG API, rather than re-writing unnecessarily
* [NEW] Beginning of compatibility features with other extensions
#### AdvancedEffects
* [CHANGED] Rewrite of override codes to only rewrite when necessary
#### AttunementTracker
* [FIXED] Bug causing attunement count to overlap with the 'add' button on the Equipment heading
* [REMOVED] Option to set attunement slots equal to proficiency bonus - my games stick to the base of 3
* [ADDED] Attunement slots for Artificers, increasing their total slots by 1 at 10th, 14th, and 18th level
* [ADDED] Attunement editor window on Inventory page for custom control of slots
* [ADDED] Items that do not require attunement no longer show the chekcbox
* [CHANGED] Rewrote the extension with dmssanctum to the current version
#### HeightManager
* [FIXED] Errors with previous iteration of the feature, caused by latest FGU update
* [ADDED] ALT + Scroll to change token height, and player control of their own token height
* [TODO] Add height field in "Size and Space" section of CT for host
#### HeroPoints
* [REMOVED] Functionality of the script no longer needed - removed as we move into 2.0
#### ImprovedCriticals
* [FIXED] Ensure ImpCrit rolls comply with FGU's new method of handling rolls
* [REMOVED] All options and roll variants to only have "maximize critical dice" as per the Discord agreed upon house rule
* [REMOVED] TheoGeek's icon (licensed) image as per TG's request
#### Parcels
* [ADDED] Ability to identify items directly within the parcel sheet
	* This is for use with Map Parcels (compatible) by SilentRuin
#### Party Sheet
* [ADDED] Ability to identify items directly within the inventory page