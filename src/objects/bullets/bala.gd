extends Area2D

var speed = 400

# Bala do jogador
var direction = 1

# Bala do inimigo
var direcao: Vector2 = Vector2.ZERO

# Quem atirou
var dono = null

func _ready():

	if direcao != Vector2.ZERO:
		rotation = direcao.angle()

func _process(delta):

	if direcao != Vector2.ZERO:
		global_position += direcao * speed * delta
	else:
		position.x += speed * direction * delta

func _on_body_entered(body):

	# Ignora quem disparou
	if body == dono:
		return

	# Bala do inimigo
	if dono != null:

		if body.is_in_group("player"):
			get_tree().change_scene_to_file("res://src/ui/menus/game_over.tscn")


		queue_free()
		return

	# Bala do jogador
	if body.is_in_group("inimigos"):
		body.morrer()

	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
