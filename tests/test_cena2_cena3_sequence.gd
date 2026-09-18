extends SceneTree

const CENA2_SCENE_PATH := "res://scenes/cena2.tscn"
const CENA2_SCRIPT_PATH := "res://scripts/cena_2.gd"


func _init() -> void:
	var scene_text := FileAccess.get_file_as_string(CENA2_SCENE_PATH)
	var cena3_text := FileAccess.get_file_as_string("res://scenes/cena3.tscn")
	var script_text := FileAccess.get_file_as_string(CENA2_SCRIPT_PATH)

	assert_contains(scene_text, "assets/sprites/scenes/cena2/fundo.png", "Cena2 should use the separated shared background.")
	assert_contains(scene_text, "assets/sprites/scenes/cena2/professor (2).png", "Cena2 should preload the first professor sprite.")
	assert_contains(script_text, "assets/sprites/scenes/cena3/professor (3).png", "Cena2 sequence should preload the cena3 professor sprite.")
	assert_contains(scene_text, "assets/sprites/scenes/cena3/tv.png", "Cena2 sequence should include the TV sprite.")
	assert_contains(scene_text, "name=\"Fundo\"", "Cena2 should have a responsive background node.")
	assert_contains(scene_text, "name=\"TV\"", "Cena2 should have a TV node behind the professor.")
	assert_contains(scene_text, "name=\"Professor\"", "Cena2 should have a professor node.")
	assert_contains(scene_text, "anchors_preset = 15", "Cena2 root/background should stretch for mobile screens.")

	assert_contains(script_text, "scene_index", "Cena2 should track the internal sequence step.")
	assert_contains(script_text, "_apply_responsive_layout()", "Cena2 should calculate layer positions from the viewport size.")
	assert_contains(script_text, "var scale_factor: float", "Cena2 responsive layout should avoid Variant type inference warnings.")
	assert_contains(script_text, "var professor_size: Vector2", "Cena2 professor size should be explicitly typed.")
	assert_contains(script_text, "PROFESSOR_BOTTOM_MARGIN_RATIO", "Cena2 professor should keep a responsive bottom margin.")
	assert_contains(script_text, "var tv_size: Vector2", "Cena2 TV size should be explicitly typed.")
	assert_contains(script_text, "_play_professor_pop()", "Cena2 should animate the professor with a pop/stretch.")
	assert_contains(script_text, "_play_tv_intro()", "TV should appear when moving to the cena3 step.")
	assert_contains(script_text, "tv_start.x = -tv.size.x", "TV should slide in from the left instead of zooming in.")
	assert_contains(script_text, "tv.scale = Vector2.ONE", "TV intro should not start with a zoom scale.")
	assert_contains(script_text, "_play_tv_zoom_transition()", "Cena3 should end with a TV zoom transition.")
	assert_contains(script_text, "pivot_offset = tv.position + tv.size / 2.0", "Final transition should zoom the whole screen toward the TV.")
	assert_contains(script_text, "tween_property(self, \"scale\"", "Final transition should scale the whole scene, not just the TV.")
	assert_not_contains(script_text, "tween_property(self, \"modulate:a\"", "TV zoom should not fade the scene before the TV fills the screen.")
	assert_contains(script_text, "SceneTransition.fade_change_scene(\"res://scenes/cena4.tscn\")", "Final TV zoom should fade to cena4 after the TV fills the screen.")
	assert_not_contains(script_text, "SceneTransition.change_scene(\"res://scenes/cena4.tscn\")", "Final TV transition should not use the circular scene transition.")
	assert_not_contains(script_text, "change_scene_to_file(\"res://scenes/cena3.tscn\")", "Cena2 should not load cena3 directly.")
	assert_contains(cena3_text, "anchor_right = 1.0", "Cena3 image should stretch to the right edge.")
	assert_contains(cena3_text, "anchor_bottom = 1.0", "Cena3 image should stretch to the bottom edge.")
	assert_contains(cena3_text, "stretch_mode = 5", "Cena3 image should cover the portrait viewport.")

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
