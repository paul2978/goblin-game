# AI SAFETY AND WORKFLOW

============================================================================
DOCUMENT PURPOSE
================

This document defines:

* AI coding behavior
* architecture safety rules
* workflow expectations
* debugging standards
* implementation priorities

All future implementations must follow this document.

============================================================================
REQUIRED DOCUMENTS
==================

Before making gameplay or architecture changes, always read:

* docs/CODEX_RULES.md
* docs/IMPLEMENTATION_STATE.md

When working on:

* AI
* spawning
* traversal
* pacing
* procedural systems
* gameplay architecture

also read:

* docs/GAME_ARCHITECTURE_SUMMARY.md

============================================================================
PRIMARY DEVELOPMENT GOALS
=========================

Prioritize:

* readable code
* stable code
* explicit logic
* simple architecture
* lightweight systems
* fast iteration
* gameplay feel

The project should always remain:

* easy to debug
* easy to modify
* easy to understand
* safe for iteration

============================================================================
ANTI-OVERENGINEERING RULES
==========================

Avoid:

* unnecessary abstraction
* giant manager classes
* premature optimization
* deeply nested systems
* advanced patterns without need
* component systems unless necessary
* framework-style architecture
* "future-proof" systems

Always prefer:

* practical solutions
* explicit logic
* simple systems
* stable implementations

============================================================================
GODOT API SAFETY RULES
======================

* NEVER assume Godot API signatures
* ALWAYS use Godot 4 compatible syntax
* NEVER chain complex API calls into one line
* ALWAYS split operations into intermediate variables
* ALWAYS validate assumptions
* ALWAYS use readable multi-step logic

BAD:

return not get_world_2d().direct_space_state.intersect_shape(query, 1).is_empty()

GOOD:

var results := get_world_2d().direct_space_state.intersect_shape(query)

var has_collision := not results.is_empty()

return has_collision

============================================================================
DEBUGGING RULES
===============

When an error occurs:

* explain WHY the error happened
* explain WHICH assumption caused the issue
* provide the SMALLEST possible fix
* avoid rewriting working systems
* avoid unrelated refactors

============================================================================
SCRIPT ORGANIZATION RULES
=========================

Use highly readable sections:

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
* avoid giant functions
* avoid misc/helper dumping grounds
* keep ownership obvious

============================================================================
GAMEPLAY DIRECTION
==================

The game should feel similar to:

* Risk of Rain 1
* fast traversal
* readable combat
* escalating pressure
* layered movement
* open combat arenas
* atmospheric sci-fi ruins

Focus on:

* movement feel
* combat readability
* enemy pressure
* pacing
* replayability

============================================================================
IMPLEMENTATION PHILOSOPHY
=========================

Build systems in this order:

1. movement
2. combat
3. enemy pressure
4. pacing
5. readability
6. replayability
7. procedural systems later

Do NOT build:

* giant systems early
* procedural generation too early
* complex item systems too early
* advanced AI too early

Gameplay feel comes first.
