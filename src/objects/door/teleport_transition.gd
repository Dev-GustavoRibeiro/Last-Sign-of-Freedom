extends CanvasLayer

const SPARKLE_TEXTURE := preload("res://assets/Bullet/Yellow_Sparkle (16 x 16).png")

var _painel: ColorRect

func start(body: Node2D, next_scene_path: String) -> void:
	layer = 128
	name = "TransicaoTeleport"
	process_mode = Node.PROCESS_MODE_ALWAYS

	_painel = ColorRect.new()
	_painel.name = "Painel"
	_painel.color = Color.BLACK
	_painel.anchor_right = 1.0
	_painel.anchor_bottom = 1.0
	_painel.pivot_offset = get_viewport().get_visible_rect().size * 0.5
	_painel.modulate.a = 0.0
	add_child(_painel)

	await _animar_saida(body)
	await _fechar_tela()

	var erro := get_tree().change_scene_to_file(next_scene_path)
	if erro != OK:
		push_error("Erro ao carregar a proxima cena: " + str(erro))
		queue_free()
		return

	await get_tree().process_frame
	await _abrir_tela()
	queue_free()

func _animar_saida(body: Node2D) -> void:
	if not is_instance_valid(body):
		return

	body.set_physics_process(false)
	body.process_mode = Node.PROCESS_MODE_DISABLED

	var brilho := _criar_brilho(body.global_position)
	var original_modulate := body.modulate
	var original_scale := body.scale

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(body, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.12)
	tween.tween_property(body, "scale", original_scale * 1.25, 0.12)
	tween.tween_property(brilho, "scale", Vector2(2.0, 2.0), 0.12)
	tween.chain().set_parallel(true)
	tween.tween_property(body, "modulate:a", 0.0, 0.32)
	tween.tween_property(body, "scale", original_scale * 0.12, 0.32)
	tween.tween_property(body, "rotation", body.rotation + TAU, 0.32)
	tween.tween_property(brilho, "rotation", TAU * 2.0, 0.32)
	tween.tween_property(brilho, "modulate:a", 0.0, 0.32)
	await tween.finished

	if is_instance_valid(body):
		body.modulate = original_modulate
	if is_instance_valid(brilho):
		brilho.queue_free()

func _criar_brilho(posicao: Vector2) -> Sprite2D:
	var brilho := Sprite2D.new()
	brilho.texture = SPARKLE_TEXTURE
	brilho.region_enabled = true
	brilho.region_rect = Rect2(0, 0, 16, 16)
	brilho.centered = true
	brilho.global_position = posicao
	brilho.scale = Vector2(1.2, 1.2)
	brilho.z_index = 100
	get_tree().current_scene.add_child(brilho)
	return brilho

func _fechar_tela() -> void:
	_painel.pivot_offset = get_viewport().get_visible_rect().size * 0.5
	_painel.scale = Vector2.ONE
	_painel.modulate.a = 0.0

	var tween := create_tween()
	tween.tween_property(_painel, "modulate:a", 1.0, 0.24).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await tween.finished

func _abrir_tela() -> void:
	_painel.pivot_offset = get_viewport().get_visible_rect().size * 0.5
	_painel.scale = Vector2.ONE
	_painel.modulate.a = 1.0

	var tween := create_tween()
	tween.tween_property(_painel, "modulate:a", 0.0, 0.28).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await tween.finished
