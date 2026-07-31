class_name NPC
extends Area2D


signal selected(npc: NPC)


@export_category("Personagem")
@export var character_name: String = "Personagem"
@export var world_sprite: Texture2D
@export var portrait: Texture2D

@export var dialogue_id: String = "default"
@export_multiline var default_line: String = "Olá."


@export_category("Objetivo")
@export var objective_order: int = 0


@export_category("Recompensa")
@export var pin_name: String = "Especial"
@export var pin_texture: Texture2D


@export_category("Seta")
@export var arrow_bob_height: float = 8.0
@export var arrow_bob_speed: float = 4.0


@export_category("Idle animation")
@export var idle_breathe_speed: float = 2.0
@export var idle_squash_amount: float = 0.03
@export var idle_bounce_height: float = 2.0
@export var idle_sway_angle: float = 1.5
@export var idle_transition_speed: float = 6.0


@onready var visual: Sprite2D = $Visual
@onready var interaction_point: Marker2D = $InteractionPoint
@onready var name_label: Label = $NameLabel
@onready var objective_arrow: Sprite2D = $ObjectiveArrow


var arrow_time: float = 0.0
var arrow_original_position: Vector2

var idle_time: float = 0.0
var visual_original_position: Vector2
var visual_original_scale: Vector2


func _ready() -> void:
	name_label.text = character_name

	if world_sprite != null:
		visual.texture = world_sprite

	arrow_original_position = objective_arrow.position

	visual_original_position = visual.position
	visual_original_scale = visual.scale

	# Faz cada NPC começar a animação em um momento diferente.
	idle_time = randf() * TAU

	# O Y Sort será responsável pela profundidade.
	z_index = 0

	objective_arrow.hide()


func _process(delta: float) -> void:
	animate_idle(delta)
	animate_objective_arrow(delta)


func animate_idle(delta: float) -> void:
	idle_time += delta * idle_breathe_speed

	var breathe: float = sin(idle_time)

	var target_scale_x: float = (
		visual_original_scale.x
		* (
			1.0
			+ breathe * idle_squash_amount
		)
	)

	var target_scale_y: float = (
		visual_original_scale.y
		* (
			1.0
			- breathe * idle_squash_amount
		)
	)

	var target_position_y: float = (
		visual_original_position.y
		+ breathe * idle_bounce_height
	)

	var target_rotation: float = (
		breathe * idle_sway_angle
	)

	var transition_weight: float = clampf(
		delta * idle_transition_speed,
		0.0,
		1.0
	)

	visual.scale.x = lerpf(
		visual.scale.x,
		target_scale_x,
		transition_weight
	)

	visual.scale.y = lerpf(
		visual.scale.y,
		target_scale_y,
		transition_weight
	)

	visual.position.y = lerpf(
		visual.position.y,
		target_position_y,
		transition_weight
	)

	visual.rotation_degrees = lerpf(
		visual.rotation_degrees,
		target_rotation,
		transition_weight
	)


func animate_objective_arrow(delta: float) -> void:
	if not objective_arrow.visible:
		return

	arrow_time += delta * arrow_bob_speed

	objective_arrow.position.y = (
		arrow_original_position.y
		+ sin(arrow_time) * arrow_bob_height
	)


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


func show_objective_arrow() -> void:
	arrow_time = 0.0
	objective_arrow.position = arrow_original_position
	objective_arrow.show()


func hide_objective_arrow() -> void:
	objective_arrow.hide()
	objective_arrow.position = arrow_original_position


func get_default_dialogue() -> Array[Dictionary]:
	return [
		{
			"speaker": character_name,
			"text": default_line,
			"portrait": portrait
		}
	]
