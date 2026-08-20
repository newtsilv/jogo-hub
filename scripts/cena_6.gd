extends "res://scripts/layered_cutscene.gd"


func _on_skip_pressed() -> void:
	$Skip.disabled = true
	await _play_outro_animation()
	get_tree().change_scene_to_file("res://scenes/cena7.tscn")
