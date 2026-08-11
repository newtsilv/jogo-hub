extends Node2D


const ClickIndicatorScript := preload("res://scripts/click_indicator.gd")


@export_category("Interação")
@export var hint_distance: float = 200.0


@export_category("Player")
@export var player_dialogue_name: String = "Player"
@export var player_portrait: Texture2D


var target_npc: NPC = null
var nearby_npc: NPC = null

var hint_is_visible: bool = false


var npc_objective_order: Array[NPC] = []
var current_npc_objective_index: int = 0

var active_dialogue_npc: NPC = null
var pending_question_npc: NPC = null
var rewarded_npc: NPC = null

var npc_by_name: Dictionary = {}

var collected_pins: Array[String] = []
var completed_npcs: Array[NPC] = []

@onready var entities: Node2D = $World/Entities
@onready var world: Node2D = $World
@onready var player: Player = $World/Entities/Player


@onready var dialogue_box: DialogueBox = (
	$UI/Dialog/DialogueBox
)

@onready var question_box: QuestionBox = (
	$UI/Questions/QuestionBox
)

@onready var reward_box: RewardBox = (
	$UI/Reward/RewardBox
)

@onready var game_over_box: GameOverBox = (
	$UI/GameOver/GameOverBox
)

@onready var interaction_hint: Label = (
	$UI/InteractionHint
)


func _ready() -> void:
	interaction_hint.hide()
	dialogue_box.hide()
	question_box.hide()
	reward_box.hide()
	game_over_box.hide()

	dialogue_box.dialogue_finished.connect(
		_on_dialogue_finished
	)

	question_box.question_answered.connect(
		_on_question_answered
	)

	reward_box.reward_closed.connect(
		_on_reward_closed
	)

	game_over_box.restart_requested.connect(
		_on_restart_requested
	)

	connect_npcs()

	npc_objective_order.sort_custom(
		_sort_npcs_by_objective_order
	)

	update_objective_arrow()


func _process(_delta: float) -> void:
	update_npc_proximity()
	update_objective_arrow()


# =========================================================
# ENTRADA E MOVIMENTAÇÃO
# =========================================================

func _unhandled_input(event: InputEvent) -> void:
	if interface_is_open():
		return

	var world_position: Vector2 = Vector2.ZERO
	var was_pressed: bool = false

	if event is InputEventScreenTouch:
		if event.pressed:
			world_position = screen_to_world(
				event.position
			)

			was_pressed = true

	elif event is InputEventMouseButton:
		if (
			event.button_index == MOUSE_BUTTON_LEFT
			and event.pressed
		):
			world_position = get_global_mouse_position()
			was_pressed = true

	if not was_pressed:
		return

	clear_current_interaction()
	show_click_indicator(world_position)
	player.move_to(world_position)


func show_click_indicator(world_position: Vector2) -> void:
	var indicator := ClickIndicatorScript.new()
	world.add_child(indicator)
	indicator.global_position = world_position


func screen_to_world(
	screen_position: Vector2
) -> Vector2:
	var inverse_canvas_transform: Transform2D = (
		get_viewport()
		.get_canvas_transform()
		.affine_inverse()
	)

	return inverse_canvas_transform * screen_position


func interface_is_open() -> bool:
	return (
		dialogue_box.dialogue_is_open
		or question_box.question_is_open
		or reward_box.reward_is_open
		or game_over_box.game_over_is_open
	)


# =========================================================
# NPCS
# =========================================================

func connect_npcs() -> void:
	npc_objective_order.clear()
	npc_by_name.clear()

	for child: Node in entities.get_children():
		if child is not NPC:
			continue

		var npc: NPC = child as NPC

		if not npc.selected.is_connected(
			_on_npc_selected
		):
			npc.selected.connect(
				_on_npc_selected
			)

		npc_objective_order.append(npc)
		npc_by_name[npc.character_name] = npc


func _sort_npcs_by_objective_order(
	first_npc: NPC,
	second_npc: NPC
) -> bool:
	return (
		first_npc.objective_order
		< second_npc.objective_order
	)


func update_npc_proximity() -> void:
	if target_npc == null:
		return

	var distance_to_npc: float = (
		player.global_position.distance_to(
			target_npc.global_position
		)
	)

	if distance_to_npc <= hint_distance:
		nearby_npc = target_npc

		if not hint_is_visible:
			show_npc_hint()

	elif nearby_npc == target_npc:
		nearby_npc = null
		hide_interaction_hint()


func _on_npc_selected(npc: NPC) -> void:
	if not npc.interaction_enabled:
		return

	if interface_is_open():
		return

	var distance_to_npc: float = (
		player.global_position.distance_to(
			npc.global_position
		)
	)

	if distance_to_npc <= hint_distance:
		target_npc = npc
		nearby_npc = npc

		player.stop_movement()
		open_npc_dialogue(npc)
		return

	clear_current_interaction()

	target_npc = npc

	player.move_to(npc.interaction_point.global_position)


func show_npc_hint() -> void:
	hint_is_visible = false
	interaction_hint.hide()
	return


func open_npc_dialogue(npc: NPC) -> void:
	if not npc.interaction_enabled:
		return

	hide_interaction_hint()
	player.stop_movement()

	active_dialogue_npc = npc

	var conversation: Array[Dictionary] = (
		get_npc_conversation(npc)
	)

	dialogue_box.start_dialogue(conversation)


func get_npc_conversation(
	npc: NPC
) -> Array[Dictionary]:
	match npc.dialogue_id:
		"gabriel_intro":
			return [
				make_dialogue_line(
					"Gabriel",
					"Opa! Gabriel sou eu. Seja muito bem-vindo ao Oxygeni Hub!",
					"base"
				),
				make_dialogue_line(
					"Gabriel",
					"Vou acompanhar você no início da sua jornada.",
					"joinha"
				),
				make_dialogue_line(
					"Gabriel",
					"Este lugar foi criado para pessoas que querem aprender, criar projetos e transformar ideias em soluções usando tecnologia.",
					"explicando"
				),
				make_dialogue_line(
					"Gabriel",
					"Aqui você vai encontrar diferentes áreas de aprendizado. Cada uma ensina uma habilidade importante para entrar no mundo da tecnologia.",
					"aponta_cima"
				),
				make_dialogue_line(
					"Gabriel",
					"Hoje sua missão é conquistar a sua primeira faixa: a Faixa Branca.",
					"joinha"
				),
				make_dialogue_line(
					"Gabriel",
					"Mas ninguém recebe uma faixa sem antes aprender o básico.",
					"base"
				),
				make_dialogue_line(
					"Gabriel",
					"Você precisará visitar nossos especialistas, completar seus desafios e coletar os três Pins da Jornada.",
					"explicando"
				),
				make_dialogue_line(
					"Gabriel",
					"Cada Pin representa um conhecimento que fará parte da sua evolução.",
					"base"
				),
				make_dialogue_line(
					"Gabriel",
					"Quando completar sua coleção, procure o professor Marcos Barros.",
					"aponta_cima"
				),
				make_dialogue_line(
					"Gabriel",
					"Boa sorte! Sua jornada começa agora.",
					"joinha"
				)
			]

		"emanuel_intro":
			return [
				make_dialogue_line(
					"Emanuel",
					"Oppa, nem percebi que você estava aí! Olá! Eu sou Emanuel.",
					"base"
				),
				make_dialogue_line(
					"Emanuel",
					"Bem-vindo à Incode. Aqui damos os primeiros passos no universo da programação.",
					"joinha"
				),
				make_dialogue_line(
					"Emanuel",
					"Programar é aprender a resolver problemas usando lógica.",
					"explicando"
				),
				make_dialogue_line(
					"Emanuel",
					"Não importa se você nunca escreveu uma linha de código. Todo desenvolvedor começou exatamente do zero.",
					"base"
				),
				make_dialogue_line(
					"Emanuel",
					"Na Incode você aprenderá linguagens como Python, entenderá algoritmos e desenvolverá raciocínio lógico para construir sistemas.",
					"explicando"
				),
				make_dialogue_line(
					"Emanuel",
					"Antes de continuar, quero fazer algumas perguntas para saber se você está preparado.",
					"aponta_cima"
				)
			]

		"laura_intro":
			return [
				make_dialogue_line(
					"Laura",
					"Oie! Eu sou a Laura. Seja bem-vindo à TechX.",
					"feliz"
				),
				make_dialogue_line(
					"Laura",
					"Aqui transformamos ideias em experiências visuais.",
					"base"
				),
				make_dialogue_line(
					"Laura",
					"Um sistema precisa funcionar bem, mas também precisa ser agradável, organizado e fácil de usar.",
					"explicando"
				),
				make_dialogue_line(
					"Laura",
					"No Front-end criamos tudo aquilo que o usuário vê e utiliza.",
					"base"
				),
				make_dialogue_line(
					"Laura",
					"Botões, menus, telas, animações e páginas fazem parte desse universo.",
					"feliz"
				),
				make_dialogue_line(
					"Laura",
					"Agora quero ver se você já aprendeu alguns conceitos.",
					"explicando"
				)
			]

		"mb_intro":
			return [
				make_dialogue_line(
					"MB",
					"Parabéns. Você chegou até aqui porque demonstrou dedicação.",
					"base"
				),
				make_dialogue_line(
					"MB",
					"Eu sou Marcos Barros. Antes de entregar sua Faixa Branca, quero apresentar a terceira trilha.",
					"joinha"
				),
				make_dialogue_line(
					"MB",
					"Enquanto o Front-end mostra tudo o que o usuário vê, o Back-end faz todo o trabalho por trás das telas.",
					"explicando"
				),
				make_dialogue_line(
					"MB",
					"É nele que ficam as regras do sistema, os servidores, os bancos de dados e a lógica que faz as aplicações funcionarem.",
					"base"
				),
				make_dialogue_line(
					"MB",
					"Em outras palavras: se o Front-end é a vitrine, o Back-end é o motor que faz tudo acontecer.",
					"explicando"
				),
				make_dialogue_line(
					"MB",
					"Agora falta um último desafio sobre o Oxygeni Hub.",
					"controle"
				)
			]

		_:
			return npc.get_default_dialogue()


func make_dialogue_line(
	speaker_name: String,
	text: String,
	expression_name: String = "base"
) -> Dictionary:
	return {
		"speaker": speaker_name,
		"text": text,
		"expression": expression_name,
		"portrait": get_character_portrait(
			speaker_name,
			expression_name
		)
	}


func get_character_portrait(
	speaker_name: String,
	expression_name: String = "base"
) -> Texture2D:
	if speaker_name == player_dialogue_name:
		return player_portrait

	var npc_value: Variant = npc_by_name.get(
		speaker_name,
		null
	)

	if npc_value is NPC:
		var npc: NPC = npc_value as NPC
		return npc.get_portrait_for_expression(expression_name)

	return null


# =========================================================
# PERGUNTAS ALEATÓRIAS
# =========================================================

func _on_dialogue_finished() -> void:
	if active_dialogue_npc == null:
		return

	var finished_npc: NPC = active_dialogue_npc
	active_dialogue_npc = null

	var question_pool: Array[Dictionary] = (
		get_questions_for_npc(finished_npc)
	)

	if question_pool.is_empty():
		finish_npc_interaction(finished_npc)
		clear_current_interaction()
		return

	var random_question_value: Variant = (
		question_pool.pick_random()
	)

	var random_question: Dictionary = (
		random_question_value as Dictionary
	)

	pending_question_npc = finished_npc

	question_box.start_question(
		random_question
	)


func get_questions_for_npc(
	npc: NPC
) -> Array[Dictionary]:
	match npc.dialogue_id:
		"emanuel_intro":
			return [
				{
					"question": "A Incode Tech School é conhecida como:",
					"answers": [
						"Escola de Marketing Digital",
						"Escola de Programação da Vida Real",
						"Escola de Administração Empresarial"
					],
					"correct_answer": 1,
					"theme": QuestionBox.QuestionTheme.INCODE
				},
				{
					"question": "Quantos módulos compõem a formação principal da Incode Tech School?",
					"answers": [
						"2 módulos",
						"3 módulos",
						"6 módulos"
					],
					"correct_answer": 1,
					"theme": QuestionBox.QuestionTheme.INCODE
				},
				{
					"question": "Qual diferencial existe no terceiro módulo da Incode?",
					"answers": [
						"É focado só em teoria",
						"Possui parceria com empresas e desafios reais",
						"É voltado só para inteligência artificial"
					],
					"correct_answer": 1,
					"theme": QuestionBox.QuestionTheme.INCODE
				},
				{
					"question": "Qual metodologia faz parte da proposta da Incode?",
					"answers": [
						"Aprendizagem baseada em desafios",
						"Apenas aulas expositivas",
						"Ensino exclusivamente por provas"
					],
					"correct_answer": 0,
					"theme": QuestionBox.QuestionTheme.INCODE
				}
			]

		"laura_intro":
			return [
				{
					"question": "Qual é a principal proposta do TechX?",
					"answers": [
						"Criar uma competição esportiva",
						"Aproximar pessoas de tecnologias e inovação",
						"Oferecer somente aulas de matemática"
					],
					"correct_answer": 1,
					"theme": QuestionBox.QuestionTheme.HUB
				},
				{
					"question": "Qual abordagem combina com uma experiência TechX?",
					"answers": [
						"Aprender tecnologia apenas pela teoria",
						"Experimentar, criar e colocar em prática",
						"Decorar conceitos sem projetos"
					],
					"correct_answer": 1,
					"theme": QuestionBox.QuestionTheme.HUB
				},
				{
					"question": "Qual tecnologia pode estar relacionada ao TechX?",
					"answers": [
						"Inteligência Artificial",
						"Robótica",
						"Todas as alternativas anteriores"
					],
					"correct_answer": 2,
					"theme": QuestionBox.QuestionTheme.HUB
				},
				{
					"question": "Qual é uma vantagem do TechX para estudantes?",
					"answers": [
						"Contato prático com tecnologias e carreiras",
						"Evitar profissionais do mercado",
						"Trabalhar somente conteúdos teóricos"
					],
					"correct_answer": 0,
					"theme": QuestionBox.QuestionTheme.HUB
				}
			]

		"mb_intro":
			return [
				{
					"question": "Qual é a proposta central do Oxygeni Hub?",
					"answers": [
						"Ser apenas um espaço de eventos",
						"Conectar pessoas, empresas e tecnologia",
						"Oferecer somente cursos de programação"
					],
					"correct_answer": 1,
					"theme": QuestionBox.QuestionTheme.HUB
				},
				{
					"question": "Qual ambiente tecnológico é ligado ao Oxygeni Hub?",
					"answers": [
						"LIA - Laboratório de Inteligência Artificial",
						"LIFA - Laboratório de Finanças Aplicadas",
						"LEMA - Laboratório de Marketing"
					],
					"correct_answer": 0,
					"theme": QuestionBox.QuestionTheme.HUB
				},
				{
					"question": "Quais públicos o Oxygeni Hub busca aproximar?",
					"answers": [
						"Apenas estudantes e professores",
						"Talentos, professores, empresas e comunidade",
						"Apenas investidores e empresários"
					],
					"correct_answer": 1,
					"theme": QuestionBox.QuestionTheme.HUB
				},
				{
					"question": "Qual atividade pode acontecer no Oxygeni Hub com empresas?",
					"answers": [
						"Hackathons e desafios corporativos",
						"Apenas aulas tradicionais",
						"Apenas competições esportivas"
					],
					"correct_answer": 0,
					"theme": QuestionBox.QuestionTheme.HUB
				}
			]

		_:
			return []


func _on_question_answered(
	was_correct: bool,
	_selected_index: int
) -> void:
	await question_box.close_question_box()

	if pending_question_npc == null:
		return

	var answered_npc: NPC = pending_question_npc
	pending_question_npc = null

	if was_correct:
		rewarded_npc = answered_npc

		var pin_id: String = (
			answered_npc.dialogue_id
		)

		if not collected_pins.has(pin_id):
			collected_pins.append(pin_id)

		reward_box.show_reward(
			answered_npc.pin_texture,
			answered_npc.pin_name
		)

	else:
		game_over_box.show_game_over()


# =========================================================
# PIN E GAME OVER
# =========================================================

func _on_reward_closed() -> void:
	if rewarded_npc == null:
		return

	var completed_npc: NPC = rewarded_npc
	rewarded_npc = null

	finish_npc_interaction(completed_npc)
	clear_current_interaction()

	if collected_pins.size() >= 3:
		print(
			"Parabéns! Todos os pins foram coletados."
		)


func _on_restart_requested() -> void:
	get_tree().reload_current_scene()


# =========================================================
# SETA DE OBJETIVO
# =========================================================

func update_objective_arrow() -> void:
	var closest_npc: NPC = get_closest_available_npc()

	for npc: NPC in npc_objective_order:
		npc.hide_objective_arrow()

	if closest_npc == null:
		player.hide_objective_arrow()
		return

	player.point_objective_arrow_to(closest_npc.global_position)


func get_closest_available_npc() -> NPC:
	var closest_npc: NPC = null
	var closest_distance := INF

	for npc: NPC in npc_objective_order:
		if not npc.interaction_enabled:
			continue

		var distance: float = player.global_position.distance_squared_to(
			npc.global_position
		)

		if distance < closest_distance:
			closest_distance = distance
			closest_npc = npc

	return closest_npc


func finish_npc_interaction(npc: NPC) -> void:
	if completed_npcs.has(npc):
		return

	completed_npcs.append(npc)
	npc.set_interaction_enabled(false)

	update_objective_arrow()


# =========================================================
# INTERFACE
# =========================================================

func show_hint_animation() -> void:
	interaction_hint.modulate.a = 0.0
	interaction_hint.show()

	var tween: Tween = create_tween()

	tween.tween_property(
		interaction_hint,
		"modulate:a",
		1.0,
		0.2
	)


func hide_interaction_hint() -> void:
	hint_is_visible = false
	interaction_hint.hide()


func clear_current_interaction() -> void:
	target_npc = null
	nearby_npc = null

	hide_interaction_hint()
