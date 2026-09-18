extends SceneTree


const MAIN_SCRIPT_PATH := "res://scripts/main.gd"
const MAIN_SCENE_PATH := "res://scenes/main.tscn"
const PROJECT_PATH := "res://project.godot"
const CENA_7_SCRIPT_PATH := "res://scripts/cena_7.gd"
const CENA_8_SCRIPT_PATH := "res://scripts/cena_8.gd"
const CENA_2_SCRIPT_PATH := "res://scripts/cena_2.gd"
const CENA_4_SCRIPT_PATH := "res://scripts/cena_4.gd"
const CHARACTER_SELECT_SCRIPT_PATH := "res://scripts/character_select.gd"
const SCENE_TRANSITION_SCRIPT_PATH := "res://scripts/scene_transition.gd"


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
	var cena_7_script_text := FileAccess.get_file_as_string(
		CENA_7_SCRIPT_PATH
	)
	var cena_8_script_text := FileAccess.get_file_as_string(
		CENA_8_SCRIPT_PATH
	)
	var cena_2_script_text := FileAccess.get_file_as_string(
		CENA_2_SCRIPT_PATH
	)
	var cena_4_script_text := FileAccess.get_file_as_string(
		CENA_4_SCRIPT_PATH
	)
	var scene_transition_text := FileAccess.get_file_as_string(
		SCENE_TRANSITION_SCRIPT_PATH
	)
	var character_select_script_text := FileAccess.get_file_as_string(
		CHARACTER_SELECT_SCRIPT_PATH
	)
	var dialog_script_text := FileAccess.get_file_as_string("res://scripts/dialog_box.gd")
	var reward_script_text := FileAccess.get_file_as_string("res://scripts/reward_box.gd")
	var pause_script_text := FileAccess.get_file_as_string("res://scripts/pause_menu.gd")

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
		dialog_script_text,
		"bottom_margin",
		"Dialogue box should keep a fixed lower-screen position."
	)
	assert_contains(
		dialog_script_text,
		"EXTRA_TALL_SCREEN_DIALOGUE_OFFSET_RATIO",
		"Dialogue box should move down on extra-tall screens."
	)
	assert_contains(
		dialog_script_text,
		"base_position",
		"Dialogue box should preserve the scene-authored base position."
	)
	assert_contains(
		dialog_script_text,
		"resized.connect(_apply_responsive_layout)",
		"Dialogue box should recalculate its position when the viewport changes."
	)
	assert_contains(
		cena_2_script_text,
		"TV_TOP_OFFSET_RATIO",
		"Cena3 TV should use a responsive top offset instead of staying too high."
	)
	assert_contains(
		cena_2_script_text,
		"tv_extra_height",
		"Cena3 TV should move down only when the viewport has extra height."
	)
	assert_contains(
		cena_2_script_text,
		"maxf(0.0, size.y - DESIGN_SIZE.y * scale_factor)",
		"Cena3 TV should not move down on standard desktop-height layout."
	)
	assert_contains(
		cena_4_script_text,
		"DESIGN_SIZE",
		"Cena4-8 sequence should scale layers from the design size."
	)
	assert_contains(
		cena_4_script_text,
		"_apply_responsive_layout()",
		"Cena4-8 sequence should recalculate layer positions from the viewport size."
	)
	assert_contains(
		cena_4_script_text,
		"resized.connect(_apply_responsive_layout)",
		"Cena4-8 sequence should respond to viewport changes."
	)
	assert_contains(
		cena_4_script_text,
		"CENAS_4_7_PROFESSOR_BOTTOM_MARGIN_RATIO",
		"Cena4-7 professor should use a responsive bottom margin on mobile."
	)
	assert_contains(
		cena_4_script_text,
		"if scene_index < SCENES.size() - 1",
		"Cena4-7 professor margin should be separate from the cena8 adjustment."
	)
	assert_contains(
		reward_script_text,
		"EXTRA_TALL_SCREEN_REWARD_OFFSET_RATIO",
		"Reward pin should move down on extra-tall screens."
	)
	assert_contains(
		reward_script_text,
		"_apply_responsive_layout()",
		"Reward box should recalculate message and pin layout."
	)
	assert_contains(
		pause_script_text,
		"_apply_responsive_layout()",
		"Pause menu should recalculate its layout from the viewport size."
	)
	assert_contains(
		pause_script_text,
		"resized.connect(_apply_responsive_layout)",
		"Pause menu should respond to viewport changes."
	)
	assert_contains(
		character_select_script_text,
		"_apply_responsive_layout()",
		"Character selection should scale its background and hitboxes from the viewport size."
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
	assert_contains(
		cena_7_script_text,
		"SceneTransition.fade_change_scene(\"res://scenes/character_select.tscn\")",
		"Cena 7 skip should fade into character selection."
	)
	assert_contains(
		cena_8_script_text,
		"SceneTransition.fade_change_scene(\"res://scenes/character_select.tscn\")",
		"Cena 8 should fade into character selection."
	)
	assert_contains(
		scene_transition_text,
		"func fade_change_scene(",
		"SceneTransition should provide a plain fade transition."
	)
	assert_contains(
		main_scene_text,
		"text = \"PAUSAR\"",
		"Pause button should use readable text instead of the pause icon."
	)

	quit(0)


func assert_contains(text: String, expected: String, message: String) -> void:
	if text.contains(expected):
		return

	printerr(message)
	quit(1)
