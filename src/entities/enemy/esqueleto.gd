extends CharacterBody2D

@onready var detector_colisao: RayCast2D = $detector_colisao
@onready var animacao_esqueleto: AnimatedSprite2D = $animacao_esqueleto
@onready var ponto_tiro: Marker2D = $PontoTiro

@export var bala_scene: PackedScene

var speed = 30.0
var direction := 1

var jogador: Node2D
var jogador_detectado := false

@export var e_chefe: bool = false
@export var vida: int = 1
var morto: bool = false

func _ready():
	jogador = get_tree().get_first_node_in_group("player")
	animacao_esqueleto.play("andando")

	var is_fase2 = (get_tree().current_scene.name == "fase2")

	if name == "esqueleto4":
		e_chefe = true
		if is_fase2:
			vida = 10
			self.modulate = Color(1.0, 0.1, 1.0) # Hot neon magenta
			self.scale = Vector2(2.0, 2.0)
		else:
			vida = 6
			self.modulate = Color(1.0, 0.4, 0.4)
			self.scale = Vector2(1.6, 1.6)
	elif is_fase2:
		speed = 55.0

	setup_aura()

func _physics_process(delta: float) -> void:

	if not is_on_floor():
		velocity += get_gravity() * delta

	# Adjust sprite scale based on active animation to prevent shrinking/distortion
	var base_scale = Vector2(0.11191573, 0.08449935)
	if animacao_esqueleto.animation == "atirando" or animacao_esqueleto.animation == "idle":
		animacao_esqueleto.scale = base_scale * Vector2(307.0 / 158.0, 1024.0 / 529.0)
	else:
		animacao_esqueleto.scale = base_scale

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
			detector_colisao.scale.x = direction
			animacao_esqueleto.flip_h = (direction < 0)

		velocity.x = direction * speed

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
			if get_tree().current_scene.name == "mundo":
				get_tree().change_scene_to_file("res://src/scenes/mundo/fase2.tscn")
			else:
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

func setup_aura():
	var aura = CPUParticles2D.new()
	aura.name = "EnemyAura"
	aura.amount = 12 if e_chefe else 6
	aura.lifetime = 0.8
	aura.preprocess = 0.8
	aura.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	aura.emission_sphere_radius = 26.0 if e_chefe else 15.0
	aura.gravity = Vector2(0, -35)
	aura.color = Color(1.0, 0.1, 0.2, 0.3) # Neon red-crimson glowing aura
	aura.scale_amount_min = 4.0
	aura.scale_amount_max = 8.0
	add_child(aura)
	move_child(aura, 0)
