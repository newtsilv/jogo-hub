extends Control

const BUTTON_HOVER_SCALE := Vector2(1.015, 1.015)
const BUTTON_NORMAL_SCALE := Vector2.ONE
const BUTTON_HOVER_DURATION := 0.2
const LOGO_ANIMATION_DURATION := 0.45

@onready var logo: TextureRect = $Logo
@onready var personagem_esquerda: TextureRect = $PersonagemEsquerda
@onready var personagem_direita: TextureRect = $PersonagemDireita
@onready var menu_buttons: Array[Button] = [
	$StartHitbox,
	$QuitHitbox,
	$CredtHitbox,
]
@onready var button_art_by_hitbox := {
	$StartHitbox: $Start,
	$QuitHitbox: $Quit,
	$CredtHitbox: $Credt,
}

# Posição final (de descanso) de cada personagem, igual à arte de fundo.
var _pos_final_esquerda: float
var _pos_final_direita: float
var button_hover_tweens := {}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_pos_final_esquerda = personagem_esquerda.offset_left
	_pos_final_direita = personagem_direita.offset_left
	_configurar_botoes()

	_animar_logo()
	_animar_chegada_dos_personagens()


func _configurar_botoes() -> void:
	for button: Button in menu_buttons:
		var button_art: TextureRect = button_art_by_hitbox[button]
		button_art.pivot_offset = button_art.size / 2.0
		button.mouse_entered.connect(_on_menu_button_mouse_entered.bind(button))
		button.mouse_exited.connect(_on_menu_button_mouse_exited.bind(button))


func _animar_logo() -> void:
	logo.pivot_offset = logo.size / 2.0
	logo.modulate.a = 0.0
	logo.scale = Vector2(0.85, 0.85)

	var tween := create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(logo, "scale", Vector2.ONE, LOGO_ANIMATION_DURATION)
	tween.tween_property(logo, "modulate:a", 1.0, LOGO_ANIMATION_DURATION)


func _animar_chegada_dos_personagens() -> void:
	var largura_tela: float = size.x

	# Começam fora da tela, cada um do seu lado.
	personagem_esquerda.position.x = -personagem_esquerda.size.x
	personagem_direita.position.x = largura_tela

	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(personagem_esquerda, "position:x", _pos_final_esquerda, 0.8)
	tween.tween_property(personagem_direita, "position:x", _pos_final_direita, 0.8).set_delay(0.1)


func _on_menu_button_mouse_entered(button: Button) -> void:
	_animar_zoom_botao(button, BUTTON_HOVER_SCALE)


func _on_menu_button_mouse_exited(button: Button) -> void:
	_animar_zoom_botao(button, BUTTON_NORMAL_SCALE)


func _animar_zoom_botao(button: Button, target_scale: Vector2) -> void:
	var button_art: TextureRect = button_art_by_hitbox[button]

	if button_hover_tweens.has(button):
		button_hover_tweens[button].kill()

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(button_art, "scale", target_scale, BUTTON_HOVER_DURATION)
	button_hover_tweens[button] = tween

#start
func _on_start_pressed() -> void:
	SceneTransition.change_scene("res://scenes/cena2.tscn")

#Quit
func _on_quit_pressed() -> void:
	get_tree().quit()

#Crédito
func _on_credt_pressed() -> void:
	SceneTransition.fade_change_scene("res://scenes/creditos.tscn")
