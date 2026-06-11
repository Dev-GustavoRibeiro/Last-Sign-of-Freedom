extends Area2D

@export var velocidade := 230.0

var direcao := Vector2.RIGHT
var dono: Node

func _ready() -> void:
	if direcao == Vector2.ZERO:
		direcao = Vector2.RIGHT

	direcao = direcao.normalized()
	rotation = direcao.angle()

func _physics_process(delta: float) -> void:
	global_position += direcao * velocidade * delta

func _on_body_entered(body: Node2D) -> void:
	if body == dono:
		return

	if body.is_in_group("player"):
		if body.has_method("morrer"):
			body.morrer()
		else:
			var erro := get_tree().change_scene_to_file("res://src/ui/menus/game_over.tscn")
			if erro != OK:
				push_error("Erro ao carregar a cena de game over: " + str(erro))

	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
