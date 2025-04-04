# Active Context

**Status:** [CURRENT] | **Last Updated:** YYYY-MM-DD | **Version:** 1.0 (DOC-YYYYMMDD-1.0)

## Introduction

This document tracks the current focus of development, recent significant changes, and immediate next steps.

## Executive Summary

Basic project structure and state management are implemented. The focus is now shifting to the core visual element: implementing the ASCII pseudo-3D rendering engine within the `Gameplay` state, inspired by the layered style of "Door in the Woods".

## Key Points [IMPORTANT]

- **Current Mode:** Code Mode
- **Current Goal:** Implement foundational ASCII rendering system (pseudo-3D layering).
- **Recent Activity:** Implemented basic state management (`StateManager`, `MainMenu`, `Gameplay` states).
- **Immediate Next Steps:**
  1.  Choose a basic map data structure (e.g., 2D/3D grid) to store character, color, and height information.
  2.  Select/Set up a monospace font suitable for ASCII rendering.
  3.  Implement basic rendering loop in `Gameplay` state (or a dedicated `Renderer` module) to draw a flat map grid.
  4.  Begin incorporating height/layering logic into the drawing process.
- **Open Questions/Decisions:** Tilemap vs direct drawing? Specific character set? How to precisely handle layering logic?

## Current Focus Details

We are tackling the core visual challenge: **ASCII Pseudo-3D Rendering**.

1.  **Data Representation:** We need a way to store the map data. A 2D grid (e.g., `map[y][x]`) where each cell contains information like `{ character, foregroundColor, backgroundColor, height }` seems like a reasonable starting point. The `height` value will be critical for the layering.
2.  **Font:** A clear monospace font is essential. We can start with Love2D's default or load a specific one later.
3.  **Rendering Logic:** The `Gameplay:draw()` function needs to iterate through the map data. Initially, we'll just draw the characters based on their (x, y) position. The next crucial step will be to draw things in the correct order (e.g., higher elements potentially drawn later/offset) to achieve the pseudo-3D look.
