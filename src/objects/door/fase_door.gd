extends Node2D

const TeleportTransition := preload("res://src/objects/door/teleport_transition.gd")

@export_file("*.tscn") var next_scene_path := ""
@export var next_scene_checkpoint_position := Vector2.ZERO
@export var use_next_scene_checkpoint_position := false
@export var mostrar_placa := true

@onready var animacao: AnimatedSprite2D = $Animacao
@onready var area: Area2D = $Area2D
@onready var placa: Label = $Placa

var aberta := false
var pronta_para_entrar := false
var teleportando := false

func _ready() -> void:
	animacao.play("fechada")
	area.body_entered.connect(_on_body_entered)
	placa.visible = mostrar_placa
	placa.text = "Elimine todos os inimigos"
	verificar_ate_abrir()

func verificar_ate_abrir() -> void:
	while not aberta:
		if _todos_inimigos_derrotados():
			abrir()
			return

		await get_tree().create_timer(0.25).timeout

func abrir() -> void:
	aberta = true
	placa.text = "Porta liberada"
	animacao.play("abrir")
	await animacao.animation_finished
	animacao.play("aberta")
	pronta_para_entrar = true

func _todos_inimigos_derrotados() -> bool:
	var inimigos := {}
	for inimigo in get_tree().get_nodes_in_group("inimigo"):
		inimigos[inimigo] = true
	for inimigo in get_tree().get_nodes_in_group("inimigos"):
		inimigos[inimigo] = true

	for inimigo in inimigos.keys():
		if not is_instance_valid(inimigo):
			continue
		if inimigo.get("morto") == true:
			continue
		return false

	return true

func _on_body_entered(body: Node2D) -> void:
	if not pronta_para_entrar or teleportando or not body.is_in_group("player") or next_scene_path.is_empty():
		return

	teleportando = true
	Global.definir_checkpoint(next_scene_path, next_scene_checkpoint_position, use_next_scene_checkpoint_position)

	var transicao := TeleportTransition.new()
	get_tree().root.add_child(transicao)
	transicao.start(body, next_scene_path)
