class_name ClickIndicator
extends Node2D


@export var radius: float = 50.0
@export var duration: float = 0.35
@export var start_scale: Vector2 = Vector2(0.6, 0.6)
@export var end_scale: Vector2 = Vector2(1.25, 1.25)
@export var circle_color: Color = Color(0.0, 0.873, 0.0, 0.749)


func _ready() -> void:
	z_index = 4096
	scale = start_scale

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(
		self,
		"scale",
		end_scale,
		duration
	)
	tween.tween_property(
		self,
		"modulate:a",
		0.0,
		duration
	)
	tween.chain().tween_callback(queue_free)


func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, circle_color)
