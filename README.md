# Last Sign of Freedom: A Sci-Fi Saga of Identity and Consciousness

**Last Sign of Freedom** is a 2D story-driven sci-fi action-platformer that places players in the shoes of a genetically engineered human grappling with simulated memories and the struggle for true liberation. Blending fast-paced combat, environmental puzzles, and a branching narrative, the game explores themes of identity, free will, and what it truly means to be alive.

## 🎮 How to Play

**Last Sign of Freedom** is built with Godot 4 and can be played directly in your web browser or desktop!

### 🖥️ Desktop
1.  Download the game for Windows, macOS, or Linux from the [itch.io page](https://gamejolt.com/games/last-sign-of-freedom/1042196).
2.  Extract the downloaded zip file.
3.  Open the game folder and run the executable (e.g., `LastSignOfFreedom.exe`).

### 🌐 Browser
1.  Visit the [itch.io page](https://gamejolt.com/games/last-sign-of-freedom/1042196).
2.  Click the green **"Play"** button.
3.  Use your keyboard to control the character:
    *   **←/→** or **A/D**: Move
    *   **↑** or **W**: Jump
    *   **← + Space** or **↓ + Space**: Wall jump
    *   **Space**: Shoot

## 📖 Story Overview

You awaken as Subject 01, a clone who has lived multiple simulated lives within a high-tech facility. As your memories surface, you realize your entire existence may be a fabrication designed to serve the enigmatic Project Chimera. Joined by two AI companions, Echo and Cypher, you must fight through facility guards and robotic defenses to reach the truth at the heart of the complex. But as you get closer to the truth, you must make critical decisions that will shape your destiny and determine the fate of others caught in the experiment.

## 🌟 Key Features

-   **Branching Narrative**: Your choices matter! Difficult decisions will impact the story, characters, and ending.
-   **Fast-Paced Combat**: Wield energy weapons and execute stylish aerial maneuvers to defeat enemies.
-   **Environmental Puzzles**: Utilize gravity manipulation and your platforming skills to navigate complex levels.
-   **Multiple Endings**: Discover different outcomes based on your choices throughout the game.
-   **AI Companions**: Interact with Echo and Cypher, whose support and insights evolve with your decisions.
-   **Console-Quality Production**: Experience a fully voiced campaign with professional voice acting, detailed pixel art, and a dynamic soundtrack.

## 🛠️ Tech Stack

**Last Sign of Freedom** is built with:

-   **Game Engine**: [Godot 4](https://godotengine.org/) (GDScript)
-   **Programming Language**: GDScript
-   **Graphics**: Godot Engine 2D System
-   **Audio**: Custom sound effects and adaptive music system

## 🚀 Development

### Getting Started

#### Prerequisites
-   **Godot Engine 4.2** or higher
-   **Python 3.x** (optional, for build tools)

#### Installation
1.  Clone the repository:
    ```bash
    git clone https://github.com/username/Last-Sign-of-Freedom.git
    cd Last-Sign-of-Freedom
    ```
2.  Open the project in Godot Engine:
    -   Launch Godot
    -   Click "Import" and select the project folder
    -   Or use "Open" and navigate to the project folder
3.  Run the game:
    -   Press **F5** to run with debugger
    -   Press **Ctrl+R** or **Cmd+R** to run without debugger

#### Building for Desktop
Use the included build script to create native executables:

```bash
./build.sh
```

This will generate executables for Windows, macOS, and Linux in the `build/` directory.

### Project Structure

```
Last-Sign-of-Freedom/
├── assets/             # Game assets (images, audio, fonts)
│   ├── characters/     # Character sprites and animations
│   ├── enemies/        # Enemy assets
│   ├── environment/    # Level tiles and background elements
│   ├── ui/             # User interface elements
│   ├── audio/          # Sound effects and music
│   └── fonts/          # Fonts for UI and text
├── levels/             # Level design scenes
│   ├── prologue.tscn   # Introduction level
│   ├── corridor_01.tscn # Early game levels
│   ├── labs_01.tscn    # Laboratory environments
│   └── ...             # Complete level set
├── scripts/            # GDScript code
│   ├── player/         # Player controller and abilities
│   ├── enemies/        # Enemy AI and behavior
│   ├── game_management/ # Game state and scene management
│   ├── ui/             # UI logic
│   ├── programming/    # Core game systems
│   └── utils/          # Helper functions and utilities
├── shaders/            # Custom shader effects
├── cinematic/         # Pre-rendered cutscenes
├── build/              # Compiled game builds (generated)
└── build.sh            # Build script
```

### Key Scripts

-   `scripts/player/player.gd`: Main player controller with movement, shooting, and wall jump mechanics.
-   `scripts/player/player_abilities.gd`: Manages energy weapon usage and ability cooldowns.
-   `scripts/programming/game_manager.gd`: Singleton for global game state, level transitions, and cinematic handling.
-   `scripts/game_management/scene_loader.gd`: Handles loading and transitioning between game scenes with smooth fade effects.
-   `scripts/programming/decision_manager.gd`: Manages player choices and their impact on the narrative.

### Workflow

1.  **Design Level**: Create or modify level scenes in the `levels/` directory.
2.  **Implement AI**: Design enemy behavior in `scripts/enemies/`.
3.  **Add Features**: Create new abilities or systems in `scripts/programming/`.
4.  **Update UI**: Modify menus and HUD in `scripts/ui/`.
5.  **Test**: Use **F5** to play and debug.
6.  **Build**: Run `./build.sh` to create distributable versions.

## 🕹️ Controls Reference

### In-Game
-   **A/D** or **←/→**: Move
-   **Space**: Jump / Shoot
-   **↑**: Jump
-   **← + Space** or **↓ + Space**: Wall jump
-   **Esc**: Pause menu

### Build Script

```bash
# Build for all platforms
./build.sh

# Build only for Windows (if on Linux/macOS)
./build.sh windows

# Clean build artifacts
./build.sh clean
```

## 📝 Development Roadmap

### Phase 1: Core Gameplay (Completed)
-   [x] Player controller with movement and jumping
-   [x] Basic combat system with energy weapon
-   [x] Wall jump mechanics
-   [x] Level design and tilemap implementation
-   [x] Basic UI (health bar, pause menu)

### Phase 2: Narrative Integration (Completed)
-   [x] Decision-making system
-   [x] Branching dialogue and interactions
-   [x] Cinematics and cutscenes
-   [x] Multiple endings
-   [x] AI companion integration (Echo and Cypher)

### Phase 3: Polish & Expansion (Completed)
-   [x] Visual effects (screen shake, particles, impacts)
-   [x] Audio system (sound effects, music, voice acting)
-   [x] Accessibility options
-   [x] Localization support
-   [x] Performance optimization

## 📜 Credits

### Development Team
-   **Owner**: [Your Name/Organization](https://github.com/username)
-   **Game Engine**: [Godot Engine](https://godotengine.org/)

### Assets
-   **Graphics**: [Creator Name] (if applicable)
-   **Audio**: [Creator Name/Sound Library] (if applicable)
-   **Music**: [Composer Name] (if applicable)

### Special Thanks
-   The entire Godot
