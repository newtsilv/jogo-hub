extends SceneTree


const PROJECT_PATH := "res://project.godot"


func _init() -> void:
	var project_text := FileAccess.get_file_as_string(PROJECT_PATH)

	if not project_text.contains(
		"run/main_scene=\"res://scenes/cena1.tscn\""
	):
		printerr("Project should start directly on cena1.tscn.")
		quit(1)
		return

	quit(0)
