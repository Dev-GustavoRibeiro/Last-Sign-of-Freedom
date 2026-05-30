extends Control

@onready var score_label = $LabelScore

func _ready() -> void:
	# Display collected coins
	score_label.text = "SCORE: " + str(Global.coins) + " INIMIGOS DESTRUIDOS"
	# Reset coins for next match
	Global.coins = 0

func _on_jogar_novamente_pressed() -> void:
	get_tree().change_scene_to_file("res://src/scenes/world/level1.tscn")

func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://src/ui/menus/start_menu.tscn")

func _on_sair_pressed() -> void:
	get_tree().quit()
