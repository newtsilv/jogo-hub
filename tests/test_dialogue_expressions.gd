extends SceneTree


const MAIN_SCENE := preload("res://scenes/main.tscn")


func _init() -> void:
	var main_scene := MAIN_SCENE.instantiate()
	root.add_child(main_scene)

	await physics_frame
	await physics_frame

	var gabriel: NPC = main_scene.get_node("World/Entities/Gabriel")
	var emanuel: NPC = main_scene.get_node("World/Entities/Emanuel")
	var laura: NPC = main_scene.get_node("World/Entities/Laura")
	var mb: NPC = main_scene.get_node("World/Entities/MB")

	assert_texture_exists(
		gabriel.get_portrait_for_expression("base"),
		"Gabriel base expression should load."
	)
	assert_texture_exists(
		gabriel.get_portrait_for_expression("joinha"),
		"Gabriel joinha expression should load."
	)
	assert_texture_exists(
		emanuel.get_portrait_for_expression("pensante"),
		"Emanuel pensante expression should load."
	)
	assert_texture_exists(
		laura.get_portrait_for_expression("feliz"),
		"Laura feliz expression should load."
	)
	assert_texture_exists(
		laura.get_portrait_for_expression("explicando"),
		"Laura explicando expression should load."
	)
	assert_texture_exists(
		laura.get_portrait_for_expression("orgulhosa"),
		"Laura orgulhosa expression should load."
	)
	assert_texture_exists(
		mb.get_portrait_for_expression("base"),
		"MB base expression should load."
	)
	assert_texture_exists(
		mb.get_portrait_for_expression("explicando"),
		"MB explicando expression should load."
	)
	assert_texture_exists(
		mb.get_portrait_for_expression("controle"),
		"MB controle expression should load."
	)

	var gabriel_conversation: Array[Dictionary] = (
		main_scene.get_npc_conversation(gabriel)
	)
	var emanuel_conversation: Array[Dictionary] = (
		main_scene.get_npc_conversation(emanuel)
	)
	var laura_conversation: Array[Dictionary] = (
		main_scene.get_npc_conversation(laura)
	)
	var mb_conversation: Array[Dictionary] = (
		main_scene.get_npc_conversation(mb)
	)

	assert_line_expression(
		gabriel_conversation[0],
		"base"
	)
	assert_line_expression(
		gabriel_conversation[2],
		"joinha"
	)
	assert_line_expression(
		emanuel_conversation[2],
		"aponta_cima"
	)
	assert_line_expression(
		laura_conversation[0],
		"feliz"
	)
	assert_line_expression(
		laura_conversation[2],
		"explicando"
	)
	assert_line_expression(
		mb_conversation[0],
		"base"
	)
	assert_line_expression(
		mb_conversation[2],
		"controle"
	)

	main_scene.queue_free()
	quit(0)


func assert_texture_exists(texture: Texture2D, message: String) -> void:
	if texture != null:
		return

	printerr(message)
	quit(1)


func assert_line_expression(line: Dictionary, expected_expression: String) -> void:
	var actual_expression: String = str(line.get("expression", ""))

	if actual_expression == expected_expression:
		return

	printerr(
		"Expected expression %s, got %s in line %s."
		% [expected_expression, actual_expression, line]
	)
	quit(1)
