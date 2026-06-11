extends Control


func _on_jogar_novamente_pressed() -> void:
	Global.resetar_checkpoint()
	get_tree().change_scene_to_file(Global.CENA_FASE_1)


func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://src/ui/menus/menu_iniciar.tscn")
