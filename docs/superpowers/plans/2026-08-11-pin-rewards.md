# Pin Rewards Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Show the correct pin image and centered reward message after each NPC question is answered correctly.

**Architecture:** Rewards remain configured on each NPC in `scenes/main.tscn`. `RewardBox` displays the texture and name passed by `main.gd`, with centered text above the centered pin image.

**Tech Stack:** Godot 4, GDScript, `.tscn` scene resources.

---

### Task 1: Configure NPC Pins

**Files:**
- Modify: `scenes/main.tscn`

- [ ] **Step 1: Add pin texture resources**

Add ext resources for `PinTechX.png`, `pin incode.png`, and `pin oxygeni.png`.

- [ ] **Step 2: Assign rewards to NPCs**

Set Emanuel to Incode, Laura to TechX, and MB to Hub.

- [ ] **Step 3: Verify scene references**

Run: `godot --headless --path /home/newt/jogo-hub --quit`

Expected: the project loads without missing resource errors.

### Task 2: Center Reward UI

**Files:**
- Modify: `scenes/main.tscn`
- Modify: `scripts/reward_box.gd`

- [ ] **Step 1: Center reward nodes**

Set `RewardBox` to full-screen anchors, place `RewardText` above `PinImage`, and center both horizontally.

- [ ] **Step 2: Update reward text**

Use the message `Parabéns! Você ganhou o pin dourado da %s!` followed by the continue instruction.

- [ ] **Step 3: Verify parsing**

Run: `godot --headless --path /home/newt/jogo-hub --quit`

Expected: the project loads without script or scene parse errors.

## Self-Review

Spec coverage: covers the requested correct pin mapping, centered display, and congratulation phrase.

Placeholder scan: no placeholders remain.

Type consistency: existing `show_reward(pin_texture: Texture2D, pin_name: String)` signature remains unchanged.
