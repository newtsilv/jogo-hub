extends SceneTree


const MAIN_SCRIPT_PATH := "res://scripts/main.gd"
const GAME_OVER_SCRIPT_PATH := "res://scripts/game_over_box.gd"


var failures: int = 0


func _init() -> void:
	var main_script_text := read_text(MAIN_SCRIPT_PATH)
	var game_over_script_text := read_text(GAME_OVER_SCRIPT_PATH)

	assert_true(
		main_script_text.contains(
			"func _on_restart_requested() -> void:\n"
			+ "\tget_tree().change_scene_to_file(\n"
			+ "\t\t\"res://scenes/main_menu.tscn\"\n"
			+ "\t)"
		),
		"Game Over restart should return to the initial menu scene."
	)

	assert_true(
		game_over_script_text.contains("modulate:a")
		and game_over_script_text.contains("0.0")
		and game_over_script_text.contains("restart_requested.emit()"),
		"Game Over should fade out before requesting the menu transition."
	)

	quit(1 if failures > 0 else 0)


func read_text(path: String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		failures += 1
		printerr("Could not read %s." % path)
		return ""

	return file.get_as_text()


func assert_true(value: bool, message: String) -> void:
	if value:
		return

	failures += 1
	printerr(message)
