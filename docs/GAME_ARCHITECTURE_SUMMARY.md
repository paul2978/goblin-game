# GOBLIN HORDE 2 - COMPLETE ARCHITECTURE SUMMARY

## QUICK REFERENCE

**File:** `goblin-horde-2-documented.html`  
**Type:** Single-file HTML5 game with inline JavaScript  
**Canvas:** 1200x720 viewport, 1800x350 world grid, 12px tiles  
**Lines:** ~1850 lines of code  

---

## GAME OVERVIEW

Goblin Horde 2 is a procedural platformer dungeon game featuring:
- **Procedural level generation** using random rooms + Minimum Spanning Tree
- **Pack-based enemy AI** with state machine behavior
- **AI Director system** that dynamically spawns enemies based on pressure
- **Elite enemies** unlocked through progression
- **Simple physics** with gravity, jumping, and tile-based collision

---

## ARCHITECTURAL PRINCIPLES (CRITICAL)

### 🔴 HARD CONSTRAINTS - NEVER VIOLATE

1. **Section order is FIXED** - The 16 sections must remain in exact order
2. **Variable names are authoritative** - Do not rename existing variables
3. **Minimal changes only** - Touch the fewest sections necessary
4. **No refactoring** unless explicitly requested
5. **No complex systems** - Keep it simple (no pathfinding, no advanced AI)
6. **Always playable** - Every change must maintain a working game

### Development Philosophy

- Make the **smallest possible code change**
- **Ask before modifying** unrelated sections
- Prefer **boring, safe, incremental** improvements
- If a request conflicts with constraints, **explain the conflict** instead of guessing

---

## CODE ORGANIZATION

### Section Hierarchy (80-char separators)

```
============================================================================
MAIN SECTIONS (16 total, fixed order)
============================================================================

1.  CONSTANTS & GLOBALS
2.  INPUT HANDLING
3.  GRID HELPERS
4.  LEVEL GENERATION - ROOMS
5.  LEVEL GENERATION - CORRIDORS
6.  LEVEL GENERATION - PLATFORMS
7.  POST-GENERATION REPAIR
8.  PICKUPS
9.  MAIN LEVEL GENERATION
10. ENEMY SPAWNING
11. COLLISION DETECTION
12. GAME UPDATE (contains 12 subsections)
13. RENDERING
14. MINIMAP & DEBUG OVERLAY
15. RUNTIME DEBUG OVERLAY
16. MAIN LOOP & INITIALIZATION
```

### Game Update Subsections (40-char separators)

```
========================================
GAME UPDATE SUBSECTIONS (12 total)
========================================

a. Player Input Handling
b. Player Physics
c. Player Collision Response
d. Enemy AI State Machine
e. Pack Behavior Calculation
f. State Machine: Patrol → Regroup → Chase → Attack
g. Enemy Movement & Physics
h. Director System Update
i. Enemy Spawn Timer
j. Pickup Collision Detection
k. Projectile Update & Collision
l. Camera Follow System
```

---

## SYSTEM DEEP DIVES

### 🎮 PHYSICS SYSTEM

**Constants:**
```javascript
GRAVITY = 0.5          // Applied every frame
JUMP_VELOCITY = -11    // Initial upward velocity
MOVE_SPEED = 12        // Ground movement speed
MAX_FALL_SPEED = 15    // Terminal velocity
AIR_CONTROL = 0.7      // Reduced movement in air (0.7x)
```

**Derived Values:**
- Max jump height: ~6 tiles (calculated from physics)
- Air speed: 8.4 units/frame (12 × 0.7)

**Entity Bounds:**
```javascript
Horizontal: ±0.4 from position (0.8 tiles wide)
Vertical: -0.9 to 0 from position (0.9 tiles tall)
```

**Collision Detection:**
- Bottom check samples at `y + 0.1` to detect ground slightly below feet
- Prevents entities from "missing" the ground between frames
- Left/right checks at `y - 0.4` (middle of entity)
- Top check at `y - 0.9` (top of entity)

**Collision Response:**
```javascript
if (collision.left)  → x = floor(x) + 0.41  // Push right
if (collision.right) → x = ceil(x) - 0.41   // Push left  
if (collision.top)   → y = ceil(y)          // Push down
if (collision.bottom)→ y = floor(y)         // Snap to ground
```

---

### 🧠 ENEMY PACK AI

**Detection & Grouping:**
- Detection range: **14 tiles** (Math.hypot distance to player)
- Pack radius: **7 tiles** (count allies within range)
- Pack threshold: **3+ enemies** required to enter chase mode

**State Machine:**

```
PATROL (default)
├─ Speed: 0.75 (baseSpeed × 0.5)
├─ Behavior: Wander back/forth
├─ Turn at: Walls or ledges
└─ Transition: If alone → REGROUP, if pack formed → CHASE

REGROUP (vulnerable, fleeing)
├─ Speed: 13 (faster than player's 12)
├─ Behavior: Flee toward nearest ally
├─ Visual: Yellow color
└─ Transition: If pack forms → CHASE

CHASE (pack attack)
├─ Speed: 3.0 (maxSpeed)
├─ Behavior: Full aggression toward player
├─ Visual: Red with yellow pulse border
├─ Requires: 3+ enemies in pack
└─ Transition: If within 2 tiles → ATTACK

ATTACK (damage state)
├─ Speed: 0 (stop moving)
├─ Damage: 5-10 (grunts), 15-25 (elites)
├─ Cooldown: 1.5s (grunts), 1.0s (elites)
├─ Visual: White/magenta with red/white border
└─ Transition: After dealing damage → PATROL
```

**Visual State Indicators:**
- State letter ALWAYS visible: **P** / **R** / **C** / **A**
- Colors change based on state (see rendering section)

---

### 🎬 DIRECTOR SYSTEM (AI Spawning)

The Director combines:
- **Left 4 Dead**-style pressure system
- **Risk of Rain**-style credit accumulation

**Credit Mechanics:**
```javascript
Accumulation rate: 1.0/sec × (1 + pressure × 0.5)
Spawn cost: 1.5 credits per enemy
Credit cap: 10 (but can exceed during credit saving)
```

**Pressure Calculation (every 3 seconds):**
```javascript
activity = player_movement_distance / 150
density = enemy_count / 25
pressure = (activity × 0.5 + density × 0.5) × 2 - 1

Range: -1.0 (calm) to +1.0 (intense)
```

**Spawn Logic (checks every 0.5 seconds):**

```
IF enemy_count >= 12:
    SAVE CREDITS (skip spawning, allow credits to accumulate beyond cap)
    
ELSE IF low_pressure_for_30_seconds AND credits >= 7:
    FORCE SPAWN (pressure failsafe, prevents stall)
    
ELSE IF credits >= 1.5:
    SPAWN ENEMY (spend 1.5 credits)
    
AFTER SPAWNING:
    IF NOT saving credits:
        CLAMP credits to 10
```

**Low Pressure Failsafe:**
- Tracks duration when pressure < -0.3
- After 30 seconds + 7+ credits → force single spawn
- Resets timer after spawn
- Prevents complete spawn stall during low activity

---

### 👑 ELITE ENEMY SYSTEM

**Unlock Gates (both must pass):**
1. **Kill threshold:** 10 kills OR
2. **Time threshold:** 60 seconds elapsed

**Spawn Requirements (all must pass):**
1. ✅ Elites unlocked (above)
2. ✅ Credits >= 3.0 (2× normal cost)
3. ✅ Elite cooldown expired (15s since last elite)
4. ✅ Random roll succeeds (35% chance)

**Elite Properties:**
```javascript
Size: Larger (+4px border)
Damage: 15-25 (vs grunts 5-10)
Attack cooldown: 1.0s (vs grunts 1.5s)
Bravery: Always high (0.85-1.0)
Aggression range: 50 tiles (vs grunts ~15-40)

Visual:
- Patrol: Dark purple (#608)
- Regroup: Medium purple (#90f)
- Chase: Bright purple (#c0f)
- Attack: Magenta (#f0f) with white border
```

**Elite Spawn Flow:**
```
Check unlock → Check credits → Check cooldown → Roll 35%
         ↓             ↓              ↓            ↓
     (pass)        (pass)         (pass)      (success)
                                                  ↓
                                            SPAWN ELITE
                                                  ↓
                                      Set 15s cooldown
```

---

### 🗺️ LEVEL GENERATION

**Algorithm Overview:**

```
1. ROOM PLACEMENT (random with overlap rejection)
   └─ Generate 100-175 rooms of varying sizes
   └─ Reject overlapping rooms
   └─ Each room: width 6-14, height 6-14

2. MINIMUM SPANNING TREE (Prim's algorithm)
   └─ Connect all rooms with minimum edge weight
   └─ Weight = Manhattan distance between room centers
   └─ Creates connected dungeon graph

3. CORRIDOR CARVING (L-shaped paths)
   └─ 80% horizontal-first bias
   └─ Carve path from each MST edge
   └─ Add combat "bulges" to long corridors (width 3-5)

4. PLATFORM GENERATION (inside large rooms)
   └─ Only in rooms width >= 10 and height >= 8
   └─ Generate 1-3 platforms per qualifying room
   └─ Auto-place ladders using flood-fill for reachability

5. POST-GENERATION REPAIR
   └─ Fix ladder-floor intersections
   └─ Remove ladders that clip into solid tiles
   └─ Ensure clean, playable geometry

6. PICKUP PLACEMENT
   └─ Spawn gold (25%), gems (8%), chests (3%) in rooms
   └─ Tile-based collection system
```

**Room Generation Details:**
```javascript
Room count: 100 + random(76)  // 100-175 rooms
Room width: 6 + random(9)      // 6-14 tiles
Room height: 6 + random(9)     // 6-14 tiles
Max placement attempts: 1000 per room
Overlap buffer: 2 tiles (rooms must be 2 tiles apart)
```

**MST Edge Selection:**
```javascript
For each unconnected room:
    Find closest connected room (Manhattan distance)
    Add edge to spanning tree
    Mark room as connected
Continue until all rooms connected
```

---

### 📊 RUNTIME DEBUG OVERLAY

**Display Sections:**

```
=== RUNTIME DEBUG ===

ENEMIES
  Total: [count]
  Patrol:  [count]
  Regroup: [count]
  Chase:   [count]
  Attack:  [count]
  Elites:  [count]
  Grunts:  [count]
  Kills:   [count]

DIRECTOR
  Credits:    [X.XX] / 10.0
  Rate:       [X.XX]/sec
  Pressure:   [X.XX]
  Next spawn: [X.XX]s
  Status:     [text]
  Last spawn: N/A

ELITES
  Unlocked:   YES/NO
  Cooldown:   [X.X]s

[F] Toggle Debug
```

**Director Status Text (derived, read-only):**
- "Credit capped" - at 10 credits
- "Eligible to spawn" - has credits and timer ready
- "Saving credits" - below 1.5 credits
- "Waiting for timer" - has credits but timer not ready

**Implementation Rules:**
- ✅ Read-only visualization
- ✅ No simulation logic
- ✅ No new state variables
- ✅ Toggle with F key
- ✅ Default: OFF

---

## DATA STRUCTURES

### Player Object
```javascript
{
    x: number,              // World position X
    y: number,              // World position Y
    vx: number,             // Velocity X
    vy: number,             // Velocity Y
    onGround: boolean,      // Touching ground?
    onLadder: boolean,      // On ladder tile?
    facing: 1 | -1,         // Direction facing
    health: number,         // Current HP (0-100)
    maxHealth: number       // Max HP (100)
}
```

### Enemy Object
```javascript
{
    x: number,              // World position X
    y: number,              // World position Y
    vx: number,             // Velocity X
    vy: number,             // Velocity Y
    dir: 1 | -1,            // Movement direction
    onGround: boolean,      // Touching ground?
    
    // AI State
    state: 'patrol' | 'regroup' | 'chase' | 'attack',
    isElite: boolean,       // Elite or grunt?
    bravery: number,        // 0.0-1.0, affects behavior
    aggressionRange: number,// Detection range in tiles
    fearThreshold: number,  // Min pack size before fleeing
    pressure: number,       // Individual pressure tracking
    fleeTimer: number,      // (unused legacy)
    moraleBoost: number,    // (unused legacy)
    
    // Combat
    attackDamage: number,   // 5-10 (grunt) or 15-25 (elite)
    attackCooldown: number  // Seconds until next attack
}
```

### Director Object
```javascript
{
    pressure: number,           // -1.0 to 1.0
    lastX: number,              // Last player X (for movement tracking)
    lastY: number,              // Last player Y
    distMoved: number,          // Accumulated movement distance
    updateTimer: number,        // Timer for 3-second pressure updates
    spawnCredits: number,       // Current spawn credits (can exceed 10)
    gameTime: number,           // Elapsed game time (seconds)
    eliteSpawnCooldown: number, // Countdown to next elite spawn allowed
    lowPressureTimer: number    // Duration of low pressure (for failsafe)
}
```

### Level Object
```javascript
{
    grid: Array<Array<{         // 2D grid [y][x]
        solid: boolean,         // Is this tile solid?
        ladder: boolean         // Is this tile a ladder?
    }>>,
    rooms: Array<{              // Room metadata
        x: number,              // Top-left X
        y: number,              // Top-left Y
        w: number,              // Width
        h: number,              // Height
        cx: number,             // Center X
        cy: number              // Center Y
    }>
}
```

### Pickup Object
```javascript
{
    x: number,          // Tile X
    y: number,          // Tile Y
    type: 'gold' | 'gem' | 'chest',
    collected: boolean  // Has player collected this?
}
```

### Projectile Object
```javascript
{
    x: number,          // World position X
    y: number,          // World position Y
    vx: number,         // Velocity X
    vy: number,         // Velocity Y
    lifetime: number    // Seconds remaining (starts at 1.5)
}
```

---

## VISUAL REFERENCE

### Player
- **Shape:** Green rectangle
- **Health bar:** Bottom-left corner, gradient (green → yellow → red)

### Enemies - Grunts
- **Patrol:** Dim red `#a66`
- **Regroup:** Yellow `#ff0`
- **Chase:** Red `#f00` with yellow pulse border
- **Attack:** White `#fff` with red border
- **State letter:** Always visible (P/R/C/A)

### Enemies - Elites
- **Patrol:** Dark purple `#608`
- **Regroup:** Medium purple `#90f`
- **Chase:** Bright purple `#c0f`
- **Attack:** Magenta `#f0f` with white border
- **Size:** Larger with +4px border
- **State letter:** Always visible (P/R/C/A)

### Other Elements
- **Projectiles:** Yellow circles
- **Ladders:** Cyan vertical lines
- **Pickups:**
  - Gold: Yellow circle
  - Gem: Magenta diamond
  - Chest: Orange box

### Minimap
- **Position:** Top-right corner
- **Shows:** Rooms (white rectangles), player (green dot)

---

## CONTROLS

| Key | Action |
|-----|--------|
| `R` | Generate new level |
| `A` or `←` | Move left |
| `D` or `→` | Move right |
| `Space` or `W` | Jump |
| `W` on ladder | Climb up |
| `S` on ladder | Climb down |
| `J` | Shoot projectile (1.5s lifetime, faces current direction) |
| `F` | Toggle debug overlay |

---

## COMMON MODIFICATION PATTERNS

### To Add a New Enemy Type
1. Update `spawnEnemy()` in **ENEMY SPAWNING** section
2. Add spawn logic with conditions (like elite gates)
3. Add visual rendering in **RENDERING** section
4. Test that state machine still works

### To Adjust Director Behavior
1. Modify credit rate/cost constants in **CONSTANTS & GLOBALS**
2. Update spawn logic in **Enemy Spawn Timer** subsection
3. Adjust pressure calculation in **Director System Update**
4. Update debug overlay to show new values

### To Change Physics
1. Update constants in **CONSTANTS & GLOBALS**
2. Verify collision still works (test wall/floor/ceiling)
3. Check both player and enemy physics subsections
4. Test jumping and falling feel right

### To Fix Collision Bugs
1. Check **COLLISION DETECTION** section (checkCollision function)
2. Verify **Player Collision Response** subsection
3. Verify **Enemy Movement & Physics** subsection
4. Test against walls, floors, ceilings, ladders

---

## WHAT IS NOT IMPLEMENTED

The following systems are **intentionally absent** and should not be added unless explicitly requested:

- ❌ Score/UI systems (beyond health bar and debug)
- ❌ Sound/audio
- ❌ Multiple weapon types
- ❌ Boss enemies
- ❌ Level progression/saving
- ❌ Inventory system
- ❌ Skill trees or upgrades
- ❌ Multiplayer

---

## HANDOFF CHECKLIST FOR NEW LLM

When another LLM takes over this codebase:

1. ✅ Read this entire summary document
2. ✅ Read the comprehensive documentation header in the HTML file
3. ✅ Understand the 16-section structure is FIXED
4. ✅ Review the hard constraints (no refactoring, minimal changes)
5. ✅ Familiarize with the three main systems (Physics, Pack AI, Director)
6. ✅ Test the game by opening the HTML file in a browser
7. ✅ Enable debug overlay (F key) to see live system state
8. ✅ Before making changes, identify which section(s) will be modified
9. ✅ Make the smallest possible change that accomplishes the goal
10. ✅ Test that the game remains playable after changes

---

## DEBUGGING TIPS

**Game won't load:**
- Check browser console for JavaScript errors
- Verify all functions are defined before use
- Check that all `{` have matching `}`

**Collision broken:**
- Verify `checkCollision()` bounds calculations
- Check collision response in both player and enemy sections
- Test bottom check at `y + 0.1` for ground detection

**Enemies acting weird:**
- Enable debug overlay to see state distribution
- Verify pack counting logic (7-tile radius)
- Check state transition conditions in AI state machine

**Director not spawning:**
- Check debug overlay: Credits, Pressure, Status
- Verify spawn timer is incrementing
- Check that credit saving rule (12+ enemies) isn't blocking
- Verify spawn cost (1.5) vs accumulated credits

**Elites never appear:**
- Check kill count or game time has reached threshold
- Verify credits >= 3.0
- Check elite cooldown has expired
- Remember: only 35% chance even when conditions met

---

## VERSION HISTORY

**Current Version:** Final tuned build with:
- Risk of Rain-style credit system
- Elite unlock gates (time/kills)
- Pressure failsafe for low activity
- Credit saving rule (skip spawning at high enemy count)
- Elite spawn cooldown (15s between elites)
- Enhanced flee speed (13 > player's 12)
- Comprehensive runtime debug overlay

**Key Features:**
- Procedural MST-based level generation
- Pack behavior AI with 4 states
- Dynamic director spawning with pressure system
- Elite enemies with progression unlock
- Tile-based physics and collision
- Debug overlay with live statistics

---

## FINAL NOTES

This codebase follows a **strict architectural discipline**:
- Sections are ordered and must not be rearranged
- Changes should be minimal and localized
- The game must remain playable at all times
- No complex systems should be added without explicit approval

When in doubt: **make the smallest change that solves the problem**, and **ask before touching unrelated sections**.

The debug overlay (F key) is your best friend for understanding system state in real-time.

**Good luck, and keep the goblins hordes challenging but fair!**
