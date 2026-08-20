extends Control

const INTRO_DURATION := 0.45
const OUTRO_DURATION := 0.35
const PROFESSOR_POP_DURATION := 0.12
const CENAS_4_7_PROFESSOR_BOTTOM_MARGIN_RATIO := 0.04
const CENA8_PROFESSOR_BOTTOM_MARGIN_RATIO := 0.08
const DESIGN_SIZE := Vector2(1080.0, 1920.0)

const SCENES := [
	{
		"fundo": preload("res://assets/sprites/scenes/cena4/fundo.png"),
		"professor": preload("res://assets/sprites/scenes/cena4/professor.png"),
		"top": preload("res://assets/sprites/scenes/cena4/Tela_hub_salas_cima.png"),
		"bottom": preload("res://assets/sprites/scenes/cena4/Tela_hub_salas_baixo.png"),
		"logo": null,
	},
	{
		"fundo": preload("res://assets/sprites/scenes/cena5/fundo.png"),
		"professor": preload("res://assets/sprites/scenes/cena5/professor.png"),
		"top": preload("res://assets/sprites/scenes/cena5/imagem_cima.png"),
		"bottom": preload("res://assets/sprites/scenes/cena5/imagem_baixo.png"),
		"logo": null,
	},
	{
		"fundo": preload("res://assets/sprites/scenes/cena6/fundo.png"),
		"professor": preload("res://assets/sprites/scenes/cena6/professor.png"),
		"top": preload("res://assets/sprites/scenes/cena6/imagem_cima.png"),
		"bottom": preload("res://assets/sprites/scenes/cena6/imagem_baixo.png"),
		"logo": null,
	},
	{
		"fundo": preload("res://assets/sprites/scenes/cena7/fundo.png"),
		"professor": preload("res://assets/sprites/scenes/cena7/professor.png"),
		"top": preload("res://assets/sprites/scenes/cena7/imagem_cima.png"),
		"bottom": preload("res://assets/sprites/scenes/cena7/imagem_baixo.png"),
		"logo": null,
	},
	{
		"fundo": preload("res://assets/sprites/scenes/cena8/fundo.png"),
		"professor": preload("res://assets/sprites/scenes/cena8/professor.png"),
		"top": null,
		"bottom": null,
		"logo": preload("res://assets/sprites/scenes/cena8/oxyquest.png"),
	},
]

var scene_index := 0
var is_transitioning := false
var top_home_position := Vector2.ZERO
var bottom_home_position := Vector2.ZERO
var professor_home_position := Vector2.ZERO
var top_design_position := Vector2.ZERO
var bottom_design_position := Vector2.ZERO
var professor_design_position := Vector2.ZERO
var top_design_size := Vector2.ZERO
var bottom_design_size := Vector2.ZERO
var professor_design_size := Vector2.ZERO
var logo_design_position := Vector2.ZERO
var logo_design_size := Vector2.ZERO

@onready var fundo: TextureRect = $Fundo
@onready var tela_cima: TextureRect = $TelaCima
@onready var tela_baixo: TextureRect = $TelaBaixo
@onready var professor: TextureRect = $Professor
@onready var logo: TextureRect = $Logo


func _ready() -> void:
	$Skip.disabled = true
	top_design_position = tela_cima.position
	bottom_design_position = tela_baixo.position
	professor_design_position = professor.position
	top_design_size = tela_cima.size
	bottom_design_size = tela_baixo.size
	professor_design_size = professor.size
	logo_design_position = logo.position
	logo_design_size = logo.size
	_apply_responsive_layout()
	_apply_scene()
	_play_professor_pop()
	await _play_intro_animation()
	$Skip.disabled = false
	resized.connect(_apply_responsive_layout)


func _apply_responsive_layout() -> void:
	var scale_factor: float = minf(size.x / DESIGN_SIZE.x, size.y / DESIGN_SIZE.y)
	var horizontal_margin: float = (size.x - DESIGN_SIZE.x * scale_factor) / 2.0

	fundo.set_anchors_preset(Control.PRESET_FULL_RECT)
	fundo.offset_left = 0.0
	fundo.offset_top = 0.0
	fundo.offset_right = 0.0
	fundo.offset_bottom = 0.0

	tela_cima.size = top_design_size * scale_factor
	tela_cima.position = Vector2(
		horizontal_margin + top_design_position.x * scale_factor,
		top_design_position.y * scale_factor
	)
	top_home_position = tela_cima.position

	tela_baixo.size = bottom_design_size * scale_factor
	tela_baixo.position = Vector2(
		horizontal_margin + bottom_design_position.x * scale_factor,
		bottom_design_position.y * scale_factor
	)
	bottom_home_position = tela_baixo.position

	professor.size = professor_design_size * scale_factor
	professor.position = Vector2(
		horizontal_margin + professor_design_position.x * scale_factor,
		professor_design_position.y * scale_factor
	)
	professor_home_position = professor.position

	logo.size = logo_design_size * scale_factor
	logo.position = Vector2(
		horizontal_margin + logo_design_position.x * scale_factor,
		logo_design_position.y * scale_factor
	)

	$Skip.offset_left = 0.0
	$Skip.offset_top = 0.0
	$Skip.offset_right = size.x
	$Skip.offset_bottom = size.y

	_apply_professor_layout()


func _apply_scene() -> void:
	var current_scene: Dictionary = SCENES[scene_index]
	fundo.texture = current_scene["fundo"]
	professor.texture = current_scene["professor"]
	logo.texture = current_scene["logo"]
	logo.visible = current_scene["logo"] != null
	tela_cima.visible = current_scene["top"] != null
	tela_baixo.visible = current_scene["bottom"] != null

	if current_scene["top"] != null:
		tela_cima.texture = current_scene["top"]
	if current_scene["bottom"] != null:
		tela_baixo.texture = current_scene["bottom"]

	_apply_professor_layout()


func _apply_professor_layout() -> void:
	professor.position = professor_home_position

	if scene_index < SCENES.size() - 1:
		var regular_bottom_margin: float = size.y * CENAS_4_7_PROFESSOR_BOTTOM_MARGIN_RATIO
		professor.position.y = size.y - professor.size.y - regular_bottom_margin
		return

	if scene_index != SCENES.size() - 1:
		return

	var bottom_margin: float = size.y * CENA8_PROFESSOR_BOTTOM_MARGIN_RATIO
	professor.position.y = size.y - professor.size.y - bottom_margin


func _play_intro_animation() -> void:
	if not tela_cima.visible or not tela_baixo.visible:
		return

	var viewport_width := get_viewport_rect().size.x
	var top_end := top_home_position
	var bottom_end := bottom_home_position
	var top_start := top_end
	var bottom_start := bottom_end

	top_start.x += viewport_width
	bottom_start.x -= viewport_width
	tela_cima.position = top_start
	tela_baixo.position = bottom_start

	var tween := _create_layer_tween()
	tween.tween_property(tela_cima, "position", top_end, INTRO_DURATION)
	tween.tween_property(tela_baixo, "position", bottom_end, INTRO_DURATION)
	await tween.finished


func _play_outro_animation() -> void:
	if not tela_cima.visible or not tela_baixo.visible:
		return

	var viewport_width := get_viewport_rect().size.x
	var top_end := top_home_position
	var bottom_end := bottom_home_position

	top_end.x += viewport_width
	bottom_end.x -= viewport_width

	var tween := _create_layer_tween()
	tween.tween_property(tela_cima, "position", top_end, OUTRO_DURATION)
	tween.tween_property(tela_baixo, "position", bottom_end, OUTRO_DURATION)
	await tween.finished


func _play_professor_pop() -> void:
	professor.pivot_offset = professor.size / 2.0
	professor.scale = Vector2(0.85, 1.12)

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(professor, "scale", Vector2.ONE, PROFESSOR_POP_DURATION)


func _create_layer_tween() -> Tween:
	var tween := create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	return tween


func _on_skip_pressed() -> void:
	if is_transitioning:
		return

	if scene_index == SCENES.size() - 1:
		$Skip.disabled = true
		SceneTransition.fade_change_scene("res://scenes/character_select.tscn")
		return

	is_transitioning = true
	$Skip.disabled = true
	await _play_outro_animation()
	scene_index += 1
	_apply_scene()
	_play_professor_pop()
	await _play_intro_animation()
	$Skip.disabled = false
	is_transitioning = false
