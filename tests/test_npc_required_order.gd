extends SceneTree


const MAIN_SCRIPT_PATH := "res://scripts/main.gd"
const MAIN_SCENE_PATH := "res://scenes/main.tscn"


func _init() -> void:
	var main_script_text := FileAccess.get_file_as_string(
		MAIN_SCRIPT_PATH
	)
	var main_scene_text := FileAccess.get_file_as_string(
		MAIN_SCENE_PATH
	)

	assert_contains(
		main_script_text,
		"get_required_npc()",
		"Main should know which NPC must be completed next."
	)
	assert_contains(
		main_script_text,
		"return get_required_npc()",
		"Objective arrow and camera preview should follow the required order."
	)
	assert_contains(
		main_script_text,
		"if npc != required_npc:",
		"Main should block dialogue with NPCs outside the required order."
	)
	assert_contains(
		main_script_text,
		"Fale com %s antes.",
		"Main should tell the player who to talk to first."
	)
	assert_contains(
		main_script_text,
		"get_blocked_order_dialogue(npc, required_npc)",
		"Main should open a short blocked-order dialogue."
	)
	assert_contains(
		main_script_text,
		"attempted_npc.character_name",
		"The NPC being interacted with should say who to talk to first."
	)
	assert_contains(
		main_script_text,
		"pending_objective_preview_npc",
		"Main should delay the objective camera until after the next-NPC dialogue."
	)
	assert_contains(
		main_script_text,
		"open_next_objective_dialogue(completed_npc)",
		"Completing an NPC should open a next-NPC dialogue before the camera preview."
	)
	assert_contains(
		main_script_text,
		"Agora fale com %s.",
		"The completed NPC should tell the player who to talk to next."
	)
	assert_contains(
		main_scene_text,
		"character_name = \"Marcos Barros\"",
		"The final NPC should be named Marcos Barros in the scene."
	)
	assert_contains(
		main_scene_text,
		"expression_key = \"mb\"",
		"Marcos Barros should keep using the existing MB expression assets."
	)
	assert_contains(
		main_script_text,
		"\"Marcos Barros\"",
		"Dialogue lines should use Marcos Barros instead of MB."
	)
	assert_not_contains(
		main_script_text,
		"\"MB\"",
		"Main script should not display MB as the speaker name."
	)

	quit(0)


func assert_contains(text: String, expected: String, message: String) -> void:
	if text.contains(expected):
		return

	printerr(message)
	quit(1)


func assert_not_contains(text: String, unexpected: String, message: String) -> void:
	if not text.contains(unexpected):
		return

	printerr(message)
	quit(1)
