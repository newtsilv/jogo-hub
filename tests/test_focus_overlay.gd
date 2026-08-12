extends SceneTree


const MAIN_SCENE_PATH := "res://scenes/main.tscn"
const MAIN_SCRIPT_PATH := "res://scripts/main.gd"


func _init() -> void:
	var main_scene_text := FileAccess.get_file_as_string(
		MAIN_SCENE_PATH
	)
	var main_script_text := FileAccess.get_file_as_string(
		MAIN_SCRIPT_PATH
	)

	assert_contains(
		main_scene_text,
		'[node name="BackgroundFocusOverlay" type="ColorRect" parent="UI"',
		"Main scene should include a focus overlay behind modal UI."
	)
	assert_contains(
		main_scene_text,
		"mouse_filter = 2",
		"Focus overlay should not consume input events."
	)
	assert_contains(
		main_scene_text,
		"color = Color(0, 0, 0, 0.22)",
		"Focus overlay should be a subtle translucent layer."
	)
	assert_contains(
		main_scene_text,
		"hint_screen_texture",
		"Focus overlay should sample the screen for blur."
	)
	assert_contains(
		main_scene_text,
		"filter_nearest_mipmap",
		"Focus overlay should use mipmaps for a soft blur."
	)
	assert_contains(
		main_scene_text,
		"material = SubResource(\"ShaderMaterial_focus_blur\")",
		"Focus overlay should use the blur shader material."
	)
	assert_contains(
		main_script_text,
		"show_focus_overlay()",
		"Main script should show the focus overlay for modal UI."
	)
	assert_contains(
		main_script_text,
		"hide_focus_overlay()",
		"Main script should hide the focus overlay when modal UI closes."
	)

	quit(0)


func assert_contains(text: String, expected: String, message: String) -> void:
	if text.contains(expected):
		return

	printerr(message)
	quit(1)
