extends "res://scripts/layered_cutscene.gd"


func _on_skip_pressed() -> void:
	$Skip.disabled = true
	await _play_outro_animation()
	SceneTransition.fade_change_scene("res://scenes/character_select.tscn")
