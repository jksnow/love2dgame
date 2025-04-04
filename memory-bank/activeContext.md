# Active Context

**Status:** [CURRENT] | **Last Updated:** YYYY-MM-DD | **Version:** 1.0 (DOC-YYYYMMDD-1.0)

## Introduction

This document tracks the current focus of development, recent significant changes, and immediate next steps.

## Executive Summary

The initial project setup (`main.lua`, `conf.lua`) and Memory Bank foundation are complete. The current focus is shifting to implementing a basic game state management system to organize different parts of the game (e.g., menu, gameplay).

## Key Points [IMPORTANT]

- **Current Mode:** Code Mode
- **Current Goal:** Implement basic game state management.
- **Recent Activity:** Created `conf.lua` and `main.lua`. Established core Memory Bank documents.
- **Immediate Next Steps:**
  1.  Choose/design a simple state management approach (e.g., basic Lua table, `hump.gamestate`).
  2.  Create initial state files (e.g., `states/MainMenu.lua`, `states/Gameplay.lua`).
  3.  Refactor `main.lua` to use the state manager.
- **Open Questions/Decisions:** Simple table vs. library for state management?

## Current Focus Details

We are moving from pure setup to the first architectural implementation: **State Management**.

1.  **Decision:** Determine the approach for state handling. A simple table managing state functions (`load`, `update`, `draw`, `keypressed`) is often sufficient initially.
2.  **Implementation:** Create a `states` directory (likely within `src/`) and define placeholder states. Modify `main.lua` to delegate its `love.*` callbacks to the currently active state via the manager.
