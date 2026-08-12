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
		'[node name="HUD" type="HBoxContainer" parent="UI"',
		"Pin HUD should use a horizontal UI container."
	)
	assert_contains(
		main_scene_text,
		"anchors_preset = 1",
		"Pin HUD should be anchored to the top-right corner."
	)
	assert_contains(
		main_scene_text,
		"custom_minimum_size = Vector2(32, 32)",
		"Pin slots should render as small icons."
	)
	assert_contains(
		main_scene_text,
		"offset_right = 32.0",
		"Pin slots should have a fixed small width."
	)
	assert_contains(
		main_scene_text,
		"offset_bottom = 32.0",
		"Pin slots should have a fixed small height."
	)
	assert_contains(
		main_scene_text,
		"offset_left = 456.0",
		"Reward pin should be much smaller than the full-size texture."
	)
	assert_contains(
		main_scene_text,
		"offset_right = 624.0",
		"Reward pin should be much smaller than the full-size texture."
	)
	assert_contains(
		main_scene_text,
		"theme_override_constants/separation = 10",
		"Pin slots should have horizontal spacing."
	)
	assert_contains(
		main_script_text,
		"PIN_HUD_REVEAL_SCALE",
		"Pin reveal animation should use a small HUD scale constant."
	)
	assert_contains(
		main_script_text,
		"PIN_HUD_ICON_SIZE",
		"HUD pins should be forced to a small runtime size."
	)
	assert_contains(
		main_script_text,
		"slot.size = PIN_HUD_ICON_SIZE",
		"HUD pin TextureRects should be resized when shown."
	)
	assert_contains(
		main_script_text,
		"REWARD_PIN_SIZE",
		"Reward pin should be forced to a smaller runtime size."
	)
	assert_contains(
		main_script_text,
		"pin_image.size = REWARD_PIN_SIZE",
		"Reward pin TextureRect should be resized when shown."
	)

	quit(0)


func assert_contains(text: String, expected: String, message: String) -> void:
	if text.contains(expected):
		return

	printerr(message)
	quit(1)
