class_name RewardBox
extends Control

signal reward_closed


@export_category("Animação")
@export var opening_duration: float = 0.3
@export var pin_start_scale: float = 0.4


@onready var pin_image: TextureRect = $PinImage
@onready var reward_text: Label = $RewardText


var reward_is_open: bool = false
var input_enabled: bool = false

var current_tween: Tween


func _ready() -> void:
	hide()


func show_reward(
	pin_texture: Texture2D,
	pin_name: String
) -> void:
	reward_is_open = true
	input_enabled = false

	pin_image.texture = pin_texture

	reward_text.text = (
		"Parabéns!\n"
		+ "Você ganhou o pin %s!\n\n"
		+ "Toque na tela para continuar."
	) % pin_name

	show()

	modulate.a = 0.0

	pin_image.pivot_offset = (
		pin_image.size / 2.0
	)

	pin_image.scale = Vector2.ONE * pin_start_scale

	if current_tween != null:
		current_tween.kill()

	current_tween = create_tween()
	current_tween.set_parallel(true)

	current_tween.tween_property(
		self,
		"modulate:a",
		1.0,
		opening_duration
	)

	current_tween.tween_property(
		pin_image,
		"scale",
		Vector2.ONE,
		opening_duration
	).set_trans(
		Tween.TRANS_BACK
	).set_ease(
		Tween.EASE_OUT
	)

	await current_tween.finished

	input_enabled = true


func _unhandled_input(event: InputEvent) -> void:
	if not reward_is_open:
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
	close_reward()


func close_reward() -> void:
	if not reward_is_open:
		return

	reward_is_open = false
	input_enabled = false

	hide()

	reward_closed.emit()
