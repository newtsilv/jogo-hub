extends Node2D

const ClickIndicatorScript := preload("res://scripts/click_indicator.gd")
const PIN_HUD_ICON_SIZE := Vector2(32, 32)
const PIN_HUD_REVEAL_SCALE := Vector2(0.8, 0.8)

@export_category("Interação")
@export var hint_distance: float = 200.0

@export_category("Player")
@export var player_dialogue_name: String = "Player"
@export var player_portrait: Texture2D

@export_category("Mensagens de Pin")
@export var incode_reward_message: Texture2D
@export var techx_reward_message: Texture2D
@export var oxygeni_reward_message: Texture2D

@export_category("Crachá final")
@export var pedro_badge: Texture2D
@export var maria_badge: Texture2D

@export_category("Câmera de objetivo")
@export var objective_preview_travel_duration: float = 2.6
@export var objective_preview_hold_duration: float = 0.45

@export_category("Navegação")
@export_file("*.tscn") var main_menu_scene_path: String = (
	"res://scenes/cena1.tscn"
)


var target_npc: NPC = null
var nearby_npc: NPC = null

var hint_is_visible: bool = false

var npc_objective_order: Array[NPC] = []
var current_npc_objective_index: int = 0

var active_dialogue_npc: NPC = null
var pending_question_npc: NPC = null
var rewarded_npc: NPC = null
var pending_congratulation_npc: NPC = null
var pending_objective_preview_npc: NPC = null
var pending_game_over_dialogue: bool = false
var pending_blocked_order_dialogue: bool = false
var pending_final_badge: bool = false

# Impede o jogador de se mover enquanto a câmera de objetivo está
# fazendo o passeio até o próximo NPC.
var is_previewing_objective: bool = false

var npc_by_name: Dictionary = {}

var collected_pins: Array[String] = []
var completed_npcs: Array[NPC] = []
var objective_preview_tween: Tween

@onready var entities: Node2D = $World/Entities
@onready var world: Node2D = $World
@onready var player: Player = $World/Entities/Player

@onready var objective_preview_camera: Camera2D = (
	$ObjectivePreviewCamera
)


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

@onready var pause_menu: PauseMenu = (
	$UI/Pause/PauseMenu
)

@onready var interaction_hint: Label = (
	$UI/InteractionHint
)

@onready var pause_button: TextureButton = (
	$UI/HUD/PauseButton
)

@onready var background_focus_overlay: ColorRect = (
	$UI/BackgroundFocusOverlay
)

@onready var pin_hud_slots: Array[TextureRect] = [
	$UI/HUD/PinHudSlot1,
	$UI/HUD/PinHudSlot2,
	$UI/HUD/PinHudSlot3
]

func _ready() -> void:
	interaction_hint.hide()
	dialogue_box.hide()
	question_box.hide()
	reward_box.hide()
	game_over_box.hide()
	pause_menu.hide()
	background_focus_overlay.hide()

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

	pause_menu.restart_requested.connect(
		_on_restart_requested
	)

	pause_menu.main_menu_requested.connect(
		_on_pause_main_menu_requested
	)

	pause_button.pressed.connect(
		_on_pause_button_pressed
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
		or is_previewing_objective
	)


func show_focus_overlay() -> void:
	background_focus_overlay.show()
	background_focus_overlay.modulate.a = 0.0

	var tween: Tween = create_tween()
	tween.tween_property(
		background_focus_overlay,
		"modulate:a",
		1.0,
		0.16
	)


func hide_focus_overlay() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(
		background_focus_overlay,
		"modulate:a",
		0.0,
		0.12
	)

	await tween.finished
	background_focus_overlay.hide()


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

	var required_npc: NPC = get_required_npc()
	if required_npc != null:
		if npc != required_npc:
			pending_blocked_order_dialogue = true
			show_focus_overlay()
			dialogue_box.start_dialogue(
				get_blocked_order_dialogue(npc, required_npc)
			)
			return

	active_dialogue_npc = npc

	var conversation: Array[Dictionary] = (
		get_npc_conversation(npc)
	)

	show_focus_overlay()
	dialogue_box.start_dialogue(conversation)


func get_required_npc() -> NPC:
	for npc: NPC in npc_objective_order:
		if completed_npcs.has(npc):
			continue

		if not npc.interaction_enabled:
			continue

		return npc

	return null


func get_blocked_order_dialogue(
	attempted_npc: NPC,
	required_npc: NPC
) -> Array[Dictionary]:
	return [
		make_dialogue_line(
			attempted_npc.character_name,
			"Fale com %s antes." % required_npc.character_name,
			"aponta_cima"
		)
	]


func get_npc_conversation(
	npc: NPC
) -> Array[Dictionary]:
	match npc.dialogue_id:
		"gabriel_intro":
			return [
				make_dialogue_line(
					"Gabriel",
					"Opa! Gabriel sou eu.",
					"base"
				),
				make_dialogue_line(
					"Gabriel",
					"Seja bem-vindo ao Oxygeni Hub!",
					"joinha"
				),
				make_dialogue_line(
					"Gabriel",
					"Aqui você vai aprender, criar e transformar ideias em soluções.",
					"explicando"
				),
				make_dialogue_line(
					"Gabriel",
					"Hoje começa sua primeira missão: conquistar a Faixa Branca.",
					"aponta_cima"
				),
				make_dialogue_line(
					"Gabriel",
					"Para isso, visite nossos especialistas, complete os desafios e conquiste os 3 Pins da Jornada.",
					"joinha"
				),
				make_dialogue_line(
					"Gabriel",
					"Cada Pin representa um novo conhecimento.",
					"base"
				),
				make_dialogue_line(
					"Gabriel",
					"Quando conseguir os três, procure o professor Marcos Barros.",
					"explicando"
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
					"Opa! Nem percebi que você estava aí!",
					"base"
				),
				make_dialogue_line(
					"Emanuel",
					"Eu sou o Emanuel. Bem-vindo à Incode!",
					"aponta_cima"
				),
				make_dialogue_line(
					"Emanuel",
					"Aqui você dá os primeiros passos na programação.",
					"pensante"
				),
				make_dialogue_line(
					"Emanuel",
					"Programar é usar a lógica para resolver problemas e criar soluções.",
					"base"
				),
				make_dialogue_line(
					"Emanuel",
					"Você vai conhecer linguagens como Python, aprender algoritmos e desenvolver seu raciocínio lógico.",
					"pensante"
				),
				make_dialogue_line(
					"Emanuel",
					"Mas antes, vamos ver o que você já sabe!",
					"aponta_cima"
				)
			]

		"laura_intro":
			return [
				make_dialogue_line(
					"Laura",
					"Oie! Eu sou a Laura.",
					"feliz"
				),
				make_dialogue_line(
					"Laura",
					"Bem-vindo à TechX!",
					"base"
				),
				make_dialogue_line(
					"Laura",
					"Aqui transformamos ideias em experiências.",
					"explicando"
				),
				make_dialogue_line(
					"Laura",
					"No Front-end, criamos aquilo que o usuário vê e utiliza: telas, botões, menus e páginas.",
					"base"
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
					"Marcos Barros",
					"Parabéns por chegar até aqui!",
					"base"
				),
				make_dialogue_line(
					"Marcos Barros",
					"Eu sou o professor Marcos Barros.",
					"joinha"
				),
				make_dialogue_line(
					"Marcos Barros",
					"Você já conquistou dois Pins. Agora falta conhecer o último desafio.",
					"explicando"
				),
				make_dialogue_line(
					"Marcos Barros",
					"O Oxygeni Hub conecta pessoas, tecnologia, inovação e empreendedorismo.",
					"base"
				),
				make_dialogue_line(
					"Marcos Barros",
					"Aqui você pode aprender, criar projetos e transformar ideias em soluções.",
					"explicando"
				),
				make_dialogue_line(
					"Marcos Barros",
					"Agora vamos descobrir se você conhece o Hub.",
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
		"profession": get_character_profession(speaker_name),
		"text": text,
		"expression": expression_name,
		"portrait": get_character_portrait(
			speaker_name,
			expression_name
		)
	}


func get_character_profession(speaker_name: String) -> String:
	match speaker_name:
		"Gabriel", "Emanuel":
			return "Programador"

		"Laura":
			return "Programadora"

		"Marcos Barros":
			return "Professor"

		_:
			return ""


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
	if pending_blocked_order_dialogue:
		pending_blocked_order_dialogue = false
		hide_focus_overlay()
		return

	if pending_objective_preview_npc != null:
		pending_objective_preview_npc = null
		hide_focus_overlay()
		preview_next_objective()
		return

	if pending_game_over_dialogue:
		pending_game_over_dialogue = false
		game_over_box.show_game_over()
		return

	if pending_congratulation_npc != null:
		var completed_npc: NPC = pending_congratulation_npc
		pending_congratulation_npc = null
		complete_rewarded_npc(completed_npc)
		return

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
		hide_focus_overlay()
		preview_next_objective()
		return

	var random_question_value: Variant = (
		question_pool.pick_random()
	)

	var random_question: Dictionary = (
		random_question_value as Dictionary
	)

	pending_question_npc = finished_npc

	show_focus_overlay()
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
						"Escola de Design"
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
						"Foco apenas em teoria",
						"Parcerias com empresas e desafios reais",
						"Foco exclusivo em IA"
					],
					"correct_answer": 1,
					"theme": QuestionBox.QuestionTheme.INCODE
				},
				{
					"question": "Qual metodologia faz parte da proposta da Incode?",
					"answers": [
						"Aprendizagem baseada em desafios",
						"Apenas aulas expositivas",
						"Apenas provas"
					],
					"correct_answer": 0,
					"theme": QuestionBox.QuestionTheme.INCODE
				}
			]

		"laura_intro":
			return [
				{
					"question": "Qual é a principal proposta da TechX?",
					"answers": [
						"Competição esportiva",
						"Aproximar pessoas de tecnologias e experiências práticas de inovação",
						"Aulas de matemática"
					],
					"correct_answer": 1,
					"theme": QuestionBox.QuestionTheme.TECHX
				},
				{
					"question": "Qual abordagem combina com a proposta da TechX?",
					"answers": [
						"Apenas teoria",
						"Experimentar, criar e colocar em prática",
						"Decorar conceitos"
					],
					"correct_answer": 1,
					"theme": QuestionBox.QuestionTheme.TECHX
				},
				{
					"question": "Qual tecnologia pode fazer parte dos projetos da TechX?",
					"answers": [
						"Inteligência Artificial",
						"Robótica",
						"Todas as alternativas"
					],
					"correct_answer": 2,
					"theme": QuestionBox.QuestionTheme.TECHX
				},
				{
					"question": "Qual uma das vantagens da TechX?",
					"answers": [
						"Contato prático com tecnologias e novas carreiras",
						"Evitar profissionais do mercado",
						"Apenas conteúdos teóricos"
					],
					"correct_answer": 0,
					"theme": QuestionBox.QuestionTheme.TECHX
				}
			]

		"mb_intro":
			return [
				{
					"question": "Qual é a proposta central do Oxygeni Hub?",
					"answers": [
						"Apenas realizar eventos",
						"Conectar pessoas, empresas, tecnologia, inovação e empreendedorismo",
						"Oferecer apenas programação"
					],
					"correct_answer": 1,
					"theme": QuestionBox.QuestionTheme.HUB
				},
				{
					"question": "Qual ambiente tecnológico é ligado ao Oxygeni Hub?",
					"answers": [
						"LIA - Laboratório de Inteligência Artificial",
						"LIFA - Laboratório de Finanças",
						"LEMA - Laboratório de Marketing"
					],
					"correct_answer": 0,
					"theme": QuestionBox.QuestionTheme.HUB
				},
				{
					"question": "Quais públicos o Oxygeni Hub busca aproximar?",
					"answers": [
						"Apenas estudantes e professores",
						"Talentos, professores, empresas e comunidade acadêmica",
						"Apenas investidores"
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
			show_collected_pin(answered_npc.pin_texture)

		show_focus_overlay()
		await reward_box.show_reward(
			get_reward_message_texture(answered_npc),
			answered_npc.pin_name
		)
		reward_box.input_enabled = false
		open_congratulation_dialogue(answered_npc)

	else:
		open_wrong_answer_dialogue(answered_npc)


# =========================================================
# PIN E GAME OVER
# =========================================================

func open_wrong_answer_dialogue(npc: NPC) -> void:
	pending_game_over_dialogue = true
	show_focus_overlay()
	dialogue_box.start_dialogue(
		get_wrong_answer_dialogue(npc)
	)


func get_wrong_answer_dialogue(npc: NPC) -> Array[Dictionary]:
	match npc.dialogue_id:
		"emanuel_intro":
			return [
				make_dialogue_line(
					"Emanuel",
					"Faz parte! Errar também é aprender. Vamos tentar novamente.",
					"base"
				)
			]

		"laura_intro":
			return [
				make_dialogue_line(
					"Laura",
					"Quase! Revise com calma e tente de novo.",
					"explicando"
				)
			]

		"mb_intro":
			return [
				make_dialogue_line(
					"Marcos Barros",
					"Quase! Lembre-se do que aprendeu durante a jornada. Tenho certeza de que você consegue!",
					"controle"
				)
			]

		_:
			return [
				make_dialogue_line(
					"Gabriel",
					"Quase! Tente novamente.",
					"base"
				)
			]


func open_congratulation_dialogue(npc: NPC) -> void:
	pending_congratulation_npc = npc
	show_focus_overlay()
	dialogue_box.start_dialogue(
		get_congratulation_dialogue(npc)
	)


func get_congratulation_dialogue(npc: NPC) -> Array[Dictionary]:
	match npc.dialogue_id:
		"emanuel_intro":
			return [
				make_dialogue_line(
					"Emanuel",
					"Mandou bem! Você conquistou o Pin Incode.",
					"aponta_cima"
				)
			]

		"laura_intro":
			return [
				make_dialogue_line(
					"Laura",
					"Muito bem! Você conquistou o Pin TechX.",
					"feliz"
				)
			]

		"mb_intro":
			return [
				make_dialogue_line(
					"Marcos Barros",
					"Excelente! Você completou sua primeira jornada no Oxygeni Hub.",
					"joinha"
				)
			]

		_:
			return [
				make_dialogue_line(
					"Gabriel",
					"Parabéns! Você conquistou um novo Pin.",
					"joinha"
				)
			]


func get_reward_message_texture(npc: NPC) -> Texture2D:
	match npc.dialogue_id:
		"emanuel_intro":
			return incode_reward_message if incode_reward_message != null else npc.pin_texture

		"laura_intro":
			return techx_reward_message if techx_reward_message != null else npc.pin_texture

		"mb_intro":
			return oxygeni_reward_message if oxygeni_reward_message != null else npc.pin_texture

		_:
			return npc.pin_texture


func show_collected_pin(pin_texture: Texture2D) -> void:
	var slot_index: int = collected_pins.size() - 1

	if slot_index < 0:
		return

	if slot_index >= pin_hud_slots.size():
		return

	var slot: TextureRect = pin_hud_slots[slot_index]
	slot.custom_minimum_size = PIN_HUD_ICON_SIZE
	slot.size = PIN_HUD_ICON_SIZE
	slot.texture = pin_texture
	slot.show()

	slot.pivot_offset = slot.size / 2.0
	slot.scale = PIN_HUD_REVEAL_SCALE

	var tween: Tween = create_tween()
	tween.tween_property(
		slot,
		"scale",
		Vector2.ONE,
		0.22
	).set_trans(
		Tween.TRANS_BACK
	).set_ease(
		Tween.EASE_OUT
	)


func _on_reward_closed() -> void:
	if pending_final_badge:
		pending_final_badge = false
		get_tree().change_scene_to_file(
			"res://scenes/cena1.tscn"
		)
		return

	rewarded_npc = null


func complete_rewarded_npc(completed_npc: NPC) -> void:
	if reward_box.reward_is_open:
		reward_box.close_reward()

	hide_focus_overlay()

	finish_npc_interaction(completed_npc)
	clear_current_interaction()

	if collected_pins.size() >= 3:
		show_final_badge()
		return

	open_next_objective_dialogue(completed_npc)


func open_next_objective_dialogue(completed_npc: NPC) -> void:
	var next_npc: NPC = get_required_npc()
	if next_npc == null:
		preview_next_objective()
		return

	pending_objective_preview_npc = next_npc
	show_focus_overlay()
	dialogue_box.start_dialogue(
		get_next_objective_dialogue(completed_npc, next_npc)
	)


func get_next_objective_dialogue(
	completed_npc: NPC,
	next_npc: NPC
) -> Array[Dictionary]:
	return [
		make_dialogue_line(
			completed_npc.character_name,
			"Agora fale com %s." % next_npc.character_name,
			"aponta_cima"
		)
	]


func show_final_badge() -> void:
	pending_final_badge = true
	show_focus_overlay()
	await reward_box.show_reward(
		get_final_badge_texture(),
		"Crachá"
	)


func get_final_badge_texture() -> Texture2D:
	if GameState.selected_character == GameState.Character.MARIA:
		return maria_badge

	return pedro_badge


func _on_restart_requested() -> void:
	get_tree().reload_current_scene()


func _on_pause_main_menu_requested() -> void:
	get_tree().change_scene_to_file(main_menu_scene_path)


func _on_pause_button_pressed() -> void:
	pause_menu.open_pause_menu()


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
	return get_required_npc()


func finish_npc_interaction(npc: NPC) -> void:
	if completed_npcs.has(npc):
		return

	completed_npcs.append(npc)
	npc.set_interaction_enabled(false)

	update_objective_arrow()


func preview_next_objective() -> void:
	var next_npc: NPC = get_closest_available_npc()

	if next_npc == null:
		return

	if objective_preview_tween != null:
		objective_preview_tween.kill()
		player.make_camera_current()

	is_previewing_objective = true
	player.stop_movement()

	objective_preview_camera.global_position = player.global_position
	objective_preview_camera.enabled = true
	objective_preview_camera.make_current()

	objective_preview_tween = create_tween()

	objective_preview_tween.tween_property(
		objective_preview_camera,
		"global_position",
		next_npc.global_position,
		objective_preview_travel_duration
	).set_trans(
		Tween.TRANS_SINE
	).set_ease(
		Tween.EASE_IN_OUT
	)

	objective_preview_tween.tween_interval(
		objective_preview_hold_duration
	)

	objective_preview_tween.tween_property(
		objective_preview_camera,
		"global_position",
		player.global_position,
		objective_preview_travel_duration
	).set_trans(
		Tween.TRANS_SINE
	).set_ease(
		Tween.EASE_IN_OUT
	)

	objective_preview_tween.finished.connect(
		_on_objective_preview_finished
	)


func _on_objective_preview_finished() -> void:
	objective_preview_camera.global_position = player.global_position
	player.make_camera_current()
	objective_preview_camera.enabled = false
	is_previewing_objective = false


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
