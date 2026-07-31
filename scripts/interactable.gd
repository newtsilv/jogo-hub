class_name Interactable
extends Area2D

signal selected(interactable: Interactable)


@export_category("Interaction")
@export var object_name: String = "Objeto"
@export_multiline var dialogue_text: String = "É apenas um objeto."


@onready var sort_point: Marker2D = $SortPoint


func _ready() -> void:
	update_z_index()


func update_z_index() -> void:
	z_index = roundi(sort_point.global_position.y)


func _input_event(
	_viewport: Viewport,
	event: InputEvent,
	_shape_index: int
) -> void:
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

	selected.emit(self)
	get_viewport().set_input_as_handled()
