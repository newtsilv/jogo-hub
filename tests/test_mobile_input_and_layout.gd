extends SceneTree


const MAIN_SCRIPT_PATH := "res://scripts/main.gd"
const MAIN_SCENE_PATH := "res://scenes/main.tscn"
const PROJECT_PATH := "res://project.godot"


func _init() -> void:
	var main_script_text := FileAccess.get_file_as_string(
		MAIN_SCRIPT_PATH
	)
	var main_scene_text := FileAccess.get_file_as_string(
		MAIN_SCENE_PATH
	)
	var project_text := FileAccess.get_file_as_string(
		PROJECT_PATH
	)

	assert_contains(
		main_script_text,
		"input_is_blocked()",
		"Main input should use one shared modal/camera guard."
	)
	assert_contains(
		main_script_text,
		"objective_preview_is_active",
		"Objective camera movement should block player input."
	)
	assert_contains(
		main_script_text,
		"dialogue_box.dialogue_is_closing",
		"Dialogue closing animation should still block re-entry."
	)
	assert_contains(
		main_script_text,
		"question_box.question_is_closing",
		"Question closing animation should still block re-entry."
	)
	assert_contains(
		main_script_text,
		"player.stop_movement()",
		"Opening modal UI should stop player movement."
	)
	assert_contains(
		FileAccess.get_file_as_string("res://scripts/dialog_box.gd"),
		"bottom_margin",
		"Dialogue box should keep a fixed lower-screen position."
	)
	assert_contains(
		main_scene_text,
		"offset_bottom = 1160.0",
		"Question text should have enough vertical room for long Incode text."
	)
	assert_contains(
		project_text,
		"window/stretch/aspect=\"expand\"",
		"Mobile screens should use expand aspect for better full-screen coverage."
	)
	assert_contains(
		project_text,
		"window/handheld/orientation=1",
		"Android export should stay in portrait orientation."
	)

	quit(0)


func assert_contains(text: String, expected: String, message: String) -> void:
	if text.contains(expected):
		return

	printerr(message)
	quit(1)
