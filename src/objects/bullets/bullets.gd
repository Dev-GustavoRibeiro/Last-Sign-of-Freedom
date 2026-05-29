extends Area2D

var pos: Vector2
var rota: float
var dir: float
var speed = 2000

func _ready():
	global_position = pos
	global_rotation = rota

func _physics_process(delta: float) -> void:
	global_position += Vector2.RIGHT.rotated(dir) * speed * delta


func _on_body_entered(body):
	if body.is_in_group("inimigo"):
		body.morrer()
		queue_free()
