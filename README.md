❗ Note: This is by no means complete ❗

# Quick Staff for QB-Core

Quickly toggle in and out of "staff mode". For use with the QB-Core Framework.

Stores your current state when entering staff mode, puts you into your staff outfit, enables some staff options, and then returns you to your regular player upon exiting staff mode.

https://github.com/maej20/mj-quickstaff

## Customization

`./mj-quickstaff/config.lua`

- **_ToggleCommand_** - Sets the command used to toggle staff mode on/off. (default = "staff")
- **_AutoGodMode_** - Turns on godmode while in staff mode. (default = true)
- **_AutoPlayerIds_** - Automatically show Player ID's over player's head while in staff mode. (default = true)
- **_ReturnToLastLocation_** - Returns staff players to their previous location upon exiting staff mode. (default = true)

## Prerequisites

**You must have**

- A saved outfit called _staff_ (this will be the outfit you change into upon entering staff mode).
- At least one other outfit saved to default back to.

## Installation

- **YouTube Tutorial**: [PENDING]

- **Clone or extract** this repository into your `resources` directory.

- **Edit** _./qb-houses/client/main.lua:564_

  - Remove `local` from before the `enterOwnedHouse()` function.

- **Edit** _./qb-houses/fxmanifest.lua_
  - **Add** this to the _end of the file._
  ```lua
  exports { "enterOwnedHouse" }
  ```
- **Add** `ensure mj-quickstaff` into your _server.cfg_ **_after the QB-Core resources_**.

### TODO

- Add ability for players to configure settings independently

## Changelog
