extends SceneTree


const CHARACTER_SELECT_SCENE_PATH := "res://scenes/character_select.tscn"
const GAME_STATE_SCRIPT_PATH := "res://scripts/game_state.gd"
const PLAYER_SCENE_PATH := "res://scenes/player.tscn"
const PLAYER_SCRIPT_PATH := "res://scripts/player.gd"


func _init() -> void:
	var character_select_text := FileAccess.get_file_as_string(
		CHARACTER_SELECT_SCENE_PATH
	)
	var game_state_text := FileAccess.get_file_as_string(
		GAME_STATE_SCRIPT_PATH
	)
	var player_scene_text := FileAccess.get_file_as_string(
		PLAYER_SCENE_PATH
	)
	var player_script_text := FileAccess.get_file_as_string(
		PLAYER_SCRIPT_PATH
	)

	assert_contains(
		character_select_text,
		'text = "PEDRO"',
		"Character select should label the male option as PEDRO."
	)
	assert_contains(
		character_select_text,
		'text = "MARIA"',
		"Character select should label the female option as MARIA."
	)
	assert_contains(
		game_state_text,
		"PEDRO",
		"GameState should expose PEDRO as a selectable character."
	)
	assert_contains(
		game_state_text,
		"MARIA",
		"GameState should expose MARIA as a selectable character."
	)
	assert_contains(
		player_scene_text,
		"pedro_texture",
		"Player scene should configure Pedro's sprite."
	)
	assert_contains(
		player_scene_text,
		"maria_texture",
		"Player scene should configure Maria's sprite."
	)
	assert_contains(
		player_scene_text,
		"scale = Vector2(0.3, 0.3)",
		"Player sprite should render larger in the world."
	)
	assert_contains(
		player_script_text,
		"pedro_texture",
		"Player script should use Pedro's sprite export."
	)
	assert_contains(
		player_script_text,
		"maria_texture",
		"Player script should use Maria's sprite export."
	)

	quit(0)


func assert_contains(text: String, expected: String, message: String) -> void:
	if text.contains(expected):
		return

	printerr(message)
	quit(1)
