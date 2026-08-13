extends Control


@onready var personagem_esquerda: TextureRect = $PersonagemEsquerda
@onready var personagem_direita: TextureRect = $PersonagemDireita

# Posição final (de descanso) de cada personagem, igual à arte de fundo.
var _pos_final_esquerda: float
var _pos_final_direita: float


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_pos_final_esquerda = personagem_esquerda.offset_left
	_pos_final_direita = personagem_direita.offset_left

	_animar_chegada_dos_personagens()


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

#start
func _on_start_pressed() -> void:
	SceneTransition.change_scene("res://scenes/cena2.tscn")

#Quit
func _on_quit_pressed() -> void:
	get_tree().quit()

#Crédito
func _on_credt_pressed() -> void:
	pass # Replace with function body.
