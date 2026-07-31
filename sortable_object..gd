class_name SortableObject
extends Node2D


@onready var sort_point: Marker2D = get_node_or_null(
	"SortPoint"
)


func _ready() -> void:
	update_z_index()


func update_z_index() -> void:
	if sort_point == null:
		push_error(
			"O nó SortPoint não foi encontrado em: %s" % name
		)
		return

	z_index = roundi(sort_point.global_position.y)
