extends SceneTree


const DIALOG_SCRIPT_PATH := "res://scripts/dialog_box.gd"
const MAIN_SCENE_PATH := "res://scenes/main.tscn"


func _init() -> void:
	var dialog_script_text := FileAccess.get_file_as_string(
		DIALOG_SCRIPT_PATH
	)
	var main_scene_text := FileAccess.get_file_as_string(
		MAIN_SCENE_PATH
	)

	assert_contains(
		dialog_script_text,
		"@export var default_background: Texture2D",
		"DialogueBox should export the default dialogue background."
	)
	assert_contains(
		dialog_script_text,
		"@export var incode_background: Texture2D",
		"DialogueBox should export the Incode dialogue background."
	)
	assert_contains(
		dialog_script_text,
		"@export var techx_background: Texture2D",
		"DialogueBox should export the TechX dialogue background."
	)
	assert_contains(
		dialog_script_text,
		"get_background_for_speaker(speaker_name)",
		"DialogueBox should choose the dialogue background from the current speaker."
	)
	assert_contains(
		dialog_script_text,
		"\"Emanuel\":",
		"Emanuel dialogue should use the Incode theme."
	)
	assert_contains(
		dialog_script_text,
		"\"Laura\":",
		"Laura dialogue should use the TechX theme."
	)
	assert_contains(
		main_scene_text,
		"dialog incode.png",
		"Main scene should include the Incode dialogue background asset."
	)
	assert_contains(
		main_scene_text,
		"dialog techx.png",
		"Main scene should include the TechX dialogue background asset."
	)

	quit(0)


func assert_contains(text: String, expected: String, message: String) -> void:
	if text.contains(expected):
		return

	printerr(message)
	quit(1)
