extends SceneTree


const MAIN_SCENE := preload("res://scenes/main.tscn")


func _init() -> void:
	var main_scene := MAIN_SCENE.instantiate()
	root.add_child(main_scene)

	await process_frame

	assert_sortable(main_scene, "World/Entities/bancada")
	assert_sortable(main_scene, "World/Entities/sofa_central")
	assert_sortable(main_scene, "World/Entities/bancada2")

	main_scene.queue_free()
	quit(0)


func assert_sortable(main_scene: Node, node_path: NodePath) -> void:
	var node := main_scene.get_node(node_path)

	if node is SortableObject:
		return

	printerr("%s should keep SortableObject from its instanced scene." % node_path)
	quit(1)
