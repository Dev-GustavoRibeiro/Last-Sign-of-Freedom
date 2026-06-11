extends CharacterBody2D

@onready var detector_colisao: RayCast2D = $detector_colisao
@onready var animacao_esqueleto: AnimatedSprite2D = $animacao_esqueleto
@onready var ponto_tiro: Marker2D = $PontoTiro
@onready var timer: Timer = $Timer
@onready var area_deteccao: Area2D = $Areadeteccao

@export var bala_scene: PackedScene
@export var distancia_patrulha = 120.0

const SPEED = 30.0
const ESCALA_POR_ANIMACAO := {
	"andando": 1.1,
	"atirando": 1.1,
	"idle": 2.1,
	"morte": 1.1,
}
const PONTO_TIRO_DIREITA := Vector2(83, 16)
const PONTO_TIRO_ESQUERDA := Vector2(27, 16)
const OFFSET_SAIDA_BALA = 0.0

var direction := 1
var inicio_patrulha_x := 0.0
var escala_animacao_base := Vector2.ONE

var jogador: Node2D
var jogador_detectado := false
var morto := false

func _ready():
	add_to_group("inimigos")
	add_to_group("inimigo")
	jogador = get_tree().get_first_node_in_group("player")
	area_deteccao.collision_mask = 4
	inicio_patrulha_x = global_position.x
	escala_animacao_base = Vector2(abs(animacao_esqueleto.scale.x), abs(animacao_esqueleto.scale.y))
	atualizar_lado_visual(direction)
	tocar_animacao("andando")

func _physics_process(delta: float) -> void:

	if not is_on_floor():
		velocity += get_gravity() * delta

	if jogador_detectado:

		# Para completamente
		velocity.x = 0

		# Olha para o jogador
		if jogador:
			var direcao_jogador = calcular_direcao_jogador()
			if direcao_jogador != 0:
				atualizar_lado_visual(direcao_jogador)

		# Só toca idle se não estiver atirando ou morrendo
		if animacao_esqueleto.animation != "atirando" and animacao_esqueleto.animation != "morte":
			tocar_animacao("idle")

	else:

		# Patrulha
		var distancia_andada = abs(global_position.x - inicio_patrulha_x)
		if distancia_andada >= distancia_patrulha or detector_colisao.is_colliding():
			virar_patrulha()

		velocity.x = direction * SPEED

		atualizar_lado_visual(direction)
		tocar_animacao("andando")

	move_and_slide()

func virar_patrulha():
	direction *= -1
	inicio_patrulha_x = global_position.x
	detector_colisao.scale.x *= -1
	atualizar_lado_visual(direction)

func atualizar_lado_visual(direcao_x):
	animacao_esqueleto.flip_h = direcao_x < 0
	ponto_tiro.position = PONTO_TIRO_ESQUERDA if direcao_x < 0 else PONTO_TIRO_DIREITA
	aplicar_escala_animacao(animacao_esqueleto.animation)

func aplicar_escala_animacao(nome_animacao):
	var multiplicador = ESCALA_POR_ANIMACAO.get(String(nome_animacao), 1.0)
	animacao_esqueleto.scale = escala_animacao_base * multiplicador

func tocar_animacao(nome_animacao, reiniciar := false):
	aplicar_escala_animacao(nome_animacao)

	if reiniciar or animacao_esqueleto.animation != nome_animacao:
		animacao_esqueleto.play(nome_animacao)

func calcular_direcao_jogador():
	var alvo = jogador
	var colisao_jogador = jogador.get_node_or_null("colisao_personagem")
	if colisao_jogador:
		alvo = colisao_jogador

	return sign(alvo.global_position.x - global_position.x)

func calcular_posicao_alvo_jogador() -> Vector2:
	var alvo = jogador
	var colisao_jogador = jogador.get_node_or_null("colisao_personagem")
	if colisao_jogador:
		alvo = colisao_jogador

	return alvo.global_position

func atirar():

	if morto or jogador == null:
		return

	var direcao_x = calcular_direcao_jogador()
	if direcao_x == 0:
		direcao_x = direction

	atualizar_lado_visual(direcao_x)
	tocar_animacao("atirando", true)

	var bala = bala_scene.instantiate()
	bala.dono = self
	bala.direcao = (calcular_posicao_alvo_jogador() - ponto_tiro.global_position).normalized()
	if bala.direcao == Vector2.ZERO:
		bala.direcao = Vector2(direcao_x, 0)
	bala.global_position = ponto_tiro.global_position + bala.direcao * OFFSET_SAIDA_BALA

	get_tree().current_scene.add_child(bala)

func _on_timer_timeout() -> void:

	if jogador_detectado and not morto:
		atirar()

func _on_areadeteccao_body_entered(body: Node2D) -> void:

	if body.is_in_group("player") and not morto:
		jogador_detectado = true

func _on_areadeteccao_body_exited(body: Node2D) -> void:

	if body.is_in_group("player") and not morto:
		jogador_detectado = false
		atualizar_lado_visual(direction)
		tocar_animacao("andando")

func _on_animacao_esqueleto_animation_finished() -> void:

	if animacao_esqueleto.animation == "morte":
		queue_free()

	elif animacao_esqueleto.animation == "atirando":

		if morto:
			return
		elif jogador_detectado:
			tocar_animacao("idle")
		else:
			tocar_animacao("andando")

func morrer():

	if morto:
		return

	morto = true
	remove_from_group("inimigos")
	remove_from_group("inimigo")
	jogador_detectado = false
	velocity = Vector2.ZERO
	timer.stop()
	area_deteccao.monitoring = false
	tocar_animacao("morte")
	set_physics_process(false)
