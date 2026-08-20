extends Control

const PROFESSOR_POP_DURATION: float = 0.14
const TV_INTRO_DURATION: float = 0.35
const TV_ZOOM_DURATION: float = 0.65
const PROFESSOR_BOTTOM_MARGIN_RATIO: float = 0.08
const TV_TOP_OFFSET_RATIO: float = 0.34
const DESIGN_SIZE: Vector2 = Vector2(1080.0, 1920.0)

const CENA2_PROFESSOR: Texture2D = preload("res://assets/sprites/scenes/cena2/professor (2).png")
const CENA3_PROFESSOR: Texture2D = preload("res://assets/sprites/scenes/cena3/professor (3).png")

var scene_index: int = 0
var is_transitioning: bool = false
var tv_design_position: Vector2 = Vector2.ZERO
var tv_design_size: Vector2 = Vector2.ZERO

@onready var fundo: TextureRect = $Fundo
@onready var tv: TextureRect = $TV
@onready var professor: TextureRect = $Professor
@onready var skip_button: Button = $skip


func _ready() -> void:
	tv_design_position = tv.position
	tv_design_size = tv.size
	tv.visible = false
	_apply_responsive_layout()
	_play_professor_pop()
	resized.connect(_apply_responsive_layout)


func _apply_responsive_layout() -> void:
	var scale_factor: float = minf(size.x / DESIGN_SIZE.x, size.y / DESIGN_SIZE.y)
	var professor_texture: Texture2D = professor.texture
	var professor_size: Vector2 = professor_texture.get_size() * scale_factor
	var professor_bottom_margin: float = size.y * PROFESSOR_BOTTOM_MARGIN_RATIO
	var tv_size: Vector2 = tv_design_size * scale_factor
	var horizontal_margin: float = (size.x - DESIGN_SIZE.x * scale_factor) / 2.0
	var tv_extra_height: float = maxf(0.0, size.y - DESIGN_SIZE.y * scale_factor)

	fundo.set_anchors_preset(Control.PRESET_FULL_RECT)
	fundo.offset_left = 0.0
	fundo.offset_top = 0.0
	fundo.offset_right = 0.0
	fundo.offset_bottom = 0.0

	professor.size = professor_size
	professor.position = Vector2(
		(size.x - professor_size.x) / 2.0,
		size.y - professor_size.y - professor_bottom_margin
	)
	professor.pivot_offset = professor.size / 2.0

	tv.size = tv_size
	tv.position = Vector2(
		horizontal_margin + tv_design_position.x * scale_factor,
		tv_design_position.y * scale_factor + tv_extra_height * TV_TOP_OFFSET_RATIO
	)
	tv.pivot_offset = tv.size / 2.0

	skip_button.offset_left = 0.0
	skip_button.offset_top = 0.0
	skip_button.offset_right = size.x
	skip_button.offset_bottom = size.y


func _show_cena3_step() -> void:
	scene_index = 1
	professor.texture = CENA3_PROFESSOR
	_apply_responsive_layout()
	_play_professor_pop()
	_play_tv_intro()


func _play_professor_pop() -> void:
	professor.scale = Vector2(0.86, 1.12)

	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(professor, "scale", Vector2.ONE, PROFESSOR_POP_DURATION)


func _play_tv_intro() -> void:
	tv.visible = true
	tv.modulate.a = 1.0
	tv.scale = Vector2.ONE
	var tv_end: Vector2 = tv.position
	var tv_start: Vector2 = tv_end
	tv_start.x = -tv.size.x
	tv.position = tv_start

	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(tv, "position", tv_end, TV_INTRO_DURATION)


func _play_tv_zoom_transition() -> void:
	tv.visible = true
	pivot_offset = tv.position + tv.size / 2.0
	var zoom_scale: float = maxf(size.x / tv.size.x, size.y / tv.size.y) * 1.25

	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(self, "scale", Vector2(zoom_scale, zoom_scale), TV_ZOOM_DURATION)
	await tween.finished


func _on_skip_pressed() -> void:
	if is_transitioning:
		return

	if scene_index == 0:
		is_transitioning = true
		skip_button.disabled = true
		_show_cena3_step()
		await get_tree().create_timer(TV_INTRO_DURATION).timeout
		skip_button.disabled = false
		is_transitioning = false
		return

	is_transitioning = true
	skip_button.disabled = true
	await _play_tv_zoom_transition()
	SceneTransition.fade_change_scene("res://scenes/cena4.tscn")
