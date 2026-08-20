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
		"pending_final_badge: bool",
		"Main should track when the final badge is waiting for a click."
	)
	assert_contains(
		main_script_text,
		"show_final_badge()",
		"Finishing all pins should show the final badge."
	)
	assert_contains(
		main_script_text,
		"if collected_pins.size() >= 3:\n\t\tshow_final_badge()",
		"The final badge should show before hiding the focus overlay."
	)
	assert_contains(
		main_script_text,
		"await reward_box.show_reward(",
		"The final badge should be shown as a clickable reward screen."
	)
	assert_contains(
		main_script_text,
		"get_final_badge_texture()",
		"Main should choose the badge image from the selected character."
	)
	assert_contains(
		main_script_text,
		"GameState.Character.MARIA",
		"Maria should receive the female badge image."
	)
	assert_contains(
		main_script_text,
		"res://scenes/main_menu.tscn",
		"Clicking the final badge should return to the start menu."
	)
	assert_contains(
		main_scene_text,
		"crachá-homem.png",
		"Main scene should include Pedro's badge asset."
	)
	assert_contains(
		main_scene_text,
		"crachá-mulher.png",
		"Main scene should include Maria's badge asset."
	)
	assert_contains(
		FileAccess.get_file_as_string("res://project.godot"),
		"config/icon=\"res://assets/sprites/pin oxygeni.png\"",
		"The APK app icon should use the Oxygeni pin image."
	)

	quit(0)


func assert_contains(text: String, expected: String, message: String) -> void:
	if text.contains(expected):
		return

	printerr(message)
	quit(1)
