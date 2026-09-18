extends Control

const INTRO_DURATION := 0.8
const OUTRO_DURATION := 0.45

@onready var tela_cima: TextureRect = $TelaCima
@onready var tela_baixo: TextureRect = $TelaBaixo


func _ready() -> void:
	_play_intro_animation()


func _play_intro_animation() -> void:
	var viewport_width := get_viewport_rect().size.x
	var top_end := tela_cima.position
	var bottom_end := tela_baixo.position
	var top_start := top_end
	var bottom_start := bottom_end

	top_start.x += viewport_width
	bottom_start.x -= viewport_width
	tela_cima.position = top_start
	tela_baixo.position = bottom_start

	var tween := _create_layer_tween()
	tween.tween_property(tela_cima, "position", top_end, INTRO_DURATION)
	tween.tween_property(tela_baixo, "position", bottom_end, INTRO_DURATION)


func _play_outro_animation() -> void:
	var viewport_width := get_viewport_rect().size.x
	var top_end := tela_cima.position
	var bottom_end := tela_baixo.position

	top_end.x += viewport_width
	bottom_end.x -= viewport_width

	var tween := _create_layer_tween()
	tween.tween_property(tela_cima, "position", top_end, OUTRO_DURATION)
	tween.tween_property(tela_baixo, "position", bottom_end, OUTRO_DURATION)
	await tween.finished


func _create_layer_tween() -> Tween:
	var tween := create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	return tween
