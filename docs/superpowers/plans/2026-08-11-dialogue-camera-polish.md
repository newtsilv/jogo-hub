# Dialogue Camera Polish Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix Laura's dialogue portrait source, use Emanuel's expression set more dynamically, and add a short camera pan to the next character after completing an interaction.

**Architecture:** Keep the existing NPC expression loader and player camera. Add an auxiliary `Camera2D` to `scenes/main.tscn`; `scripts/main.gd` drives that camera to the next available NPC, waits briefly, and returns control to the player's camera.

**Tech Stack:** Godot 4, GDScript, `.tscn` scene resources.

---

### Task 1: Portrait Data Fixes

**Files:**
- Modify: `scenes/main.tscn`
- Modify: `scripts/npc.gd`
- Modify: `scripts/main.gd`

- [ ] **Step 1: Remove Laura fallback portrait**

Clear Laura's `portrait` assignment in `scenes/main.tscn` so the balloon uses expression sprites instead of `laura.png`.

- [ ] **Step 2: Prefer Laura expression fallback**

Update `NPC.get_portrait_for_expression()` to use loaded expression portraits first, then `feliz`/`base`, then exported `portrait`.

- [ ] **Step 3: Vary Emanuel expressions**

Change Emanuel dialogue lines to use `base`, `pensante`, and `aponta_cima` across the conversation.

### Task 2: Camera Preview

**Files:**
- Modify: `scenes/main.tscn`
- Modify: `scripts/player.gd`
- Modify: `scripts/main.gd`

- [ ] **Step 1: Add auxiliary camera**

Add `ObjectivePreviewCamera` under `Main`, disabled by default.

- [ ] **Step 2: Expose player camera return**

Add a `make_camera_current()` method to `Player` that calls `$Camera2D.make_current()`.

- [ ] **Step 3: Preview next NPC**

After finishing an NPC interaction, move the auxiliary camera to the player position, tween to the next available NPC, wait briefly, tween back, then return to the player camera.

### Task 3: Verify

**Files:**
- Check: modified files

- [ ] **Step 1: Run whitespace check**

Run: `git diff --check -- scenes/main.tscn scripts/main.gd scripts/npc.gd scripts/player.gd`

Expected: no output.

- [ ] **Step 2: Try Godot headless if available**

Run: `godot --headless --path /home/newt/jogo-hub --quit`

Expected: command succeeds. If unavailable, report it.

## Self-Review

Spec coverage: covers Laura portrait, Emanuel expression variety, and camera movement to next NPC then back to player.

Placeholder scan: no placeholders remain.

Type consistency: new `Player.make_camera_current()` is called from `Main` only.
