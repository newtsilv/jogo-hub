extends SceneTree

const CENA1_SCRIPT_PATH := "res://scripts/cena_1.gd"
const CREDITOS_SCENE_PATH := "res://scenes/creditos.tscn"
const CREDITOS_SCRIPT_PATH := "res://scripts/creditos.gd"


func _init() -> void:
	var cena1_script_text := FileAccess.get_file_as_string(CENA1_SCRIPT_PATH)
	var creditos_scene_text := FileAccess.get_file_as_string(CREDITOS_SCENE_PATH)
	var creditos_script_text := FileAccess.get_file_as_string(CREDITOS_SCRIPT_PATH)

	assert_contains(cena1_script_text, "SceneTransition.fade_change_scene(\"res://scenes/creditos.tscn\")", "Credits button should open the credits scene.")
	assert_contains(creditos_script_text, "SceneTransition.fade_change_scene(\"res://scenes/cena1.tscn\")", "Credits screen should return to cena1 when pressed.")
	assert_contains(creditos_scene_text, "color = Color(0, 0, 0, 1)", "Credits scene should have a black background.")
	assert_contains(creditos_scene_text, "assets/sprites/scenes/creditos/oxyquest.png", "Credits scene should show the Oxyquest logo first.")
	assert_contains(creditos_scene_text, "assets/sprites/scenes/creditos/Uma produção da Oxygeni Hub.png", "Credits scene should show the production credit second.")
	assert_contains(creditos_scene_text, "assets/sprites/scenes/creditos/nomes.png", "Credits scene should show names third.")
	assert_contains(creditos_scene_text, "assets/sprites/scenes/creditos/agradecimentos.png", "Credits scene should show acknowledgements fourth.")
	assert_contains(creditos_scene_text, "offset_right =", "Credits sprites should have explicit width so they are visible.")
	assert_contains(creditos_scene_text, "offset_bottom =", "Credits sprites should have explicit height so they are visible.")
	assert_contains(creditos_scene_text, "mouse_filter = 2", "Credits sprites should not block the fullscreen back button.")
	assert_not_contains(creditos_scene_text, "VBoxContainer", "Credits sprites should not rely on container minimum sizes.")
	assert_order(creditos_scene_text, "oxyquest.png", "Uma produção da Oxygeni Hub.png", "Oxyquest should appear before the production credit.")
	assert_order(creditos_scene_text, "Uma produção da Oxygeni Hub.png", "nomes.png", "Production credit should appear before names.")
	assert_order(creditos_scene_text, "nomes.png", "agradecimentos.png", "Names should appear before acknowledgements.")

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


func assert_order(text: String, first: String, second: String, message: String) -> void:
	var first_index: int = text.find(first)
	var second_index: int = text.find(second)

	if first_index >= 0 and second_index >= 0 and first_index < second_index:
		return

	printerr(message)
	quit(1)
