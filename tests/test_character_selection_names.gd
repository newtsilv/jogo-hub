extends SceneTree


const CHARACTER_SELECT_SCENE_PATH := "res://scenes/character_select.tscn"
const CHARACTER_SELECT_SCRIPT_PATH := "res://scripts/character_select.gd"
const GAME_STATE_SCRIPT_PATH := "res://scripts/game_state.gd"
const PLAYER_SCENE_PATH := "res://scenes/player.tscn"
const PLAYER_SCRIPT_PATH := "res://scripts/player.gd"


func _init() -> void:
	var character_select_text := FileAccess.get_file_as_string(
		CHARACTER_SELECT_SCENE_PATH
	)
	var character_select_script_text := FileAccess.get_file_as_string(
		CHARACTER_SELECT_SCRIPT_PATH
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

	# A tela de seleção (arte do Figma) traz "Pedro" e "Maria" já
	# desenhados no fundo, então quem garante o mapeamento correto é
	# o script: PedroButton -> PEDRO, MariaButton -> MARIA.
	assert_contains(
		character_select_text,
		'name="PedroButton"',
		"Character select should have a PedroButton."
	)
	assert_contains(
		character_select_text,
		'name="MariaButton"',
		"Character select should have a MariaButton."
	)
	assert_contains(
		character_select_script_text,
		"pedro_button: Button = $PedroButton",
		"CharacterSelect should bind pedro_button to the PedroButton node."
	)
	assert_contains(
		character_select_script_text,
		"maria_button: Button = $MariaButton",
		"CharacterSelect should bind maria_button to the MariaButton node."
	)
	assert_contains(
		character_select_script_text,
		"_on_character_selected.bind(GameState.Character.PEDRO)",
		"PedroButton should select GameState.Character.PEDRO."
	)
	assert_contains(
		character_select_script_text,
		"_on_character_selected.bind(GameState.Character.MARIA)",
		"MariaButton should select GameState.Character.MARIA."
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
