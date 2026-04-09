# 🎮 Game Design Document (GDD)

## 📌 Project Name

**(To be defined)**
Codename: *Gravity Rooms*

---

## 🧠 Overview

**Gravity Rooms** is a 2D platformer focused on puzzle-solving through a **gravity inversion mechanic**.
Players must manipulate gravity to navigate challenging rooms, solve spatial puzzles, and reach the exit.

The game emphasizes:

* Clear and responsive gameplay
* Learning through interaction (no intrusive tutorials)
* Skill progression through mechanic mastery

---

## 🎯 Player Objective

* Navigate through levels
* Collect keys (or activate mechanisms)
* Reach the exit door

---

## 🎮 Core Mechanic

### 🔄 Gravity Inversion

The player can invert gravity at will (future limitations may apply).

**Gameplay impact:**

* Instantly redefines spatial navigation
* Enables creative puzzle-solving
* Expands vertical level design possibilities

---

## 🧩 Secondary Mechanics

* Horizontal movement
* Jump
* Static platforms
* Moving platforms
* Hazard zones (lava, spikes)
* Special surfaces (ice)
* Altered physics areas (low/no gravity zones)

---

## 🧱 Level Structure

The game contains **30 levels**, divided into:

* 🟢 Easy (01–10) → Learning
* 🟡 Normal (11–20) → Combination
* 🔴 Hard (21–30) → Mastery

Each level follows the naming convention:

```id="lvlname01"
level_<NN>_<biome>_<difficulty>
```

Example:

```id="lvlname02"
level_01_neon_lab_easy
```

---

## 🌍 Biomes

Each biome introduces or expands gameplay mechanics:

| Biome             | Purpose                                  |
| ----------------- | ---------------------------------------- |
| neon_lab          | Tutorial and core mechanics introduction |
| ruins_ancient     | Spatial awareness                        |
| crystal_caves     | Visual guidance and direction            |
| lava_forge        | Timing and pressure                      |
| sky_ruins         | Gravity mastery                          |
| deep_forest       | Exploration and navigation               |
| ice_temple        | Precision and control                    |
| abandoned_station | Altered physics                          |
| shadow_realm      | Memory and perception                    |
| gravity_core      | Final challenge                          |

---

## 📈 Design Progression

### Core Principles:

1. Introduce **one mechanic at a time**
2. Teach through gameplay, not text
3. Reuse mechanics with variation
4. Increase difficulty through combination, not speed

---

## 🕹️ Gameplay Loop

1. Player enters level
2. Observes environment
3. Experiments with mechanics
4. Solves puzzle
5. Reaches exit
6. Progresses to next level

---

## 🎨 Art Direction

* Style: minimalistic and functional
* Clarity over realism
* Color used to communicate mechanics
* Each biome has a distinct identity

---

## 🔊 Audio

* Action feedback (jump, gravity switch)
* Interaction cues
* Ambient music per biome

---

## 🧪 Playtesting

Each level should be validated based on:

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
* Short, intelligent levels
* Clean learning curve
* Controlled scope (ideal for indie development)

---

## 📌 Next Steps

* Finalize neon_lab biome (first 3 levels)
* Improve gravity feedback (visual/audio)
* Start internal playtesting
* Refine movement feel

---

## 🧠 Designer Notes

* If a level needs explanation, it is poorly designed
* If the player does not use gravity, the level failed
* Simple > complex
* Clarity > difficulty

---
