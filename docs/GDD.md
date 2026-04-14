# 🎮 Game Design Document (GDD)

## 📌 Project Name

**(To be defined)**
Codename: *Gravity Rooms*

---

## 🧠 Overview

**Gravity Rooms** is a 2D puzzle-platformer where players manipulate **gravity** to escape a series of interconnected rooms within a mysterious medieval castle.

Each room is a self-contained challenge that requires the player to rethink space, positioning, and movement.

The game emphasizes:

* Clear and responsive gameplay
* Learning through interaction (no intrusive tutorials)
* Skill progression through mechanic mastery

---

## 🎯 Player Objective

* Navigate through rooms
* Collect keys or activate mechanisms
* Reach the exit door

---

## 🎮 Core Mechanic

### 🔄 Gravity Inversion

The player can invert gravity at will.

**Gameplay impact:**

* Transforms floors into ceilings instantly
* Redefines navigation and spatial reasoning
* Enables creative puzzle-solving

---

## 🧩 Secondary Mechanics

* Horizontal movement
* Jump
* Static platforms (stone, wood)
* Moving platforms (chains, lifts, mechanisms)
* Hazard zones (spikes, molten metal, traps)
* Special surfaces (ice)
* Magical zones with altered physics

---

## 🧱 Level Structure

The game contains **30 rooms**, divided into:

* 🟢 Easy (01–10) → Learning
* 🟡 Normal (11–20) → Combination
* 🔴 Hard (21–30) → Mastery

Each room follows the naming convention:

```txt
level_<NN>_<biome>_<difficulty>
```

Example:

```txt
level_01_castle_dungeons_easy
```

---

## 🌍 Biomes

Each biome introduces or evolves gameplay mechanics while maintaining a cohesive medieval fantasy theme.

| Biome            | Purpose                                  |
| ---------------- | ---------------------------------------- |
| castle_dungeons  | Core mechanics introduction (tutorial)   |
| ancient_ruins    | Spatial awareness and hazards            |
| crystal_mines    | Visual guidance and verticality          |
| molten_forge     | Timing and pressure                      |
| royal_towers     | Gravity mastery and vertical traversal   |
| enchanted_forest | Exploration and navigation               |
| frozen_keep      | Precision and movement control           |
| abandoned_castle | Altered physics through magical elements |
| shadow_catacombs | Memory and perception challenges         |
| king_core        | Final challenge combining all mechanics  |

---

## 📈 Design Progression

### Core Principles:

1. Introduce **one mechanic at a time**
2. Teach through gameplay, not text
3. Reuse mechanics with variation
4. Increase difficulty through combination, not speed

---

## 🕹️ Gameplay Loop

1. Player enters a room
2. Observes the environment
3. Experiments with gravity
4. Solves the puzzle
5. Reaches the exit
6. Progresses to the next room

---

## 🎨 Art Direction

* Style: medieval cartoon (inspired by Kings and Pigs assets)
* Bright colors and readable silhouettes
* Strong contrast between interactive elements
* Visual clarity prioritized over detail

**Design goal:**
Gameplay readability always comes before visual complexity.

---

## 🔊 Audio

* Feedback sounds (jump, gravity switch, interactions)
* Environmental ambience per biome
* Light, thematic medieval background music

---

## 🧪 Playtesting

Each room should be validated based on:

* Completion time (30–90 seconds)
* Clarity of objective
* Player error rate
* Points of confusion

---

## 📊 Production

**Tools:**

* Engine: Godot
* Version Control: Git
* Documentation: /docs

---

## 📅 Scope

Estimated timeline:

* 3 to 6 months

Development strategy:

* Build one biome at a time
* Fully polish before moving forward
* Prioritize gameplay over visuals

---

## 🚀 Unique Selling Points

* Strong core mechanic (gravity inversion)
* Compact, puzzle-focused rooms
* Clear and satisfying learning curve
* Cohesive visual identity (medieval fantasy)

---

## 📌 Next Steps

* Finalize **castle_dungeons** (first 3 rooms)
* Improve gravity feedback (visual/audio)
* Begin structured playtesting
* Refine movement and controls

---

## 🧠 Designer Notes

* If a room needs explanation, it is poorly designed
* If gravity is not required, the room failed
* Simple > complex
* Clarity > difficulty

---
