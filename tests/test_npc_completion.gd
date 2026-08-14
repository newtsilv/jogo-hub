extends SceneTree


const MAIN_SCENE := preload("res://scenes/main.tscn")


func _init() -> void:
	var main_scene := MAIN_SCENE.instantiate()
	root.add_child(main_scene)

	await physics_frame
	await physics_frame

	var closest_npc: NPC = get_closest_available_npc(main_scene)

	if closest_npc == null:
		printerr("Expected one available NPC.")
		quit(1)
		return

	var player: Player = main_scene.get_node("World/Entities/Player")

	if not player.objective_arrow.visible:
		printerr("Player objective arrow should be visible when an NPC is available.")
		quit(1)
		return

	assert_player_arrow_points_to(player, closest_npc)
	assert_no_npc_arrows_visible(main_scene)

	var gabriel: NPC = main_scene.get_node("World/Entities/Gabriel")
	main_scene.finish_npc_interaction(gabriel)

	if gabriel.interaction_enabled:
		printerr("Completed NPC should have interaction disabled.")
		quit(1)
		return

	var next_closest_npc: NPC = get_closest_available_npc(main_scene)
	assert_player_arrow_points_to(player, next_closest_npc)

	main_scene._on_npc_selected(gabriel)

	if main_scene.active_dialogue_npc == gabriel or main_scene.target_npc == gabriel:
		printerr("Completed NPC should not open dialogue or become target again.")
		quit(1)
		return

	main_scene.queue_free()
	quit(0)


func get_closest_available_npc(main_scene: Node) -> NPC:
	var player: Player = main_scene.get_node("World/Entities/Player")
	var closest_npc: NPC = null
	var closest_distance := INF

	for npc: NPC in main_scene.npc_objective_order:
		if not npc.interaction_enabled:
			continue

		var distance: float = player.global_position.distance_squared_to(
			npc.global_position
		)

		if distance < closest_distance:
			closest_distance = distance
			closest_npc = npc

	return closest_npc


func assert_player_arrow_points_to(player: Player, expected_npc: NPC) -> void:
	if expected_npc == null:
		if player.objective_arrow.visible:
			printerr("Player objective arrow should hide when no NPC is available.")
			quit(1)

		return

	var expected_direction: Vector2 = player.global_position.direction_to(
		expected_npc.global_position
	)
	var actual_direction: Vector2 = player.objective_arrow.position.normalized()

	if actual_direction.dot(expected_direction) > 0.95:
		return

	printerr(
		"Player objective arrow should point to %s. Expected %s, got %s."
		% [expected_npc.character_name, expected_direction, actual_direction]
	)
	quit(1)


func assert_no_npc_arrows_visible(main_scene: Node) -> void:
	for npc: NPC in main_scene.npc_objective_order:
		if not npc.objective_arrow.visible:
			continue

		printerr(
			"NPC arrows should not be visible. Found visible arrow on %s."
			% npc.character_name
		)
		quit(1)
