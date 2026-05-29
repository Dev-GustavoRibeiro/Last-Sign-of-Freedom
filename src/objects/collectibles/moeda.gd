extends Area2D

@onready var animacao_municao: AnimatedSprite2D = $"animacao-municao"

var quantidade = 1

func _on_body_entered(body: Node2D) -> void:

	if body.name == "personagem":

		body.adicionar_municao(quantidade)

		animacao_municao.play("captura")


func _on_animacaomunicao_animation_finished() -> void:

	queue_free()
