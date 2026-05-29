extends Control

@onready var score_label = $LabelScore

func _ready() -> void:
	# Exibe as moedas coletadas
	score_label.text = "SCORE: " + str(Global.moedas) + " INIMIGOS DESTRUIDOS"
	# Reseta as moedas para a próxima partida
	Global.moedas = 0

func _on_jogar_novamente_pressed() -> void:
	get_tree().change_scene_to_file("res://src/scenes/mundo/mundo.tscn")

func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://src/ui/menus/menu_iniciar.tscn")

func _on_sair_pressed() -> void:
	get_tree().quit()
