extends Node2D


@export var color_cycle_speed: float = 0.18
@export var glow_cycle_speed: float = 0.24


var time: float = 0.0

var polygon_palettes: Array = [
	[
		Color(0.85, 0.72, 1.0, 1.0),
		Color(0.42, 0.86, 1.0, 0.42),
		Color(1.0, 0.52, 0.78, 0.38),
		Color(0.55, 1.0, 0.78, 0.32)
	],
	[
		Color(1.0, 0.76, 0.58, 1.0),
		Color(0.78, 0.52, 1.0, 0.42),
		Color(0.42, 0.95, 1.0, 0.38),
		Color(1.0, 0.88, 0.48, 0.32)
	],
	[
		Color(0.68, 0.86, 1.0, 1.0),
		Color(1.0, 0.58, 0.9, 0.42),
		Color(0.82, 1.0, 0.6, 0.38),
		Color(0.76, 0.64, 1.0, 0.32)
	]
]

var glow_palettes: Array = [
	[
		Color(0.94, 0.46, 1.0, 0.18),
		Color(0.33, 0.96, 1.0, 0.16),
		Color(1.0, 0.82, 0.43, 0.14)
	],
	[
		Color(1.0, 0.38, 0.66, 0.2),
		Color(0.56, 0.43, 1.0, 0.18),
		Color(0.55, 1.0, 0.76, 0.15)
	],
	[
		Color(0.42, 0.9, 1.0, 0.18),
		Color(1.0, 0.72, 0.36, 0.16),
		Color(0.94, 0.52, 1.0, 0.14)
	]
]

var polygons: Array[Polygon2D] = []
var glows: Array[Sprite2D] = []


func _ready() -> void:
	for child: Node in get_children():
		if child is Polygon2D:
			polygons.append(child as Polygon2D)

		elif child is Sprite2D:
			glows.append(child as Sprite2D)


func _process(delta: float) -> void:
	time += delta
	animate_polygons()
	animate_glows()


func animate_polygons() -> void:
	for index: int in range(polygons.size()):
		var palette_colors: Array = get_shifted_colors(
			polygon_palettes,
			index,
			color_cycle_speed
		)

		if palette_colors.is_empty():
			continue

		polygons[index].color = palette_colors[index % palette_colors.size()]


func animate_glows() -> void:
	for index: int in range(glows.size()):
		var palette_colors: Array = get_shifted_colors(
			glow_palettes,
			index,
			glow_cycle_speed
		)

		if palette_colors.is_empty():
			continue

		glows[index].modulate = palette_colors[index % palette_colors.size()]


func get_shifted_colors(
	palettes: Array,
	phase_offset: int,
	speed: float
) -> Array:
	if palettes.is_empty():
		return []

	var palette_count: int = palettes.size()
	var cycle_position: float = fposmod(
		time * speed + float(phase_offset) * 0.17,
		float(palette_count)
	)

	var first_index: int = floori(cycle_position)
	var second_index: int = (first_index + 1) % palette_count
	var blend: float = smoothstep(0.0, 1.0, cycle_position - first_index)

	var first_palette: Array = palettes[first_index]
	var second_palette: Array = palettes[second_index]
	var color_count: int = mini(first_palette.size(), second_palette.size())
	var shifted_colors: Array = []

	for color_index: int in range(color_count):
		var first_color: Color = first_palette[color_index] as Color
		var second_color: Color = second_palette[color_index] as Color

		shifted_colors.append(
			first_color.lerp(second_color, blend)
		)

	return shifted_colors
