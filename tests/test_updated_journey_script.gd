extends SceneTree


const MAIN_SCRIPT_PATH := "res://scripts/main.gd"
const REWARD_SCRIPT_PATH := "res://scripts/reward_box.gd"
const QUESTION_SCRIPT_PATH := "res://scripts/question_box.gd"
const MAIN_SCENE_PATH := "res://scenes/main.tscn"


func _init() -> void:
	var main_script_text := FileAccess.get_file_as_string(
		MAIN_SCRIPT_PATH
	)
	var reward_script_text := FileAccess.get_file_as_string(
		REWARD_SCRIPT_PATH
	)
	var question_script_text := FileAccess.get_file_as_string(
		QUESTION_SCRIPT_PATH
	)
	var main_scene_text := FileAccess.get_file_as_string(
		MAIN_SCENE_PATH
	)

	assert_contains(
		main_script_text,
		"conversar com os especialistas e conquistar os Pins da Jornada",
		"Gabriel should explain the short specialist pin journey."
	)
	assert_contains(
		main_script_text,
		"Na Incode, você aprende programação, lógica e como resolver problemas com tecnologia.",
		"Emanuel dialogue should briefly introduce Incode."
	)
	assert_contains(
		main_script_text,
		"Na TechX, a gente conecta tecnologia, criatividade e desafios reais para criar soluções.",
		"Laura dialogue should briefly introduce TechX."
	)
	assert_contains(
		main_script_text,
		"Eu sou o professor Marcos Barros.",
		"Marcos dialogue should match the new script."
	)
	assert_contains(
		main_script_text,
		"Parcerias com empresas e desafios reais",
		"Incode questions should include the updated third module answer."
	)
	assert_contains(
		main_script_text,
		"Todas as alternativas",
		"TechX questions should include the all alternatives answer."
	)
	assert_contains(
		main_script_text,
		"Talentos, professores, empresas e comunidade acadêmica",
		"Oxygeni questions should include the updated audience answer."
	)
	assert_contains(
		main_script_text,
		"Programador",
		"Gabriel and Emanuel should include their character profession."
	)
	assert_contains(
		main_script_text,
		"Programadora",
		"Laura should include her character profession."
	)
	assert_contains(
		main_script_text,
		"Professor",
		"Marcos Barros should include his character profession."
	)
	assert_contains(
		main_script_text,
		"profession",
		"Dialogue lines should carry profession metadata."
	)
	assert_contains(
		question_script_text,
		"A pergunta precisa ter exatamente 3 respostas",
		"Questions should use three answer choices."
	)
	assert_contains(
		main_script_text,
		"QuestionBox.QuestionTheme.TECHX",
		"Laura questions should use the TechX visual theme."
	)
	assert_contains(
		main_scene_text,
		"techXbox = ExtResource",
		"Main scene should connect the TechX question box texture."
	)
	assert_contains(
		main_scene_text,
		"techXbotao = ExtResource",
		"Main scene should connect the TechX button texture."
	)
	assert_contains(
		main_script_text,
		"Você conquistou o Pin Incode.",
		"Reward copy should use the updated Pin message."
	)
	assert_contains(
		main_scene_text,
		"theme_override_font_sizes/normal_font_size = 40",
		"Dialogue text font should be larger."
	)

	quit(0)


func assert_contains(text: String, expected: String, message: String) -> void:
	if text.contains(expected):
		return

	printerr(message)
	quit(1)
