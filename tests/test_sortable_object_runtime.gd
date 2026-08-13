extends SceneTree


const SORTABLE_SCRIPT := preload("res://scripts/sortable_object.gd")


func _init() -> void:
	var sortable := Node2D.new()
	sortable.name = "Sortable"
	sortable.set_script(SORTABLE_SCRIPT)

	var sort_point := Marker2D.new()
	sort_point.name = "SortPoint"
	sort_point.position = Vector2(0.0, 10.0)
	sortable.add_child(sort_point)

	root.add_child(sortable)
	await process_frame

	var initial_z_index: int = sortable.z_index
	sort_point.position.y = 120.0
	await process_frame

	if sortable.z_index == initial_z_index:
		printerr("SortableObject should update z_index after its SortPoint moves.")
		sortable.queue_free()
		quit(1)
		return

	sortable.queue_free()
	quit(0)
