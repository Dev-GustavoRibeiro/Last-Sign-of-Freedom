extends CharacterBody2D

@onready var detector_colisao: RayCast2D = $detector_colisao
@onready var animacao_esqueleto: AnimatedSprite2D = $animacao_esqueleto
@onready var ponto_tiro: Marker2D = $PontoTiro
@onready var timer: Timer = $Timer
@onready var area_deteccao: Area2D = $Areadeteccao

@export var bala_scene: PackedScene
@export var distancia_patrulha = 120.0

const SPEED = 30.0
var direction := 1
var inicio_patrulha_x := 0.0

var jogador: Node2D
var jogador_detectado := false
var morto := false

func _ready():
	jogador = get_tree().get_first_node_in_group("player")
	inicio_patrulha_x = global_position.x
	animacao_esqueleto.play("andando")

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
		var distancia_andada = abs(global_position.x - inicio_patrulha_x)
		if distancia_andada >= distancia_patrulha or detector_colisao.is_colliding():
			virar_patrulha()

		velocity.x = direction * SPEED

		if animacao_esqueleto.animation != "andando":
			animacao_esqueleto.play("andando")

		move_and_slide()


	
	

func virar_patrulha():
	direction *= -1
	inicio_patrulha_x = global_position.x
	detector_colisao.scale.x *= -1
	animacao_esqueleto.scale.x *= -1

func atirar():

	if morto or jogador == null:
		return

	animacao_esqueleto.play("atirando")

	var bala = bala_scene.instantiate()
	bala.dono = self
	bala.global_position = ponto_tiro.global_position

	var direcao_x = sign(jogador.global_position.x - ponto_tiro.global_position.x)
	if direcao_x == 0:
		direcao_x = -1 if animacao_esqueleto.flip_h else 1

	bala.direcao = Vector2(direcao_x, 0)

	get_tree().current_scene.add_child(bala)

func _on_timer_timeout() -> void:

	if jogador_detectado and not morto:
		atirar()

func _on_areadeteccao_body_entered(body: Node2D) -> void:

	if body.is_in_group("player") and not morto:
		jogador_detectado = true

func _on_areadeteccao_body_exited(body: Node2D) -> void:

	if body.is_in_group("player"):
		jogador_detectado = false

func _on_animacao_esqueleto_animation_finished() -> void:

	if animacao_esqueleto.animation == "morte":
		queue_free()

	elif animacao_esqueleto.animation == "atirando":

		if morto:
			return
		elif jogador_detectado:
			animacao_esqueleto.play("idle")
		else:
			animacao_esqueleto.play("andando")

func morrer():

	if morto:
		return

	morto = true
	jogador_detectado = false
	velocity = Vector2.ZERO
	timer.stop()
	area_deteccao.monitoring = false
	animacao_esqueleto.play("morte")
	set_physics_process(false)
