extends Node

# Autoload (Singleton) responsável por guardar escolhas do jogador
# que precisam sobreviver à troca de cena, como o personagem
# selecionado na tela de seleção.


enum Character {
	GABRIEL,
	LAURA
}


var selected_character: Character = Character.GABRIEL


func select_gabriel() -> void:
	selected_character = Character.GABRIEL


func select_laura() -> void:
	selected_character = Character.LAURA
