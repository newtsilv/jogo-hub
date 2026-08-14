class_name DialogueBox
extends Control

signal dialogue_finished


@export_category("Animação da caixa")
@export var animation_duration: float = 0.25
@export var entrance_offset: float = 80.0


@export_category("Animação do texto")
@export var characters_per_second: float = 35.0


@export_category("Fundos por tema")
@export var default_background: Texture2D
@export var incode_background: Texture2D
@export var techx_background: Texture2D


@onready var portrait: TextureRect = $Portrait
@onready var textbox_background: TextureRect = $TextboxBackground
@onready var character_name_label: Label = $CharacterName
@onready var character_profession_label: Label = $CharacterProfession
@onready var dialogue_text_label: RichTextLabel = $DialogText


var dialogue_lines: Array[Dictionary] = []
var current_line_index: int = 0

var current_tween: Tween
var typing_tween: Tween
var portrait_tween: Tween

var original_position: Vector2
var dialogue_is_open: bool = false
var dialogue_is_closing: bool = false
var is_typing: bool = false


func _ready() -> void:
	original_position = position
	hide()


func _unhandled_input(event: InputEvent) -> void:
	if not dialogue_is_open:
		return

	var was_pressed: bool = false

	if event is InputEventScreenTouch:
		was_pressed = event.pressed

	elif event is InputEventMouseButton:
		was_pressed = (
			event.button_index == MOUSE_BUTTON_LEFT
			and event.pressed
		)

	if not was_pressed:
		return

	get_viewport().set_input_as_handled()

	if is_typing:
		finish_typing()
	else:
		next_line()


func start_dialogue(lines: Array[Dictionary]) -> void:
	if lines.is_empty():
		return

	dialogue_lines = lines
	current_line_index = 0
	dialogue_is_open = true
	dialogue_is_closing = false

	show()
	animate_opening()
	show_current_line()


func show_current_line() -> void:
	if current_line_index >= dialogue_lines.size():
		close_dialogue()
		return

	if typing_tween != null:
		typing_tween.kill()

	var line: Dictionary = dialogue_lines[current_line_index]

	var speaker_name: String = line.get(
		"speaker",
		"Desconhecido"
	)

	var dialogue_text: String = line.get(
		"text",
		""
	)
	var character_profession: String = line.get(
		"profession",
		""
	)

	var portrait_texture: Texture2D = line.get(
		"portrait",
		null
	)

	textbox_background.texture = get_background_for_speaker(speaker_name)
	character_name_label.text = speaker_name
	character_profession_label.text = character_profession
	show_portrait(portrait_texture)

	dialogue_text_label.text = dialogue_text
	dialogue_text_label.visible_characters = 0

	start_typing(dialogue_text)


func get_background_for_speaker(speaker_name: String) -> Texture2D:
	match speaker_name:
		"Emanuel":
			return incode_background if incode_background != null else default_background

		"Laura":
			return techx_background if techx_background != null else default_background

		_:
			return default_background


func show_portrait(portrait_texture: Texture2D) -> void:
	if portrait.texture == portrait_texture:
		return

	if portrait_tween != null:
		portrait_tween.kill()

	portrait.texture = portrait_texture
	portrait.pivot_offset = portrait.size / 2.0
	portrait.modulate.a = 0.0
	portrait.scale = Vector2.ONE * 0.96

	portrait_tween = create_tween()
	portrait_tween.set_parallel(true)

	portrait_tween.tween_property(
		portrait,
		"modulate:a",
		1.0,
		0.18
	)

	portrait_tween.tween_property(
		portrait,
		"scale",
		Vector2.ONE,
		0.18
	).set_trans(
		Tween.TRANS_SINE
	).set_ease(
		Tween.EASE_OUT
	)


func start_typing(text: String) -> void:
	is_typing = true

	var character_count: int = text.length()

	if character_count == 0:
		is_typing = false
		return

	var typing_duration: float = (
		float(character_count) / characters_per_second
	)

	typing_tween = create_tween()

	typing_tween.tween_property(
		dialogue_text_label,
		"visible_characters",
		character_count,
		typing_duration
	)

	typing_tween.finished.connect(
		_on_typing_finished
	)


func finish_typing() -> void:
	if typing_tween != null:
		typing_tween.kill()

	dialogue_text_label.visible_characters = -1
	is_typing = false


func _on_typing_finished() -> void:
	dialogue_text_label.visible_characters = -1
	is_typing = false


func next_line() -> void:
	if is_typing:
		finish_typing()
		return

	current_line_index += 1

	if current_line_index >= dialogue_lines.size():
		close_dialogue()
		return

	show_current_line()


func animate_opening() -> void:
	if current_tween != null:
		current_tween.kill()

	modulate.a = 0.0
	position = original_position + Vector2(
		0.0,
		entrance_offset
	)

	current_tween = create_tween()
	current_tween.set_parallel(true)

	current_tween.tween_property(
		self,
		"modulate:a",
		1.0,
		animation_duration
	)

	current_tween.tween_property(
		self,
		"position",
		original_position,
		animation_duration
	).set_trans(
		Tween.TRANS_BACK
	).set_ease(
		Tween.EASE_OUT
	)


func close_dialogue() -> void:
	if not dialogue_is_open:
		return

	if dialogue_is_closing:
		return

	dialogue_is_closing = true
	is_typing = false

	if typing_tween != null:
		typing_tween.kill()

	if portrait_tween != null:
		portrait_tween.kill()

	if current_tween != null:
		current_tween.kill()

	current_tween = create_tween()
	current_tween.set_parallel(true)

	current_tween.tween_property(
		self,
		"modulate:a",
		0.0,
		0.15
	)

	current_tween.tween_property(
		self,
		"position",
		original_position + Vector2(
			0.0,
			entrance_offset
		),
		0.15
	)

	await current_tween.finished

	dialogue_is_open = false
	dialogue_is_closing = false
	hide()
	position = original_position

	dialogue_lines.clear()
	current_line_index = 0
	dialogue_text_label.visible_characters = -1
	portrait.modulate.a = 1.0
	portrait.scale = Vector2.ONE

	dialogue_finished.emit()
