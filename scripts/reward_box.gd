class_name RewardBox
extends Control

signal reward_closed


@export_category("Animação")
@export var opening_duration: float = 0.3


const REWARD_MESSAGE_SIZE := Vector2(1080, 1920)


@onready var message_image: TextureRect = $MessageImage
@onready var pin_image: TextureRect = $PinImage
@onready var reward_text: Label = $RewardText


var reward_is_open: bool = false
var input_enabled: bool = false

var current_tween: Tween


func _ready() -> void:
	pin_image.hide()
	reward_text.hide()
	hide()


func show_reward(
	message_texture: Texture2D,
	pin_name: String
) -> void:
	reward_is_open = true
	input_enabled = false

	message_image.custom_minimum_size = REWARD_MESSAGE_SIZE
	message_image.size = REWARD_MESSAGE_SIZE
	message_image.texture = message_texture
	message_image.show()
	pin_image.hide()
	reward_text.hide()

	show()

	modulate.a = 0.0
	message_image.modulate.a = 0.0

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
		message_image,
		"modulate:a",
		1.0,
		opening_duration
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
