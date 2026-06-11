extends CharacterBody2D

@onready var animacao: AnimatedSprite2D = $AnimatedSprite2D
@onready var colisao: CollisionShape2D = $CollisionShape2D
@onready var area_ataque: Area2D = $AreaAtaque
@onready var ataque_visual: Node2D = $AtaqueVisual
@onready var explosao_visual: Node2D = $ExplosaoVisual
@onready var tempo_ataque: Timer = $TempoAtaque

@export var projetil_ataque_scene: PackedScene
@export_file("*.tscn") var cena_vitoria := "res://src/ui/menus/vitoria.tscn"
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
@export var ignora_paredes_para_detectar := true
@export var amplitude_flutuacao := 32.0
@export var velocidade_flutuacao := 1.7
@export var limite_vertical_patrulha := 110.0
@export var recuo_parede := 12.0
@export var cooldown_colisao_parede := 0.18

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
var inicio_patrulha_y := 0.0
var tempo_flutuacao := 0.0
var tempo_sem_virar_parede := 0.0

func _ready() -> void:
	add_to_group("inimigos")
	add_to_group("inimigo")
	jogador = get_tree().get_first_node_in_group("player")
	area_ataque.collision_mask = 4
	tempo_ataque.wait_time = intervalo_ataque
	ataque_visual.visible = false
	explosao_visual.visible = false
	inicio_patrulha_x = global_position.x
	inicio_patrulha_y = global_position.y
	animacao.play("idle")

func _physics_process(delta: float) -> void:
	if morto:
		return

	tempo_flutuacao += delta
	tempo_sem_virar_parede = maxf(tempo_sem_virar_parede - delta, 0.0)

	if atacando:
		atualizar_ataque(delta)

	atualizar_comportamento(delta)
	move_and_slide()
	virar_ao_bater_na_parede()

func atualizar_comportamento(delta: float) -> void:
	if not is_instance_valid(jogador):
		jogador = get_tree().get_first_node_in_group("player")

	if jogador_esta_visivel():
		jogador_avistado = true

	if atacando:
		velocity = calcular_velocidade_flutuacao(global_position, delta, velocidade_patrulha, true)
		if is_instance_valid(jogador):
			olhar_para_jogador()
		return

	if jogador_avistado and is_instance_valid(jogador):
		perseguir_jogador(delta)
		return

	patrulhar(delta)

func patrulhar(delta: float) -> void:
	var distancia_andada: float = abs(global_position.x - inicio_patrulha_x)
	if distancia_andada >= distancia_patrulha:
		virar_patrulha()

	var alvo_patrulha: Vector2 = Vector2(
		inicio_patrulha_x + direcao_patrulha * min(distancia_patrulha, distancia_andada + 120.0),
		inicio_patrulha_y + sin(tempo_flutuacao * velocidade_flutuacao) * limite_vertical_patrulha
	)
	velocity = calcular_velocidade_flutuacao(alvo_patrulha, delta, velocidade_patrulha)
	atualizar_lado_visual(direcao_patrulha)
	if not atacando:
		tocar_idle()

func perseguir_jogador(delta: float) -> void:
	var direcao_jogador: float = sign(jogador.global_position.x - global_position.x)
	var alvo_jogador: Vector2 = obter_posicao_alvo_jogador()
	var distancia_jogador: float = global_position.distance_to(alvo_jogador)
	var deslocamento_y: float = clampf(
		alvo_jogador.y - inicio_patrulha_y,
		-limite_vertical_patrulha,
		limite_vertical_patrulha
	)
	var alvo_perseguicao: Vector2 = alvo_jogador + Vector2(0.0, deslocamento_y * 0.18)

	if direcao_jogador == 0:
		direcao_jogador = direcao_patrulha

	atualizar_lado_visual(direcao_jogador)

	if distancia_jogador <= distancia_ataque:
		if distancia_jogador <= distancia_parar:
			velocity = calcular_velocidade_flutuacao(global_position, delta, velocidade_patrulha, true)
		else:
			velocity = calcular_velocidade_flutuacao(alvo_perseguicao, delta, velocidade_perseguicao)
		if tempo_ataque.is_stopped():
			tempo_ataque.start()
			atacar()
	elif distancia_jogador <= distancia_visao * 1.35:
		if not tempo_ataque.is_stopped():
			tempo_ataque.stop()
		velocity = calcular_velocidade_flutuacao(alvo_perseguicao, delta, velocidade_perseguicao)
	else:
		jogador_avistado = false
		if not tempo_ataque.is_stopped():
			tempo_ataque.stop()
		patrulhar(delta)

	if not atacando:
		tocar_idle()

func jogador_esta_visivel() -> bool:
	if not is_instance_valid(jogador):
		return false

	if global_position.distance_to(jogador.global_position) > distancia_visao:
		return false

	if ignora_paredes_para_detectar:
		return true

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
	atualizar_lado_visual(sign(obter_posicao_alvo_jogador().x - global_position.x))

func obter_posicao_alvo_jogador() -> Vector2:
	if not is_instance_valid(jogador):
		return global_position

	var colisao_jogador: CollisionShape2D = jogador.get_node_or_null("colisao_personagem") as CollisionShape2D
	if colisao_jogador != null:
		return colisao_jogador.global_position

	return jogador.global_position

func atualizar_lado_visual(direcao_x: float) -> void:
	if direcao_x == 0:
		return

	var olhando_para_direita: bool = direcao_x > 0
	animacao.flip_h = olhando_para_direita
	ataque_visual.scale.x = 1.0 if olhando_para_direita else -1.0

func virar_patrulha() -> void:
	direcao_patrulha *= -1
	inicio_patrulha_x = global_position.x
	inicio_patrulha_y = global_position.y
	atualizar_lado_visual(direcao_patrulha)

func virar_ao_bater_na_parede() -> void:
	if tempo_sem_virar_parede > 0.0:
		return

	for i in range(get_slide_collision_count()):
		var colisao: KinematicCollision2D = get_slide_collision(i)
		var normal: Vector2 = colisao.get_normal()
		if abs(normal.x) > 0.6:
			global_position += normal * recuo_parede
			velocity.x = 0.0
			tempo_sem_virar_parede = cooldown_colisao_parede
			virar_patrulha()
			return
		if abs(normal.y) > 0.6:
			global_position += normal * (recuo_parede * 0.6)
			velocity.y = 0.0
			inicio_patrulha_y = clampf(global_position.y, inicio_patrulha_y - limite_vertical_patrulha, inicio_patrulha_y + limite_vertical_patrulha)
			tempo_sem_virar_parede = cooldown_colisao_parede
			return

func calcular_velocidade_flutuacao(alvo: Vector2, delta: float, velocidade_base: float, travar_x := false) -> Vector2:
	var alvo_flutuante: Vector2 = alvo + Vector2(0.0, sin(tempo_flutuacao * velocidade_flutuacao * TAU * 0.5) * amplitude_flutuacao)
	var deslocamento: Vector2 = alvo_flutuante - global_position
	var velocidade_alvo: Vector2 = deslocamento.normalized() * velocidade_base
	if deslocamento.length() < 6.0:
		velocidade_alvo = Vector2.ZERO
	elif deslocamento.length() < 90.0:
		velocidade_alvo *= clamp(deslocamento.length() / 90.0, 0.22, 1.0)

	if travar_x:
		velocidade_alvo.x = lerp(velocity.x, 0.0, min(delta * 6.0, 1.0))

	return velocity.lerp(velocidade_alvo, min(delta * 4.5, 1.0))

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
	var lado: float = 1.0 if animacao.flip_h else -1.0
	var origem: Vector2 = global_position + Vector2(70.0 * lado, -12.0)
	var direcao_projetil: Vector2 = (obter_posicao_alvo_jogador() - origem).normalized()
	if direcao_projetil == Vector2.ZERO:
		direcao_projetil = Vector2.RIGHT * lado
	projetil.global_position = origem
	projetil.set("direcao", direcao_projetil)
	projetil.set("dono", self)
	get_tree().current_scene.add_child(projetil)

func mostrar_ataque_visual() -> void:
	ataque_visual.visible = true
	ataque_visual.modulate = Color(1.0, 1.0, 1.0, 1.0)
	ataque_visual.scale.y = 1.0
	tempo_visual_ataque = 0.24

	var tween: Tween = create_tween()
	tween.set_parallel(true)
	ataque_visual.scale = Vector2(ataque_visual.scale.x, 0.82)
	ataque_visual.modulate.a = 0.25
	tween.tween_property(ataque_visual, "scale:y", 1.16, 0.10)
	tween.tween_property(ataque_visual, "modulate:a", 1.0, 0.08)
	tween.chain().tween_property(ataque_visual, "scale:y", 1.0, 0.12)

func morrer() -> void:
	if morto:
		return

	vida -= 1

	if vida <= 0:
		morto = true
		iniciar_morte_final()
		return

	var tween: Tween = create_tween()
	tween.tween_property(animacao, "modulate", Color(1.0, 0.35, 0.35), 0.05)
	tween.tween_property(animacao, "modulate", Color.WHITE, 0.1)

func iniciar_morte_final() -> void:
	atacando = false
	ataque_lancado = false
	tempo_ataque.stop()
	area_ataque.monitoring = false
	area_ataque.monitorable = false
	ataque_visual.visible = false
	velocity = Vector2.ZERO
	collision_layer = 0
	collision_mask = 0
	if colisao:
		colisao.set_deferred("disabled", true)

	animacao.stop()
	mostrar_explosao_final()

	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(animacao, "modulate", Color(1.0, 0.55, 0.95, 0.0), 0.55)
	tween.tween_property(animacao, "scale", animacao.scale * 1.45, 0.18)
	tween.chain().tween_property(animacao, "scale", animacao.scale * 0.08, 0.34)
	await tween.finished

	var erro := get_tree().change_scene_to_file(cena_vitoria)
	if erro != OK:
		push_error("Erro ao carregar a cena de vitoria: " + str(erro))

func mostrar_explosao_final() -> void:
	explosao_visual.visible = true
	explosao_visual.modulate = Color(1.0, 1.0, 1.0, 1.0)
	explosao_visual.scale = Vector2(0.25, 0.25)
	explosao_visual.rotation = 0.0

	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(explosao_visual, "scale", Vector2(2.6, 2.6), 0.42).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(explosao_visual, "rotation", deg_to_rad(110.0), 0.42)
	tween.tween_property(explosao_visual, "modulate:a", 0.0, 0.55).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

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
	if jogador_avistado and is_instance_valid(jogador) and global_position.distance_to(obter_posicao_alvo_jogador()) <= distancia_ataque:
		atacar()
