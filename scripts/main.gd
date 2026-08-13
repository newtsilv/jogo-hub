extends Node2D


@export_category("Interação")
@export var hint_distance: float = 200.0


@export_category("Player")
@export var player_dialogue_name: String = "Player"
@export var player_portrait: Texture2D


@export_category("Navegação")
@export_file("*.tscn") var main_menu_scene_path: String = (
	"res://scenes/main_menu.tscn"
)


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


@onready var entities: Node2D = $World/Entities
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

@onready var pause_menu: PauseMenu = (
	$UI/Pause/PauseMenu
)

@onready var interaction_hint: Label = (
	$UI/InteractionHint
)

@onready var pause_button: TextureButton = (
	$UI/HUD/PauseButton
)


func _ready() -> void:
	interaction_hint.hide()
	dialogue_box.hide()
	question_box.hide()
	reward_box.hide()
	game_over_box.hide()
	pause_menu.hide()

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
	player.move_to(world_position)


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

	player.move_to(
		npc.interaction_point.global_position
	)


func show_npc_hint() -> void:
	if nearby_npc == null:
		return

	hint_is_visible = true

	interaction_hint.text = (
		"Toque em %s para conversar"
		% nearby_npc.character_name
	)

	show_hint_animation()


func open_npc_dialogue(npc: NPC) -> void:
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
					"Opa, Gabriel sou eu."
				),
				make_dialogue_line(
					"Player",
					"Onde fica tal sala, sei lá?"
				),
				make_dialogue_line(
					"Gabriel",
					"Antes disso, responde uma pergunta."
				)
			]

		"emanuel_intro":
			return [
				make_dialogue_line(
					"Emanuel",
					"Sou Emanuel."
				),
				make_dialogue_line(
					"Player",
					"Diálogo."
				),
				make_dialogue_line(
					"Emanuel",
					"Responde essa pergunta aí."
				)
			]

		"laura_intro":
			return [
				make_dialogue_line(
					"Laura",
					"Oiii."
				),
				make_dialogue_line(
					"Player",
					"O que tenho que fazer agora?"
				),
				make_dialogue_line(
					"Laura",
					"Acertar minha pergunta."
				)
			]

		_:
			return npc.get_default_dialogue()


func make_dialogue_line(
	speaker_name: String,
	text: String
) -> Dictionary:
	return {
		"speaker": speaker_name,
		"text": text,
		"portrait": get_character_portrait(
			speaker_name
		)
	}


func get_character_portrait(
	speaker_name: String
) -> Texture2D:
	if speaker_name == player_dialogue_name:
		return player_portrait

	var npc_value: Variant = npc_by_name.get(
		speaker_name,
		null
	)

	if npc_value is NPC:
		var npc: NPC = npc_value as NPC
		return npc.portrait

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
		"gabriel_intro":
			return [
				{
					"question": "Quantos anos tem a Incode?",
					"answers": [
						"2 anos",
						"4 anos",
						"6 anos"
					],
					"correct_answer": 2,
					"theme": QuestionBox.QuestionTheme.INCODE
				},
				{
					"question": "A Incode trabalha principalmente com:",
					"answers": [
						"Inovação e tecnologia",
						"Turismo",
						"Culinária"
					],
					"correct_answer": 0,
					"theme": QuestionBox.QuestionTheme.INCODE
				},
				{
					"question": "Qual destas opções combina com a Incode?",
					"answers": [
						"Criação de soluções",
						"Evitar tecnologia",
						"Somente trabalho manual"
					],
					"correct_answer": 0,
					"theme": QuestionBox.QuestionTheme.INCODE
				}
			]

		"emanuel_intro":
			return [
				{
					"question": "Qual é uma função do Hub?",
					"answers": [
						"Conectar pessoas e projetos",
						"Vender roupas",
						"Organizar campeonatos"
					],
					"correct_answer": 0,
					"theme": QuestionBox.QuestionTheme.HUB
				},
				{
					"question": "O Hub incentiva principalmente:",
					"answers": [
						"Inovação e colaboração",
						"Isolamento",
						"Trabalho sem equipe"
					],
					"correct_answer": 0,
					"theme": QuestionBox.QuestionTheme.HUB
				},
				{
					"question": "O Hub serve como espaço para:",
					"answers": [
						"Projetos e ideias",
						"Somente armazenamento",
						"Somente vendas"
					],
					"correct_answer": 0,
					"theme": QuestionBox.QuestionTheme.HUB
				}
			]

		"laura_intro":
			return [
				{
					"question": "O TechX está relacionado a:",
					"answers": [
						"Tecnologia",
						"Culinária",
						"Turismo"
					],
					"correct_answer": 0,
					"theme": QuestionBox.QuestionTheme.HUB
				},
				{
					"question": "Qual opção combina com o TechX?",
					"answers": [
						"Experimentação tecnológica",
						"Evitar novas ideias",
						"Eliminar projetos digitais"
					],
					"correct_answer": 0,
					"theme": QuestionBox.QuestionTheme.HUB
				},
				{
					"question": "O TechX estimula:",
					"answers": [
						"Novas soluções",
						"Menos criatividade",
						"Isolamento entre equipes"
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
			"Parabéns! Os três pins foram coletados."
		)


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
	for npc: NPC in npc_objective_order:
		npc.hide_objective_arrow()

	if (
		current_npc_objective_index
		>= npc_objective_order.size()
	):
		return

	var current_objective_npc: NPC = (
		npc_objective_order[
			current_npc_objective_index
		]
	)

	current_objective_npc.show_objective_arrow()


func finish_npc_interaction(npc: NPC) -> void:
	if (
		current_npc_objective_index
		>= npc_objective_order.size()
	):
		return

	var current_objective_npc: NPC = (
		npc_objective_order[
			current_npc_objective_index
		]
	)

	if npc != current_objective_npc:
		return

	current_npc_objective_index += 1
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
