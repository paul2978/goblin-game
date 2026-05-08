IMPLEMENTATION STATE

Project Phase:
Early Graybox Prototype

Engine:
Godot 4

Game Style:
2D side-scrolling roguelike action game inspired by Risk of Rain 1.

Player:

basic movement
jumping
sprinting
camera follow

World:

handcrafted graybox level
layered traversal
parallax backgrounds
combat arenas

Enemies:

simple enemy AI
idle/chase/attack states
state color readability
basic enemy spawning

Director:

lightweight enemy pacing
simple pressure scaling
timed spawning
unique function names per behavior block

Combat:

not fully implemented yet
responsive combat
enemy pressure
combat readability
traversal feel
pacing
item systems later

The game must feel:

fast
readable
dangerous
replayable
traversal focused

The game should NOT feel:

cramped
slow
realistic
simulation heavy
overcomplicated
Keep systems lightweight
Avoid over-engineering
Avoid premature abstraction
Maintain readable section formatting
Use explicit logic
Prefer stable simple systems

Planned later:

item system
XP and leveling
elite enemies
procedural generation
director expansion
pickups
VFX polish
audio
boss encounter integration

NOT currently planned:

multiplayer
crafting
quests
dialogue
open world systems

Implemented now:

basic enemy pressure
XP and leveling
elite enemy support
director pacing expansion
boss encounter foundations
boss encounter integration
modular world generation foundations
lightweight proc effects
upgrade path identity and build archetypes
enemy counterplay pressure, build adaptation, and landmark weighting
rare upgrades and run-defining moments
projectile proc constants renamed to avoid enemy-script member collisions
projectile proc application indentation fixed for global class parsing
boss and swarm proc constants renamed to avoid inherited ranged_enemy collisions
boss and swarm proc tuning constants renamed to keep ranged_enemy parsing stable
boss proc state renamed to avoid inherited ranged_enemy member collisions
advanced enemy ecology layering added to director spawn selection
lightweight unlock progression and replay-driven discovery added to player progression
