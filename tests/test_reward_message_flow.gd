extends SceneTree


const MAIN_SCRIPT_PATH := "res://scripts/main.gd"
const REWARD_SCRIPT_PATH := "res://scripts/reward_box.gd"
const MAIN_SCENE_PATH := "res://scenes/main.tscn"
const ROOT_MAIN_SCENE_PATH := "res://main.tscn"


func _init() -> void:
	var main_script_text := FileAccess.get_file_as_string(
		MAIN_SCRIPT_PATH
	)
	var reward_script_text := FileAccess.get_file_as_string(
		REWARD_SCRIPT_PATH
	)
	var main_scene_text := FileAccess.get_file_as_string(
		MAIN_SCENE_PATH
	)
	var root_main_scene_text := FileAccess.get_file_as_string(
		ROOT_MAIN_SCENE_PATH
	)

	assert_contains(
		reward_script_text,
		"message_texture",
		"RewardBox should show a ready-made message image."
	)
	assert_contains(
		main_scene_text,
		"mensagem incode.png",
		"Main scene should include the Incode reward message image."
	)
	assert_contains(
		main_scene_text,
		"mensagem techx (1).png",
		"Main scene should include the TechX reward message image."
	)
	assert_contains(
		main_scene_text,
		"Mensagem Oxy.png",
		"Main scene should include the Oxygeni reward message image."
	)
	assert_contains(
		main_scene_text,
		"custom_minimum_size = Vector2(1080, 1920)",
		"Reward message image should have an explicit screen size."
	)
	assert_contains(
		root_main_scene_text,
		"MessageImage",
		"Root main scene duplicate should also include MessageImage."
	)
	assert_contains(
		main_script_text,
		"get_reward_message_texture",
		"Main should choose the correct reward message image."
	)
	assert_contains(
		main_script_text,
		"pending_congratulation_npc",
		"Main should defer completion until after the congratulation dialogue."
	)
	assert_contains(
		main_script_text,
		"await reward_box.show_reward(",
		"Main should keep the reward visible while preparing the congratulation dialogue."
	)
	assert_contains(
		main_script_text,
		"open_congratulation_dialogue(answered_npc)",
		"The congratulation dialogue should open while the reward image is still visible."
	)
	assert_contains(
		main_script_text,
		"reward_box.input_enabled = false",
		"The reward image should not close from input while the congratulation dialogue is active."
	)
	assert_contains(
		main_script_text,
		"reward_box.close_reward()",
		"Finishing the congratulation dialogue should close the reward image."
	)
	assert_not_contains(
		main_script_text,
		"open_congratulation_dialogue(completed_npc)",
		"Closing the reward should not be what starts the congratulation dialogue."
	)
	assert_contains(
		main_script_text,
		"Mandou bem! Você conquistou o Pin Incode.",
		"Emanuel should congratulate the player after the reward image."
	)
	assert_contains(
		main_script_text,
		"Muito bem! Você conquistou o Pin TechX.",
		"Laura should congratulate the player after the reward image."
	)
	assert_contains(
		main_script_text,
		"Excelente! Você completou sua primeira jornada no Oxygeni Hub.",
		"Marcos should congratulate the player after the reward image."
	)

	quit(0)


func assert_contains(text: String, expected: String, message: String) -> void:
	if text.contains(expected):
		return

	printerr(message)
	quit(1)


func assert_not_contains(text: String, unexpected: String, message: String) -> void:
	if not text.contains(unexpected):
		return

	printerr(message)
	quit(1)
