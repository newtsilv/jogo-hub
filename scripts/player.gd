class_name Player
extends CharacterBody2D


signal destination_reached
signal movement_blocked


const SORT_Z_OFFSET := 2048


@export_category("Movement")
@export var movement_speed: float = 450
@export var stopping_distance: float = 10.0
@export var stuck_time_limit: float = 0.9
@export var minimum_progress_distance: float = 2.0
@export var slide_assist_strength: float = 0.85


@export_category("Walk animation")
@export var walk_sway_angle: float = 5.0
@export var walk_sway_speed: float = 12.0
@export var walk_bounce_height: float = 4.0


@export_category("Idle animation")
@export var idle_breathe_speed: float = 2.0
@export var idle_squash_amount: float = 0.04
@export var idle_bounce_height: float = 2.0
@export var idle_transition_speed: float = 6.0


@export_category("Seta")
@export var objective_arrow_distance: float = 230.0
@export var arrow_bob_height: float = 8.0
@export var arrow_bob_speed: float = 4.0


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
var arrow_time: float = 0.0
var arrow_direction: Vector2 = Vector2.UP


@onready var visual: Node2D = $Visual
@onready var body: Sprite2D = $Visual/Body
@onready var camera: Camera2D = $Camera2D
@onready var objective_arrow: Sprite2D = $ObjectiveArrow
@onready var sort_point: Marker2D = $SortPoint


func _ready() -> void:
	target_position = global_position
	last_position = global_position
	objective_arrow.hide()

	apply_selected_character()
	reset_visual_immediately()
	update_z_index()


func apply_selected_character() -> void:
	var game_state: Node = get_node_or_null("/root/GameState")
	var selected_character := 0

	if game_state != null:
		selected_character = int(game_state.get("selected_character"))

	if selected_character == 1:
		if laura_texture != null:
			body.texture = laura_texture

		return

	if gabriel_texture != null:
		body.texture = gabriel_texture


func _physics_process(delta: float) -> void:
	update_z_index()
	animate_objective_arrow(delta)

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

	var direction: Vector2 = global_position.direction_to(target_position)

	update_facing_direction(direction)

	velocity = direction * movement_speed
	move_and_slide()
	apply_slide_assist(direction)

	animate_walk(delta)
	update_stuck_detection(delta)


func move_to(new_target_position: Vector2) -> void:
	target_position = new_target_position
	is_moving = true

	walk_time = 0.0
	stuck_time = 0.0
	last_position = global_position


func point_objective_arrow_to(target_global_position: Vector2) -> void:
	arrow_direction = global_position.direction_to(target_global_position)

	if arrow_direction == Vector2.ZERO:
		hide_objective_arrow()
		return

	objective_arrow.position = arrow_direction * objective_arrow_distance
	objective_arrow.rotation = arrow_direction.angle() + PI / 2.0
	objective_arrow.show()


func hide_objective_arrow() -> void:
	objective_arrow.hide()


func make_camera_current() -> void:
	camera.make_current()


func animate_objective_arrow(delta: float) -> void:
	if not objective_arrow.visible:
		return

	arrow_time += delta * arrow_bob_speed

	objective_arrow.position = (
		arrow_direction
		* (
			objective_arrow_distance
			+ sin(arrow_time) * arrow_bob_height
		)
	)


func apply_slide_assist(direction: Vector2) -> void:
	if get_slide_collision_count() == 0:
		return

	var best_slide_direction := Vector2.ZERO
	var best_score := -INF

	for index: int in range(get_slide_collision_count()):
		var collision := get_slide_collision(index)
		var normal: Vector2 = collision.get_normal()
		var tangent := Vector2(-normal.y, normal.x)

		for candidate: Vector2 in [tangent, -tangent]:
			var score: float = candidate.dot(direction)

			if score > best_score:
				best_score = score
				best_slide_direction = candidate

	if best_score <= 0.05:
		return

	velocity = best_slide_direction * movement_speed * slide_assist_strength
	move_and_slide()


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
