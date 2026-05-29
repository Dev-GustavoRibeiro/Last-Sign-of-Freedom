extends CharacterBody2D
var bullet_path=preload("res://src/objects/bullets/bullets.tscn")

func _physics_process(delta: float) -> void:
	look_at(get_global_mouse_position())
	if Input.is_action_just_pressed("click"):
		fire()

func fire():
	var bullet=bullet_path.instantiate()
	bullet.dir=rotation
	bullet.pos=$Node2D.global_position
	get_parent().add_child(bullet)
