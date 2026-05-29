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
			print("ACERTOU O JOGADOR")
			spawn_sparks(global_position, self, Color(1.0, 0.1, 0.3)) # Cyberpunk crimson-neon sparks
			if body.has_method("receber_dano"):
				body.receber_dano()

		queue_free()
		return

	# Bala do jogador
	if body.is_in_group("inimigos") or body.is_in_group("inimigo"):
		spawn_sparks(global_position, self, Color(1.0, 0.5, 0.0)) # Cyberpunk orange-neon sparks
		body.morrer()
	else:
		spawn_sparks(global_position, self, Color(0.0, 0.8, 1.0)) # Cyberpunk cyan-neon sparks on walls

	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

static func spawn_sparks(pos: Vector2, parent_node: Node, color: Color = Color(1.0, 0.5, 0.0)):
	var particles = CPUParticles2D.new()
	particles.global_position = pos
	particles.emitting = true
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.amount = 15
	particles.lifetime = 0.4
	particles.spread = 180.0
	particles.gravity = Vector2(0, 450)
	particles.initial_velocity_min = 120.0
	particles.initial_velocity_max = 240.0
	particles.color = color
	particles.scale_amount_min = 2.0
	particles.scale_amount_max = 4.5
	parent_node.get_tree().current_scene.add_child(particles)
	
	# Auto delete particles after emission ends
	await parent_node.get_tree().create_timer(0.45).timeout
	particles.queue_free()
