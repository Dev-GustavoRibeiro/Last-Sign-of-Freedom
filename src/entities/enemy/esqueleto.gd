extends CharacterBody2D

@onready var detector_colisao: RayCast2D = $detector_colisao
@onready var animacao_esqueleto: AnimatedSprite2D = $animacao_esqueleto
@onready var ponto_tiro: Marker2D = $PontoTiro

@export var bala_scene: PackedScene

const SPEED = 30.0
var direction := 1

var jogador: Node2D
var jogador_detectado := false

@export var e_chefe: bool = false
@export var vida: int = 1
var morto: bool = false

func _ready():
	jogador = get_tree().get_first_node_in_group("player")
	animacao_esqueleto.play("andando")

	if name == "esqueleto4":
		e_chefe = true
		vida = 6
		self.modulate = Color(1.0, 0.4, 0.4)
		self.scale = Vector2(1.6, 1.6)

func _physics_process(delta: float) -> void:

	if not is_on_floor():
		velocity += get_gravity() * delta

	if jogador_detectado:

		# Para completamente
		velocity.x = 0

		# Olha para o jogador
		if jogador:
			animacao_esqueleto.flip_h = jogador.global_position.x < global_position.x

		# Só toca idle se não estiver atirando ou morrendo
		if animacao_esqueleto.animation != "atirando" and animacao_esqueleto.animation != "morte":
			if animacao_esqueleto.animation != "idle":
				animacao_esqueleto.play("idle")

	else:

		# Patrulha
		if detector_colisao.is_colliding():
			direction *= -1
			detector_colisao.scale.x *= -1
			animacao_esqueleto.scale.x *= -1

		velocity.x = direction * SPEED

		if animacao_esqueleto.animation != "andando":
			animacao_esqueleto.play("andando")

	move_and_slide()

func atirar():

	if jogador == null:
		return

	animacao_esqueleto.play("atirando")

	var bala = bala_scene.instantiate()
	bala.dono = self
	bala.global_position = ponto_tiro.global_position

	var direcao = (jogador.global_position - ponto_tiro.global_position).normalized()
	bala.direcao = direcao

	get_tree().current_scene.add_child(bala)

func _on_timer_timeout() -> void:

	if jogador_detectado:
		atirar()

func _on_areadeteccao_body_entered(body: Node2D) -> void:

	if body.is_in_group("player"):
		jogador_detectado = true

func _on_areadeteccao_body_exited(body: Node2D) -> void:

	if body.is_in_group("player"):
		jogador_detectado = false

func _on_animacao_esqueleto_animation_finished() -> void:

	if animacao_esqueleto.animation == "morte":
		if e_chefe:
			get_tree().change_scene_to_file("res://src/ui/menus/vitoria.tscn")
		else:
			queue_free()

	elif animacao_esqueleto.animation == "atirando":

		if jogador_detectado:
			animacao_esqueleto.play("idle")
		else:
			animacao_esqueleto.play("andando")

func morrer():
	if morto:
		return

	if e_chefe:
		vida -= 1
		if vida > 0:
			var original_color = self.modulate
			self.modulate = Color(1.0, 1.0, 1.0)
			await get_tree().create_timer(0.15).timeout
			self.modulate = original_color
			return

	morto = true
	Global.moedas += 1
	spawn_death_particles()
	animacao_esqueleto.play("morte")
	set_physics_process(false)

func spawn_death_particles():
	var particles = CPUParticles2D.new()
	particles.global_position = global_position + Vector2(55, 12)
	particles.emitting = true
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.amount = 35
	particles.lifetime = 0.5
	particles.spread = 360.0
	particles.gravity = Vector2(0, 300)
	particles.initial_velocity_min = 150.0
	particles.initial_velocity_max = 280.0
	particles.color = Color(0.9, 0.1, 0.6) if e_chefe else Color(1.0, 0.4, 0.1)
	particles.scale_amount_min = 2.5
	particles.scale_amount_max = 6.0
	get_tree().current_scene.add_child(particles)

	await get_tree().create_timer(0.6).timeout
	particles.queue_free()
