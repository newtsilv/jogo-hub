class_name NPC
extends Area2D


signal selected(npc: NPC)


const SORT_Z_OFFSET := 2048
const EXPRESSION_DIRECTORY := "res://assets/sprites/expressions"


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


@export_category("Interação")
@export var interaction_enabled: bool = true


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
@onready var name_label: Label = get_node_or_null("NameLabel") as Label
@onready var objective_arrow: Sprite2D = $ObjectiveArrow
@onready var sort_point: Marker2D = $SortPoint


var arrow_time: float = 0.0
var arrow_original_position: Vector2

var idle_time: float = 0.0
var visual_original_position: Vector2
var visual_original_scale: Vector2
var portrait_by_expression: Dictionary = {}


func _ready() -> void:
	if name_label != null:
		name_label.text = character_name

	if world_sprite != null:
		visual.texture = world_sprite

	load_expression_portraits()

	arrow_original_position = objective_arrow.position

	visual_original_position = visual.position
	visual_original_scale = visual.scale

	# Faz cada NPC começar a animação em um momento diferente.
	idle_time = randf() * TAU

	update_z_index()

	objective_arrow.hide()


func _process(delta: float) -> void:
	update_z_index()
	animate_idle(delta)
	animate_objective_arrow(delta)


func update_z_index() -> void:
	z_index = clampi(
		SORT_Z_OFFSET + roundi(sort_point.global_position.y),
		-4096,
		4096
	)


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

	if not interaction_enabled:
		get_viewport().set_input_as_handled()
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


func set_interaction_enabled(enabled: bool) -> void:
	interaction_enabled = enabled
	hide_objective_arrow()


func get_default_dialogue() -> Array[Dictionary]:
	return [
		{
			"speaker": character_name,
			"text": default_line,
			"expression": "base",
			"portrait": get_portrait_for_expression("base")
		}
	]


func load_expression_portraits() -> void:
	portrait_by_expression.clear()

	for expression_name: String in [
		"base",
		"joinha",
		"aponta_cima",
		"pensante",
		"feliz",
		"explicando",
		"orgulhosa",
		"controle"
	]:
		var expression_path: String = (
			"%s/%s_%s.png"
			% [
				EXPRESSION_DIRECTORY,
				character_name.to_lower(),
				expression_name
			]
		)

		if not ResourceLoader.exists(expression_path):
			continue

		portrait_by_expression[expression_name] = load(expression_path)


func get_portrait_for_expression(expression_name: String) -> Texture2D:
	var normalized_expression := expression_name.strip_edges().to_lower()

	if normalized_expression.is_empty():
		normalized_expression = "base"

	var expression_value: Variant = portrait_by_expression.get(
		normalized_expression,
		null
	)

	if expression_value is Texture2D:
		return expression_value as Texture2D

	var base_value: Variant = portrait_by_expression.get(
		"base",
		null
	)

	if base_value is Texture2D:
		return base_value as Texture2D

	return portrait
