class_name SortableObject
extends Node2D


const SORT_Z_OFFSET := 2048


@onready var sort_point: Node2D = _find_sort_point()


func _ready() -> void:
	update_z_index()


func _process(_delta: float) -> void:
	update_z_index()


func update_z_index() -> void:
	if sort_point == null:
		push_error(
			"O nó SortPoint não foi encontrado em: %s" % name
		)
		return

	z_index = clampi(
		SORT_Z_OFFSET + roundi(sort_point.global_position.y),
		-4096,
		4096
	)


func _find_sort_point() -> Node2D:
	if name == "SortPoint":
		return self

	var child_sort_point := get_node_or_null("SortPoint") as Node2D
	if child_sort_point != null:
		return child_sort_point

	var nested_sort_point := get_node_or_null("Area2D/SortPoint") as Node2D
	if nested_sort_point != null:
		return nested_sort_point

	var parent_node := get_parent()
	if parent_node == null:
		return null

	return parent_node.get_node_or_null("SortPoint") as Node2D
