extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_iniciar_pressed() -> void:
	$start_menu_music_player.stop()
	get_tree().change_scene_to_file("res://src/scenes/world/level1.tscn")


func _on_sair_pressed() -> void:
	get_tree().quit()
