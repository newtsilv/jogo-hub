extends SceneTree

const CENA1_SCENE_PATH := "res://scenes/cena1.tscn"
const CENA1_SCRIPT_PATH := "res://scripts/cena_1.gd"


func _init() -> void:
	var scene_text := FileAccess.get_file_as_string(CENA1_SCENE_PATH)
	var script_text := FileAccess.get_file_as_string(CENA1_SCRIPT_PATH)

	assert_contains(scene_text, "assets/sprites/scenes/cena1/fundo.png", "Cena1 should use the separated background sprite.")
	assert_contains(scene_text, "assets/sprites/scenes/cena1/oxyquest.png", "Cena1 should use the separated logo sprite.")
	assert_contains(scene_text, "assets/sprites/scenes/cena1/jogar.png", "Cena1 should use the separated play button sprite.")
	assert_contains(scene_text, "assets/sprites/scenes/cena1/sair.png", "Cena1 should use the separated quit button sprite.")
	assert_contains(scene_text, "assets/sprites/scenes/cena1/creditos.png", "Cena1 should use the separated credits button sprite.")
	assert_contains(scene_text, "name=\"Logo\"", "Cena1 should have a separated logo node.")
	assert_contains(scene_text, "type=\"TextureRect\"", "Cena1 menu artwork should use full-size TextureRects.")
	assert_contains(scene_text, "texture = ExtResource", "Menu artwork should display exported button sprites at image size.")
	assert_contains(scene_text, "name=\"StartHitbox\"", "Play button should use a separate hitbox.")
	assert_contains(scene_text, "name=\"QuitHitbox\"", "Quit button should use a separate hitbox.")
	assert_contains(scene_text, "name=\"CredtHitbox\"", "Credits button should use a separate hitbox.")
	assert_contains(scene_text, "modulate = Color(1, 1, 1, 0)", "Hitboxes should remain invisible.")
	assert_contains(script_text, ".mouse_entered.connect", "Menu buttons should connect hover enter signals.")
	assert_contains(script_text, ".mouse_exited.connect", "Menu buttons should connect hover exit signals.")
	assert_not_contains(scene_text, "parent=\"TextureRect\"", "Menu buttons should not be transparent children over the old combined background.")

	assert_contains(script_text, "@onready var logo", "Cena1 script should animate the separated logo.")
	assert_contains(script_text, "_animar_logo()", "Cena1 should start the logo animation on ready.")
	assert_contains(script_text, "_on_menu_button_mouse_entered", "Cena1 should handle menu hover enter.")
	assert_contains(script_text, "_on_menu_button_mouse_exited", "Cena1 should handle menu hover exit.")
	assert_contains(script_text, "button_art_by_hitbox", "Cena1 should animate artwork from separate hitboxes.")
	assert_contains(script_text, "BUTTON_HOVER_SCALE := Vector2(1.015, 1.015)", "Cena1 should zoom buttons slightly and smoothly on hover.")
	assert_contains(script_text, "button_hover_tweens", "Cena1 should replace the previous hover tween instead of stacking animations.")

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
