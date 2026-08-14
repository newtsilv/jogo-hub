# Oxygeni Hub Roteiro Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the current placeholder NPC dialogue and question banks with the approved Oxygeni Hub journey roteiro.

**Architecture:** Keep the existing `main.gd` data-driven flow. Update `get_npc_conversation()` for Gabriel, Emanuel, Laura, and MB, and update `get_questions_for_npc()` for Emanuel, Laura, and MB with three-answer versions of the approved questions.

**Tech Stack:** Godot 4, GDScript, existing Godot scene resources.

---

### Task 1: Update Roteiro Dialogues

**Files:**
- Modify: `scripts/main.gd`

- [ ] **Step 1: Replace Gabriel dialogue**

Use the reception text from the roteiro. Gabriel introduces Oxygeni Hub, the Jornada da Faixa Branca, the three pins, and Marcos Barros.

- [ ] **Step 2: Replace Emanuel dialogue**

Use the Incode text from the roteiro. Emanuel introduces programming, logic, Python, algorithms, and the challenge.

- [ ] **Step 3: Replace Laura dialogue**

Use the TechX text from the roteiro. Laura introduces visual experiences, front-end, UI elements, and the challenge.

- [ ] **Step 4: Replace MB dialogue**

Use the Marcos Barros/Oxygeni Hub text from the roteiro. MB introduces back-end and the final challenge.

### Task 2: Update Question Banks

**Files:**
- Modify: `scripts/main.gd`

- [ ] **Step 1: Replace Incode questions**

Add the four Incode questions adapted to three answers each, preserving the correct answer.

- [ ] **Step 2: Replace TechX questions**

Add the four TechX questions adapted to three answers each, preserving the correct answer.

- [ ] **Step 3: Replace Oxygeni Hub questions**

Add the four Oxygeni Hub questions adapted to three answers each, preserving the correct answer.

### Task 3: Verify Static Consistency

**Files:**
- Check: `scripts/main.gd`

- [ ] **Step 1: Verify no question has four answers**

Read `get_questions_for_npc()` and confirm each `answers` array contains three entries.

- [ ] **Step 2: Run whitespace check**

Run: `git diff --check -- scripts/main.gd`

Expected: no output.

- [ ] **Step 3: Try Godot headless if available**

Run: `godot --headless --path /home/newt/jogo-hub --quit`

Expected: command succeeds. If `godot` is unavailable, report that it could not be run.

## Self-Review

Spec coverage: covers the approved NPC order, dialogue replacement, three-answer question adaptation, and game-over-on-error behavior through existing code.

Placeholder scan: no placeholders remain.

Type consistency: no new public types or method signatures are introduced.
