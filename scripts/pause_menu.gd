class_name PauseMenu
extends Control

# Menu de pausa exibido ao apertar Esc durante o jogo.
# Permite continuar, reiniciar a fase atual ou voltar ao menu inicial.

signal resume_requested
signal restart_requested
signal main_menu_requested


@onready var resume_button: TextureButton = $ResumeButton
@onready var restart_button: TextureButton = $RestartButton
@onready var main_menu_button: TextureButton = $MainMenuButton


var pause_menu_is_open: bool = false


func _ready() -> void:
	hide()

	resume_button.pressed.connect(_on_resume_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
		return

	get_viewport().set_input_as_handled()

	if pause_menu_is_open:
		close_pause_menu()
	else:
		open_pause_menu()


func open_pause_menu() -> void:
	if pause_menu_is_open:
		return

	pause_menu_is_open = true

	show()
	get_tree().paused = true


func close_pause_menu() -> void:
	if not pause_menu_is_open:
		return

	pause_menu_is_open = false

	get_tree().paused = false
	hide()

	resume_requested.emit()


func _on_resume_pressed() -> void:
	close_pause_menu()


func _on_restart_pressed() -> void:
	pause_menu_is_open = false

	get_tree().paused = false
	hide()

	restart_requested.emit()


func _on_main_menu_pressed() -> void:
	pause_menu_is_open = false

	get_tree().paused = false
	hide()

	main_menu_requested.emit()
