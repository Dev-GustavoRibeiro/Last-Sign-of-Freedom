extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_jogar_novamente_pressed() -> void:
	get_tree().change_scene_to_file("res://src/scenes/world/level1.tscn")

func _on_mennu_pressed() -> void:
	get_tree().change_scene_to_file("res://src/ui/menus/start_menu.tscn")

func _on_sair_pressed() -> void:
	get_tree().quit()


func _on_jogar_novamente_mouse_entered() -> void:
	pass # Replace with function body.
	


func _on_jogar_novamente_mouse_exited() -> void:
	pass # Replace with function body.
