extends CanvasLayer

@onready var hud = $"../CanvasLayer"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	process_mode=Node.PROCESS_MODE_ALWAYS
	
func _unhandled_input(event: InputEvent) -> void:
	if get_tree().paused:
		return
	if event.is_action_pressed("ui_cancel") and !event.is_echo():
		if visible == false:
			visible = true
			hud.hide()
			
			get_tree().paused = true
			$AudioStreamPlayer.play()
		else:
			$AudioStreamPlayer.stop()
			visible = false
			hud.show()
			get_tree().paused = false

func _on_voltar_pressed() -> void:
	$AudioStreamPlayer.stop()
	visible = false
	hud.show()
	get_tree().paused = false


func _on_sair_pressed() -> void:
	get_tree().quit()
