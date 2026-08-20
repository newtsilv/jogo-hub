extends SceneTree


const MAIN_SCRIPT_PATH := "res://scripts/main.gd"
const PLAYER_SCRIPT_PATH := "res://scripts/player.gd"


var failures: int = 0


func _init() -> void:
	var main_script_text := read_text(MAIN_SCRIPT_PATH)
	var player_script_text := read_text(PLAYER_SCRIPT_PATH)

	assert_contains(
		player_script_text,
		"func get_foot_offset() -> Vector2:",
		"Player should expose the foot offset used for touch destinations."
	)

	assert_contains(
		main_script_text,
		"touch_follow_is_active",
		"Main should track when touch-follow movement is active."
	)

	assert_contains(
		main_script_text,
		"touch_follow_screen_position",
		"Main should remember the held touch position between drag events."
	)

	assert_contains(
		main_script_text,
		"update_touch_follow_destination()",
		"Main should refresh the held-touch destination every frame."
	)

	assert_contains(
		main_script_text,
		"InputEventScreenDrag",
		"Dragging on touch screens should update the movement destination."
	)

	assert_contains(
		main_script_text,
		"InputEventMouseMotion",
		"Holding and moving the mouse should mirror touch-follow for desktop testing."
	)

	assert_contains(
		main_script_text,
		"move_player_foot_to",
		"Main should move the player's foot to the touched world position."
	)

	assert_contains(
		main_script_text,
		"world_position - player.get_foot_offset()",
		"The target should compensate the player's foot offset."
	)

	assert_contains(
		player_script_text,
		"var was_already_moving: bool = is_moving",
		"Updating a drag target should know whether walking animation is already running."
	)

	assert_contains(
		player_script_text,
		"if not was_already_moving:",
		"Player should only reset walk animation when starting movement."
	)

	quit(1 if failures > 0 else 0)


func read_text(path: String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		failures += 1
		printerr("Could not read %s." % path)
		return ""

	return file.get_as_text()


func assert_contains(text: String, expected: String, message: String) -> void:
	if text.contains(expected):
		return

	failures += 1
	printerr(message)
