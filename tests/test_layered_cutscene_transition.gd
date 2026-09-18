extends SceneTree

const SEQUENCE_SCRIPT_PATH := "res://scripts/cena_4.gd"
const CENA4_SCENE_PATH := "res://scenes/cena4.tscn"

const LAYERED_SCENES := {
	"cena4": {
		"scene": "res://scenes/cena4.tscn",
		"script": "res://scripts/cena_4.gd",
		"top": "assets/sprites/scenes/cena4/Tela_hub_salas_cima.png",
		"bottom": "assets/sprites/scenes/cena4/Tela_hub_salas_baixo.png",
		"next": "res://scenes/cena5.tscn",
	},
	"cena5": {
		"scene": "res://scenes/cena5.tscn",
		"script": "res://scripts/cena_5.gd",
		"top": "assets/sprites/scenes/cena5/imagem_cima.png",
		"bottom": "assets/sprites/scenes/cena5/imagem_baixo.png",
		"next": "res://scenes/cena6.tscn",
	},
	"cena6": {
		"scene": "res://scenes/cena6.tscn",
		"script": "res://scripts/cena_6.gd",
		"top": "assets/sprites/scenes/cena6/imagem_cima.png",
		"bottom": "assets/sprites/scenes/cena6/imagem_baixo.png",
		"next": "res://scenes/cena7.tscn",
	},
	"cena7": {
		"scene": "res://scenes/cena7.tscn",
		"script": "res://scripts/cena_7.gd",
		"top": "assets/sprites/scenes/cena7/imagem_cima.png",
		"bottom": "assets/sprites/scenes/cena7/imagem_baixo.png",
		"next": "res://scenes/character_select.tscn",
	},
}


func _init() -> void:
	var sequence_script_text := FileAccess.get_file_as_string(SEQUENCE_SCRIPT_PATH)
	var cena4_scene_text := FileAccess.get_file_as_string(CENA4_SCENE_PATH)

	assert_contains(
		sequence_script_text,
		"_play_intro_animation()",
		"Scene sequence should start the intro animation on ready."
	)
	assert_contains(
		sequence_script_text,
		"top_start.x += viewport_width",
		"Top image should enter from the right."
	)
	assert_contains(
		sequence_script_text,
		"bottom_start.x -= viewport_width",
		"Bottom image should enter from the left."
	)
	assert_contains(
		sequence_script_text,
		"top_end.x += viewport_width",
		"Top image should exit to the right before changing scenes."
	)
	assert_contains(
		sequence_script_text,
		"bottom_end.x -= viewport_width",
		"Bottom image should exit to the left before changing scenes."
	)
	assert_contains(
		sequence_script_text,
		"create_tween()",
		"Scene sequence should animate layers with a tween."
	)
	assert_contains(sequence_script_text, "scene_index", "Scene sequence should track the current internal scene index.")
	assert_contains(sequence_script_text, "current_scene[\"logo\"]", "Scene sequence should support the cena8 logo layer.")
	assert_contains(sequence_script_text, "res://assets/sprites/scenes/cena8/fundo.png", "Cena8 background should be in the internal sequence.")
	assert_contains(sequence_script_text, "res://assets/sprites/scenes/cena8/professor.png", "Cena8 professor should be in the internal sequence.")
	assert_contains(sequence_script_text, "res://assets/sprites/scenes/cena8/oxyquest.png", "Cena8 logo should be in the internal sequence.")
	assert_contains(sequence_script_text, "CENA8_PROFESSOR_BOTTOM_MARGIN_RATIO", "Cena8 professor should use a responsive bottom margin.")
	assert_contains(sequence_script_text, "_apply_professor_layout()", "Scene sequence should reposition the professor for each internal scene.")
	assert_contains(sequence_script_text, "_play_professor_pop()", "Professor should have a quick pop/stretch animation.")
	assert_contains(sequence_script_text, "SceneTransition.fade_change_scene(\"res://scenes/character_select.tscn\")", "Final sequence step should go to character selection.")
	assert_not_contains(sequence_script_text, "change_scene_to_file(\"res://scenes/cena5.tscn\")", "Cena4 should not change to cena5 directly, avoiding scene-load flicker.")
	assert_contains(cena4_scene_text, "name=\"Logo\"", "Cena4 sequence scene should include a logo layer for cena8.")
	assert_contains(cena4_scene_text, "assets/sprites/scenes/cena8/oxyquest.png", "Cena4 sequence scene should preload the cena8 logo sprite.")

	for scene_name in LAYERED_SCENES:
		var config: Dictionary = LAYERED_SCENES[scene_name]

		assert_contains(sequence_script_text, "res://assets/sprites/scenes/%s/fundo.png" % scene_name, "%s background should be in the internal sequence." % scene_name)
		assert_contains(sequence_script_text, "res://assets/sprites/scenes/%s/professor.png" % scene_name, "%s professor should be in the internal sequence." % scene_name)
		assert_contains(sequence_script_text, config["top"], "%s top image should be in the internal sequence." % scene_name)
		assert_contains(sequence_script_text, config["bottom"], "%s bottom image should be in the internal sequence." % scene_name)

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
