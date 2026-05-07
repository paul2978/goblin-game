# CODEX RULES

============================================================================
PROJECT OVERVIEW
================

This project is a gameplay-first 2D roguelike action prototype built in Godot 4.

Inspired by:

* Risk of Rain 1
* Left 4 Dead AI Director systems
* Horde survival roguelikes

The codebase must prioritize:

* readability
* stability
* debuggability
* gameplay feel
* fast iteration

over:

* clever abstractions
* over-engineering
* compressed code
* premature optimization

============================================================================
CORE DEVELOPMENT RULES
======================

* ALWAYS keep code simple and readable
* ALWAYS use explicit logic over shorthand logic
* ALWAYS use typed GDScript
* ALWAYS keep scripts easy to debug
* ALWAYS use clear section organization
* ALWAYS preserve working systems unless explicitly asked to refactor
* NEVER add unnecessary architecture
* NEVER over-engineer systems
* NEVER create giant monolithic managers
* NEVER create deeply nested logic
* NEVER add systems "for future use"

============================================================================
SCRIPT ORGANIZATION RULES
=========================

All gameplay scripts must use clear readable sections.

Use this exact style:

============================================================================
CONSTANTS
=========

============================================================================
EXPORTED VARIABLES
==================

============================================================================
NODE REFERENCES
===============

============================================================================
RUNTIME VARIABLES
=================

============================================================================
GODOT LIFECYCLE
===============

============================================================================
INPUT
=====

============================================================================
MOVEMENT
========

============================================================================
COMBAT
======

============================================================================
AI
==

============================================================================
VISUALS
=======

============================================================================
DEBUG
=====

Rules:

* one gameplay responsibility per section
* avoid misc/helper dumping grounds
* avoid giant functions
* keep ownership obvious

============================================================================
GODOT SAFETY RULES
==================

* NEVER assume Godot API signatures
* ALWAYS use Godot 4 compatible syntax
* NEVER chain complex API calls into one line
* ALWAYS split multi-step operations into readable variables
* ALWAYS store intermediate results before validation
* ALWAYS prefer explicit logic over compact logic

BAD:

return not get_world_2d().direct_space_state.intersect_shape(query, 1).is_empty()

GOOD:

var results := get_world_2d().direct_space_state.intersect_shape(query)

var has_collision := not results.is_empty()

return has_collision

============================================================================
ERROR PREVENTION
================

Before finishing any implementation:

* verify method names exist
* verify argument counts
* avoid undocumented shorthand
* avoid version-specific tricks
* prefer simplest working implementation
* avoid assumptions about engine behavior

============================================================================
DEBUGGING RULES
===============

When an error occurs:

* explain WHY the error happened
* explain WHICH assumption caused it
* provide the SMALLEST possible fix
* DO NOT rewrite working systems unnecessarily
* DO NOT refactor unrelated systems

============================================================================
ARCHITECTURE SAFETY
===================

* prioritize readability over optimization
* prioritize maintainability over abstraction
* one responsibility per function
* avoid giant one-line expressions
* avoid deeply nested logic
* avoid "smart" code

============================================================================
GAMEPLAY DIRECTION
==================

The game should always feel similar to:

* Risk of Rain 1
* fast traversal
* readable combat
* layered movement
* escalating enemy pressure
* atmospheric sci-fi ruins
* horizontal exploration
* dangerous open arenas

Prioritize:

* movement feel
* combat readability
* enemy pressure
* traversal flow
* replayability

============================================================================
CURRENT PROTOTYPE SCOPE
=======================

Current allowed systems:

* player movement
* graybox level design
* simple enemies
* simple combat
* enemy spawning
* basic director pacing

Current forbidden systems:

* multiplayer
* inventory systems
* save systems
* dialogue
* quests
* procedural generation
* complex crafting
* advanced RPG systems
