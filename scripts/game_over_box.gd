class_name GameOverBox
extends Control

signal restart_requested


@onready var play_again_button: Button = $PlayAgainButton


var game_over_is_open: bool = false


func _ready() -> void:
	hide()
	play_again_button.pressed.connect(_on_play_again_pressed)


func show_game_over() -> void:
	game_over_is_open = true

	show()

	modulate.a = 0.0

	var tween: Tween = create_tween()

	tween.tween_property(
		self,
		"modulate:a",
		1.0,
		0.25
	)

func _on_play_again_pressed() -> void:
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
