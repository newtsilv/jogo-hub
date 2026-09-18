extends CanvasLayer

# Autoload (Singleton) responsável pela transição de cena em "íris":
# um círculo que fecha até a tela ficar preta, troca de cena, e depois
# abre revelando a cena nova.

const CIRCLE_WIPE_SHADER := preload("res://assets/shaders/circle_wipe.gdshader")

@export var default_duration: float = 0.6

var _wipe_rect: ColorRect
var _fade_rect: ColorRect
var _material: ShaderMaterial
var _max_radius: float = 1.0


func _ready() -> void:
	layer = 128

	_wipe_rect = ColorRect.new()
	_wipe_rect.name = "WipeRect"
	_wipe_rect.color = Color(0, 0, 0, 1)
	_wipe_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_wipe_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_wipe_rect)

	_material = ShaderMaterial.new()
	_material.shader = CIRCLE_WIPE_SHADER
	_wipe_rect.material = _material

	_fade_rect = ColorRect.new()
	_fade_rect.name = "FadeRect"
	_fade_rect.color = Color(0, 0, 0, 1)
	_fade_rect.modulate.a = 0.0
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_fade_rect)

	_update_max_radius()
	_set_radius(_max_radius) # começa totalmente aberto (sem preto visível)


func _update_max_radius() -> void:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var aspect: float = viewport_size.x / viewport_size.y

	_material.set_shader_parameter("aspect", aspect)
	_max_radius = sqrt(pow(0.5 * aspect, 2.0) + pow(0.5, 2.0)) + 0.02


func _set_radius(value: float) -> void:
	_material.set_shader_parameter("radius", value)


## Fecha o círculo (revela preto) até cobrir a tela inteira.
func close(duration: float = -1.0, center: Vector2 = Vector2(0.5, 0.5)) -> void:
	if duration < 0.0:
		duration = default_duration

	_update_max_radius()
	_material.set_shader_parameter("center", center)

	var tween: Tween = create_tween()
	tween.tween_method(
		_set_radius, _max_radius, 0.0, duration
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)

	await tween.finished


## Abre o círculo a partir do centro, revelando a cena atual.
func open(duration: float = -1.0, center: Vector2 = Vector2(0.5, 0.5)) -> void:
	if duration < 0.0:
		duration = default_duration

	_update_max_radius()
	_material.set_shader_parameter("center", center)

	var tween: Tween = create_tween()
	tween.tween_method(
		_set_radius, 0.0, _max_radius, duration
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	await tween.finished


## Fecha o círculo, troca de cena e abre de novo revelando a cena nova.
func change_scene(
	scene_path: String,
	duration: float = -1.0,
	center: Vector2 = Vector2(0.5, 0.5)
) -> void:
	await close(duration, center)

	get_tree().change_scene_to_file(scene_path)

	# Deixa a cena nova terminar de entrar e desenhar o primeiro frame
	# antes de começar a abrir o círculo.
	await get_tree().process_frame
	await get_tree().process_frame

	await open(duration, center)


## Faz fade para preto, troca de cena e volta do preto para a cena nova.
func fade_change_scene(
	scene_path: String,
	duration: float = -1.0
) -> void:
	if duration < 0.0:
		duration = default_duration

	var fade_out: Tween = create_tween()
	fade_out.tween_property(_fade_rect, "modulate:a", 1.0, duration)
	await fade_out.finished

	get_tree().change_scene_to_file(scene_path)

	await get_tree().process_frame
	await get_tree().process_frame

	var fade_in: Tween = create_tween()
	fade_in.tween_property(_fade_rect, "modulate:a", 0.0, duration)
	await fade_in.finished
