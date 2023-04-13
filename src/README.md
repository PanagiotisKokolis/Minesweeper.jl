# Some Notes

## Components

1. **Input Handling**
   1. **Actions** - create abstract actions that can be associated with different inputs
   2. **Controls** - bind inputs from various devices to certain actions
   3. **Control Sets** - organize sets of bindings (inputs to actions) into different contexts (menus, inventories, etc); these can be placed on a stack

2. **Game Logic**
   1. **Complete Implementation** - fully implemented game logic
   2. **Difficulties** - easy, medium, hard
   3. **StateTransition** - menu and results state with transition logic via ESC key to play multiple rounds
   
3. **Rendering**
   1. **SDLTTS** - graphical rendering done using SDL2 and TTS


# TO DO
(3/20/2023)
[x] Handle mouse clicks in PlayState (left / right); reveal
[x] Render play state completely; mines, hints, flags
- Write functionality for checking win/lose states

(3/26/2023)
- Implement functionality for win/lose states still

(4/13/2023)
[x] Implement functionality for win/lose states
[x] Full playthrough
- bug testing
