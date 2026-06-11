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
@export var velocidade_patrulha := 55.0
@export var velocidade_perseguicao := 95.0
@export var distancia_patrulha := 760.0
@export var distancia_visao := 560.0
@export var distancia_ataque := 340.0
@export var distancia_parar := 170.0

var jogador: Node2D
var jogador_avistado := false
var atacando := false
var ataque_lancado := false
var tempo_para_lancar := 0.0
var tempo_para_fim_ataque := 0.0
var tempo_visual_ataque := 0.0
var morto := false
var direcao_patrulha := -1
var inicio_patrulha_x := 0.0

func _ready() -> void:
	add_to_group("inimigos")
	add_to_group("inimigo")
	jogador = get_tree().get_first_node_in_group("player")
	area_ataque.collision_mask = 4
	tempo_ataque.wait_time = intervalo_ataque
	ataque_visual.visible = false
	inicio_patrulha_x = global_position.x
	animacao.play("idle")

func _physics_process(delta: float) -> void:
	if morto:
		return

	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		velocity.y = 0

	if atacando:
		atualizar_ataque(delta)

	atualizar_comportamento()
	move_and_slide()
	virar_ao_bater_na_parede()

func atualizar_comportamento() -> void:
	if not is_instance_valid(jogador):
		jogador = get_tree().get_first_node_in_group("player")

	if jogador_esta_visivel():
		jogador_avistado = true

	if atacando:
		velocity.x = 0
		if is_instance_valid(jogador):
			olhar_para_jogador()
		return

	if jogador_avistado and is_instance_valid(jogador):
		perseguir_jogador()
		return

	patrulhar()

func patrulhar() -> void:
	var distancia_andada: float = abs(global_position.x - inicio_patrulha_x)
	if distancia_andada >= distancia_patrulha:
		virar_patrulha()

	velocity.x = direcao_patrulha * velocidade_patrulha
	atualizar_lado_visual(direcao_patrulha)
	if not atacando:
		tocar_idle()

func perseguir_jogador() -> void:
	var direcao_jogador: float = sign(jogador.global_position.x - global_position.x)
	var distancia_jogador: float = global_position.distance_to(jogador.global_position)

	if direcao_jogador == 0:
		direcao_jogador = direcao_patrulha

	atualizar_lado_visual(direcao_jogador)

	if distancia_jogador <= distancia_ataque:
		velocity.x = 0 if distancia_jogador <= distancia_parar else direcao_jogador * velocidade_perseguicao
		if tempo_ataque.is_stopped():
			tempo_ataque.start()
			atacar()
	elif distancia_jogador <= distancia_visao * 1.35:
		if not tempo_ataque.is_stopped():
			tempo_ataque.stop()
		velocity.x = direcao_jogador * velocidade_perseguicao
	else:
		jogador_avistado = false
		if not tempo_ataque.is_stopped():
			tempo_ataque.stop()
		patrulhar()

	if not atacando:
		tocar_idle()

func jogador_esta_visivel() -> bool:
	if not is_instance_valid(jogador):
		return false

	if global_position.distance_to(jogador.global_position) > distancia_visao:
		return false

	var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var query: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(global_position, jogador.global_position)
	query.exclude = [self]
	query.collision_mask = 1 | 4
	var resultado: Dictionary = space_state.intersect_ray(query)
	if resultado.is_empty():
		return true

	var collider: Variant = resultado.get("collider")
	return collider == jogador or (collider is Node and jogador.is_ancestor_of(collider))

func olhar_para_jogador() -> void:
	atualizar_lado_visual(sign(jogador.global_position.x - global_position.x))

func atualizar_lado_visual(direcao_x: float) -> void:
	if direcao_x == 0:
		return

	var olhando_para_esquerda: bool = direcao_x < 0
	animacao.flip_h = olhando_para_esquerda
	ataque_visual.scale.x = -1.0 if olhando_para_esquerda else 1.0

func virar_patrulha() -> void:
	direcao_patrulha *= -1
	inicio_patrulha_x = global_position.x
	atualizar_lado_visual(direcao_patrulha)

func virar_ao_bater_na_parede() -> void:
	if jogador_avistado:
		return

	for i in range(get_slide_collision_count()):
		var colisao: KinematicCollision2D = get_slide_collision(i)
		if abs(colisao.get_normal().x) > 0.6:
			virar_patrulha()
			return

func tocar_idle() -> void:
	if animacao.animation != "idle":
		animacao.play("idle")

func atacar() -> void:
	if morto or atacando or not jogador_avistado or not is_instance_valid(jogador):
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
		if not morto and not jogador_avistado:
			animacao.play("idle")

func lancar_projetil() -> void:
	if morto or not jogador_avistado or not is_instance_valid(jogador):
		return

	if projetil_ataque_scene == null:
		push_warning("Boss sem projetil_ataque_scene configurado.")
		return

	mostrar_ataque_visual()

	var projetil: Node2D = projetil_ataque_scene.instantiate()
	var lado: float = -1.0 if animacao.flip_h else 1.0
	var origem: Vector2 = global_position + Vector2(70.0 * lado, 0.0)
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

	var tween: Tween = create_tween()
	tween.tween_property(animacao, "modulate", Color(1.0, 0.35, 0.35), 0.05)
	tween.tween_property(animacao, "modulate", Color.WHITE, 0.1)

func _on_area_ataque_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not morto:
		jogador = body
		jogador_avistado = true

func _on_area_ataque_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		jogador_avistado = false
		tempo_ataque.stop()
		ataque_visual.visible = false
		animacao.play("idle")

func _on_tempo_ataque_timeout() -> void:
	if jogador_avistado and is_instance_valid(jogador) and global_position.distance_to(jogador.global_position) <= distancia_ataque:
		atacar()
