# Architecture

## Codebase Structure

```
N-E-S-game/
│
├── main.lua              # love.load / love.update / love.draw / input callbacks
│                         # Wires hump.gamestate; owns virtual canvas scaling
│
├── game.lua              # Shared context module: game.font, game.audio.*
│                         # Populated in love.load(); required by states for audio/font
│
├── conf.lua              # LÖVE window config (title, size, resizable)
├── constants.lua         # VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT
├── config.lua            # baton input instance + metadata (icons/labels for options UI)
│
├── states/
│   ├── title.lua         # Title screen: 3 buttons (Play / Options / Quit), L/R navigation
│   ├── options.lua       # Control rebinding: 6 actions + back, keyboard + gamepad
│   ├── intro.lua         # Intro room: lying-down anim → free movement → TV interaction
│   └── forest.lua        # Forest level: spawns Wendy at map spawn point
│
├── entities/
│   ├── entity.lua        # Base class (classic): move(), addToWorld(), draw()
│   ├── player.lua        # Extends Entity: 8 directional sprite anims, input-driven
│   └── wendy.lua         # Extends Entity: single spritesheet, 8 directional anims
│
├── assets/
│   ├── audio/
│   │   ├── music/        # intro.ogg (BGM)
│   │   └── sfx/          # select.wav, nav.ogg
│   ├── fonts/            # RasterForgeRegular (UI font)
│   ├── sprites/
│   │   └── characters/
│   │       ├── player/   # Separate PNGs per animation (idle_*, run_*, lying_down)
│   │       └── wendy/    # Single spritesheet (wendy.png, 64×112, 4 cols × 7 rows)
│   ├── ui/
│   │   ├── hud/          # action_prompt.png (interact prompt sprite)
│   │   ├── icons/        # dpad_*.png (used in options menu)
│   │   └── menu/         # play_btn, gear_btn, eject_btn, btn_rewind
│   └── worlds/
│       ├── intro_room/   # intro_room.tmx + intro_room.lua (Tiled export)
│       └── forest_glitch/# forest.tmx + forest.lua (Tiled export)
│
└── lib/
    ├── anim8.lua         # Sprite animation (grid slicing, frame sequencing)
    ├── baton.lua         # Input abstraction (keyboard + gamepad, analog deadzone)
    ├── bump.lua          # AABB collision (spatial hash world)
    ├── classic.lua       # Minimal OOP base class
    ├── lume.lua          # Lua utility belt
    ├── hump/
    │   └── gamestate.lua # State machine (switch/push/pop + lifecycle callbacks)
    ├── moonshine/        # Post-processing effects (vendored, not yet wired)
    └── sti/              # Tiled map loader (bump plugin used for collision layer)
```

### State Flow

```
love.load()
    └── Gamestate.switch(Title)

Title ──(Play)──► Intro ──(interact TV)──► Forest
      ──(Gear)──► Options ──(back)──────► Title
      ──(Eject)─► love.event.quit()
```

### Key Contracts

| Concern                            | Owner                                                               |
| ---------------------------------- | ------------------------------------------------------------------- |
| Virtual canvas + letterbox scaling | `main.lua`                                                          |
| Audio sources + font               | `game.lua` (populated in `love.load`)                               |
| Input polling (`input:update()`)   | Each state's `:update(dt)`                                          |
| Collision world lifecycle          | Each state's `:enter()` creates a fresh `bump.newWorld`             |
| Map object lookup                  | Local `findObject(layer, propType)` in `intro.lua` and `forest.lua` |
| Sprite animation                   | `anim8` via `Entity` subclasses                                     |
| Control rebinding                  | `options.lua` mutates `input.config.controls[actionId]` directly    |
