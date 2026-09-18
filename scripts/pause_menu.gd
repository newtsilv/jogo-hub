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
@onready var background: ColorRect = $Background
@onready var box: ColorRect = $Box
@onready var title_label: Label = $TitleLabel


const DESIGN_SIZE: Vector2 = Vector2(1080.0, 1920.0)
const BOX_DESIGN_RECT := Rect2(140.0, 560.0, 800.0, 880.0)
const TITLE_DESIGN_RECT := Rect2(140.0, 610.0, 800.0, 100.0)
const RESUME_DESIGN_RECT := Rect2(190.0, 790.0, 700.0, 175.0)
const RESTART_DESIGN_RECT := Rect2(190.0, 1005.0, 700.0, 175.0)
const MAIN_MENU_DESIGN_RECT := Rect2(190.0, 1220.0, 700.0, 175.0)


var pause_menu_is_open: bool = false


func _ready() -> void:
	_apply_responsive_layout()
	resized.connect(_apply_responsive_layout)
	hide()

	resume_button.pressed.connect(_on_resume_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)


func _apply_responsive_layout() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	var scale_factor: float = minf(
		viewport_size.x / DESIGN_SIZE.x,
		viewport_size.y / DESIGN_SIZE.y
	)
	var offset: Vector2 = (
		viewport_size - DESIGN_SIZE * scale_factor
	) / 2.0

	_set_rect(self, Rect2(Vector2.ZERO, viewport_size))
	_set_rect(background, Rect2(Vector2.ZERO, viewport_size))
	_set_rect(box, _scale_rect(BOX_DESIGN_RECT, scale_factor, offset))
	_set_rect(title_label, _scale_rect(TITLE_DESIGN_RECT, scale_factor, offset))
	_set_rect(resume_button, _scale_rect(RESUME_DESIGN_RECT, scale_factor, offset))
	_set_rect(restart_button, _scale_rect(RESTART_DESIGN_RECT, scale_factor, offset))
	_set_rect(main_menu_button, _scale_rect(MAIN_MENU_DESIGN_RECT, scale_factor, offset))


func _scale_rect(rect: Rect2, scale_factor: float, offset: Vector2) -> Rect2:
	return Rect2(
		offset + rect.position * scale_factor,
		rect.size * scale_factor
	)


func _set_rect(control: Control, rect: Rect2) -> void:
	control.position = rect.position
	control.size = rect.size


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
