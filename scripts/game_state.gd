extends Node

# Autoload (Singleton) responsável por guardar escolhas do jogador
# que precisam sobreviver à troca de cena, como o personagem
# selecionado na tela de seleção.


enum Character {
	PEDRO,
	MARIA
}


var selected_character: Character = Character.PEDRO


func select_pedro() -> void:
	selected_character = Character.PEDRO


func select_maria() -> void:
	selected_character = Character.MARIA
