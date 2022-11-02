# LocLogger
Player coordinate logging for World of Warcraft. This addon was created to aid in development of [Questie](https://github.com/Questie/Questie), specifically to help generate NPC waypoint paths.

## Instructions
Install as you would any other addon.

1. Start logging with `/loc start`
2. Stop logging with `/loc stop`
3. Each log session can be viewed/copied with `/loc output`

### Settings Explanation
**/loc interval** sets the frequency in seconds that the player's position is recorded. default is `1` second

**/loc precision** sets the precision with which the player's position is recorded. default is `2` decimal places (ex. 34.67,49.63)

**/loc cull** toggles coordinate culling, which ignores duplicate successive entries. default is `enabled`