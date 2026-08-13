extends SceneTree


const MAIN_SCRIPT_PATH := "res://scripts/main.gd"


func _init() -> void:
	var main_script_text := FileAccess.get_file_as_string(
		MAIN_SCRIPT_PATH
	)

	assert_contains(
		main_script_text,
		"pending_game_over_dialogue",
		"Main should track when a wrong-answer dialogue must lead to game over."
	)
	assert_contains(
		main_script_text,
		"open_wrong_answer_dialogue(answered_npc)",
		"Wrong answers should open a dialogue before game over."
	)
	assert_contains(
		main_script_text,
		"get_wrong_answer_dialogue",
		"Wrong-answer dialogue should be generated per NPC."
	)
	assert_contains(
		main_script_text,
		"Faz parte! Errar também é aprender.",
		"Emanuel should have a wrong-answer line."
	)
	assert_contains(
		main_script_text,
		"Quase! Revise com calma e tente de novo.",
		"Laura should have a wrong-answer line."
	)
	assert_contains(
		main_script_text,
		"Tenho certeza de que você consegue!",
		"Marcos should have a wrong-answer line."
	)

	quit(0)


func assert_contains(text: String, expected: String, message: String) -> void:
	if text.contains(expected):
		return

	printerr(message)
	quit(1)
