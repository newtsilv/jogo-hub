class_name GameOverBox
extends Control

signal restart_requested


@onready var game_over_text: Label = $GameOverText


var game_over_is_open: bool = false
var input_enabled: bool = false


func _ready() -> void:
	hide()


func show_game_over() -> void:
	game_over_is_open = true
	input_enabled = false

	game_over_text.text = (
		"Quase!\n\n"
		+ "Lembre-se do que aprendeu durante a jornada.\n\n"
		+ "Tente novamente. Tenho certeza de que você consegue!"
	)

	show()

	modulate.a = 0.0

	var tween: Tween = create_tween()

	tween.tween_property(
		self,
		"modulate:a",
		1.0,
		0.25
	)

	await tween.finished

	input_enabled = true


func _unhandled_input(event: InputEvent) -> void:
	if not game_over_is_open:
		return

	if not input_enabled:
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

	input_enabled = false
	game_over_is_open = false

	var tween: Tween = create_tween()
	tween.tween_property(
		self,
		"modulate:a",
		0.0,
		0.25
	)

	await tween.finished

	restart_requested.emit()
