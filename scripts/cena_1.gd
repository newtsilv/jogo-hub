extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#start
func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/cena2.tscn")

#Quit
func _on_quit_pressed() -> void:
	get_tree().quit()

#Crédito
func _on_credt_pressed() -> void:
	pass # Replace with function body.
