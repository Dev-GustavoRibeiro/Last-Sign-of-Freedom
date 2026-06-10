extends CharacterBody2D

@onready var animacao: AnimatedSprite2D = $AnimatedSprite2D
@onready var area_ataque: Area2D = $AreaAtaque
@onready var ataque_visual: Node2D = $AtaqueVisual
@onready var tempo_ataque: Timer = $TempoAtaque

@export var projetil_ataque_scene: PackedScene
@export var intervalo_ataque := 1.2
@export var atraso_lancamento := 0.35
@export var tempo_recuperacao_ataque := 0.35
@export var vida := 8

var jogador: Node2D
var jogador_no_alcance := false
var atacando := false
var ataque_lancado := false
var tempo_para_lancar := 0.0
var tempo_para_fim_ataque := 0.0
var tempo_visual_ataque := 0.0
var morto := false

func _ready() -> void:
	add_to_group("inimigos")
	jogador = get_tree().get_first_node_in_group("player")
	area_ataque.collision_mask = 4
	tempo_ataque.wait_time = intervalo_ataque
	ataque_visual.visible = false
	animacao.play("idle")

func _physics_process(delta: float) -> void:
	if morto:
		return

	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		velocity.x = 0

	if atacando:
		atualizar_ataque(delta)

	if jogador_no_alcance and is_instance_valid(jogador):
		olhar_para_jogador()
	elif not atacando and animacao.animation != "idle":
		animacao.play("idle")

	move_and_slide()

func olhar_para_jogador() -> void:
	var olhando_para_esquerda := jogador.global_position.x < global_position.x
	animacao.flip_h = olhando_para_esquerda
	ataque_visual.scale.x = -1.0 if olhando_para_esquerda else 1.0

func atacar() -> void:
	if morto or atacando or not jogador_no_alcance or not is_instance_valid(jogador):
		return

	atacando = true
	olhar_para_jogador()
	animacao.play("ataque")
	animacao.frame = 0
	ataque_lancado = false
	tempo_para_lancar = atraso_lancamento
	tempo_para_fim_ataque = atraso_lancamento + tempo_recuperacao_ataque

func atualizar_ataque(delta: float) -> void:
	tempo_visual_ataque -= delta
	if tempo_visual_ataque <= 0.0:
		ataque_visual.visible = false

	if not ataque_lancado:
		tempo_para_lancar -= delta
		if tempo_para_lancar <= 0.0:
			ataque_lancado = true
			lancar_projetil()

	tempo_para_fim_ataque -= delta
	if tempo_para_fim_ataque <= 0.0:
		atacando = false
		if not morto and not jogador_no_alcance:
			animacao.play("idle")

func lancar_projetil() -> void:
	if morto or not jogador_no_alcance or not is_instance_valid(jogador):
		return

	if projetil_ataque_scene == null:
		push_warning("Boss sem projetil_ataque_scene configurado.")
		return

	mostrar_ataque_visual()

	var projetil = projetil_ataque_scene.instantiate()
	var lado := -1.0 if animacao.flip_h else 1.0
	var origem := global_position + Vector2(70.0 * lado, 0.0)
	projetil.global_position = origem
	projetil.set("direcao", (jogador.global_position - origem).normalized())
	projetil.set("dono", self)
	get_tree().current_scene.add_child(projetil)

func mostrar_ataque_visual() -> void:
	ataque_visual.visible = true
	ataque_visual.modulate = Color.WHITE
	ataque_visual.scale.y = 1.0
	tempo_visual_ataque = 0.18

func morrer() -> void:
	if morto:
		return

	vida -= 1

	if vida <= 0:
		morto = true
		atacando = false
		ataque_lancado = false
		tempo_ataque.stop()
		area_ataque.monitoring = false
		ataque_visual.visible = false
		queue_free()
		return

	var tween := create_tween()
	tween.tween_property(animacao, "modulate", Color(1.0, 0.35, 0.35), 0.05)
	tween.tween_property(animacao, "modulate", Color.WHITE, 0.1)

func _on_area_ataque_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not morto:
		jogador = body
		jogador_no_alcance = true
		atacar()
		tempo_ataque.start()

func _on_area_ataque_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		jogador_no_alcance = false
		tempo_ataque.stop()
		ataque_visual.visible = false
		animacao.play("idle")

func _on_tempo_ataque_timeout() -> void:
	atacar()
