class_name Player
extends CharacterBody2D


signal destination_reached
signal movement_blocked


const SORT_Z_OFFSET := 2048


@export_category("Movement")
@export var movement_speed: float = 350.0
@export var stopping_distance: float = 10.0
@export var stuck_time_limit: float = 0.35
@export var minimum_progress_distance: float = 2.0


@export_category("Walk animation")
@export var walk_sway_angle: float = 5.0
@export var walk_sway_speed: float = 12.0
@export var walk_bounce_height: float = 4.0


@export_category("Idle animation")
@export var idle_breathe_speed: float = 2.0
@export var idle_squash_amount: float = 0.04
@export var idle_bounce_height: float = 2.0
@export var idle_transition_speed: float = 6.0


@export_category("Personagem")
@export var gabriel_texture: Texture2D
@export var laura_texture: Texture2D


var target_position: Vector2
var is_moving: bool = false

var walk_time: float = 0.0
var idle_time: float = 0.0

var facing_direction: float = 1.0

var last_position: Vector2
var stuck_time: float = 0.0


@onready var visual: Node2D = $Visual
@onready var body: Sprite2D = $Visual/Body
@onready var sort_point: Marker2D = $SortPoint


func _ready() -> void:
	target_position = global_position
	last_position = global_position

	apply_selected_character()
	reset_visual_immediately()
	update_z_index()


func apply_selected_character() -> void:
	match GameState.selected_character:
		GameState.Character.LAURA:
			if laura_texture != null:
				body.texture = laura_texture

		_:
			if gabriel_texture != null:
				body.texture = gabriel_texture


func _physics_process(delta: float) -> void:
	update_z_index()

	if not is_moving:
		velocity = Vector2.ZERO
		animate_idle(delta)
		return

	var distance_to_target: float = (
		global_position.distance_to(target_position)
	)

	if distance_to_target <= stopping_distance:
		stop_movement(true)
		return

	var direction: Vector2 = (
		global_position.direction_to(target_position)
	)

	update_facing_direction(direction)

	velocity = direction * movement_speed

	move_and_slide()

	animate_walk(delta)
	update_stuck_detection(delta)


func move_to(new_target_position: Vector2) -> void:
	target_position = new_target_position
	is_moving = true

	walk_time = 0.0
	stuck_time = 0.0
	last_position = global_position


func stop_movement(
	reached_destination: bool = false
) -> void:
	velocity = Vector2.ZERO
	is_moving = false

	idle_time = 0.0
	stuck_time = 0.0
	last_position = global_position

	if reached_destination:
		destination_reached.emit()


func update_stuck_detection(delta: float) -> void:
	var distance_moved: float = (
		global_position.distance_to(last_position)
	)

	if distance_moved >= minimum_progress_distance:
		stuck_time = 0.0
		last_position = global_position
		return

	stuck_time += delta

	if stuck_time < stuck_time_limit:
		return

	stop_movement()
	movement_blocked.emit()


func update_facing_direction(direction: Vector2) -> void:
	if direction.x > 0.05:
		facing_direction = 1.0

	elif direction.x < -0.05:
		facing_direction = -1.0


func animate_walk(delta: float) -> void:
	walk_time += delta * walk_sway_speed

	var sway: float = sin(walk_time)
	var bounce: float = absf(sin(walk_time))

	visual.rotation_degrees = (
		sway * walk_sway_angle
	)

	visual.position.y = (
		-bounce * walk_bounce_height
	)

	visual.scale.x = -facing_direction
	visual.scale.y = 1.0


func animate_idle(delta: float) -> void:
	idle_time += delta * idle_breathe_speed

	var breathe: float = sin(idle_time)

	var target_scale_y: float = (
		1.0
		- breathe * idle_squash_amount
	)

	var target_scale_x_absolute: float = (
		1.0
		+ breathe * idle_squash_amount
	)

	var target_scale_x: float = (
		-facing_direction
		* target_scale_x_absolute
	)

	var transition_weight: float = clampf(
		delta * idle_transition_speed,
		0.0,
		1.0
	)

	visual.rotation_degrees = lerpf(
		visual.rotation_degrees,
		0.0,
		transition_weight
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
		breathe * idle_bounce_height,
		transition_weight
	)


func reset_visual_immediately() -> void:
	visual.rotation_degrees = 0.0
	visual.position = Vector2.ZERO

	visual.scale = Vector2(
		-facing_direction,
		1.0
	)


func update_z_index() -> void:
	z_index = clampi(
		SORT_Z_OFFSET + roundi(sort_point.global_position.y),
		-4096,
		4096
	)
