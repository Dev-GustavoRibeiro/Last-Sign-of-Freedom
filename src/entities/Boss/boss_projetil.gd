extends Area2D

@export var velocidade := 230.0

@onready var brilho: Polygon2D = $Brilho
@onready var nucleo: Polygon2D = $Nucleo
@onready var anel: Line2D = $Anel
@onready var rastro: Line2D = $Rastro

var direcao := Vector2.RIGHT
var dono: Node
var tempo_voo := 0.0

func _ready() -> void:
	if direcao == Vector2.ZERO:
		direcao = Vector2.RIGHT

	direcao = direcao.normalized()
	rotation = direcao.angle()
	collision_mask = 4

func _physics_process(delta: float) -> void:
	tempo_voo += delta
	global_position += direcao * velocidade * delta
	var pulso := 1.0 + sin(tempo_voo * 18.0) * 0.08
	brilho.scale = Vector2.ONE * pulso
	nucleo.scale = Vector2.ONE * (1.0 + sin(tempo_voo * 26.0) * 0.05)
	anel.width = 2.0 + (sin(tempo_voo * 20.0) + 1.0) * 0.9
	rastro.width = 3.5 + (sin(tempo_voo * 14.0) + 1.0) * 0.8

func _on_body_entered(body: Node2D) -> void:
	if body == dono:
		return

	if not body.is_in_group("player"):
		return

	if body.has_method("morrer"):
		body.morrer()
	else:
		var erro := get_tree().change_scene_to_file("res://src/ui/menus/game_over.tscn")
		if erro != OK:
			push_error("Erro ao carregar a cena de game over: " + str(erro))

	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
