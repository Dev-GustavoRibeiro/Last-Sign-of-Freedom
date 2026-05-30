extends Area2D

@onready var ammo_animation: AnimatedSprite2D = $"animacao-municao"

var amount = 1

func _on_body_entered(body: Node2D) -> void:

	if body.name == "player":

		body.add_ammo(amount)

		ammo_animation.play("captura")


func _on_ammo_animation_finished() -> void:

	queue_free()
