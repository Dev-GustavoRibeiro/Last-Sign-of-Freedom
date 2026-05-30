extends CharacterBody2D

@onready var collision_detector: RayCast2D = $collision_detector
@onready var thug_animation: AnimatedSprite2D = $thug_animation
@onready var shoot_point: Marker2D = $PontoTiro

@export var bullet_scene: PackedScene

var speed = 30.0
var direction := 1

var player: Node2D
var player_detected := false

@export var is_boss: bool = false
@export var health: int = 1
var dead: bool = false

var health_bar: ProgressBar

func _ready():
	player = get_tree().get_first_node_in_group("player")
	thug_animation.play("run")

	var is_fase2 = (get_tree().current_scene.name == "fase2")

	if name == "thug4":
		is_boss = true
		if is_fase2:
			health = 10
			self.modulate = Color(1.0, 0.1, 1.0) # Hot neon magenta
			self.scale = Vector2(2.0, 2.0)
		else:
			health = 6
			self.modulate = Color(1.0, 0.4, 0.4)
			self.scale = Vector2(1.6, 1.6)
	elif is_fase2:
		speed = 55.0

	setup_health_bar()

func setup_health_bar():
	health_bar = ProgressBar.new()
	health_bar.show_percentage = false
	health_bar.size = Vector2(50, 6)
	
	# Position above the thug's head (adjusted based on boss/scale)
	if is_boss:
		health_bar.position = Vector2(-25, -75)
	else:
		health_bar.position = Vector2(-25, -65)
		
	# Custom StyleBox for premium Cyberpunk look
	var sb_bg = StyleBoxFlat.new()
	sb_bg.bg_color = Color(0.05, 0.05, 0.05, 0.8)
	sb_bg.set_border_width_all(1)
	sb_bg.border_color = Color(0.1, 0.1, 0.1, 0.5)
	sb_bg.set_corner_radius_all(2)
	health_bar.add_theme_stylebox_override("background", sb_bg)
	
	var sb_fill = StyleBoxFlat.new()
	if is_boss:
		sb_fill.bg_color = Color(1.0, 0.1, 0.6) # Neon pink/magenta for boss
	else:
		sb_fill.bg_color = Color(1.0, 0.35, 0.0) # Neon orange/red for standard capanga
	sb_fill.set_corner_radius_all(2)
	health_bar.add_theme_stylebox_override("fill", sb_fill)
	
	health_bar.max_value = max(1, health)
	health_bar.value = health
	add_child(health_bar)


func _physics_process(delta: float) -> void:

	if not is_on_floor():
		velocity += get_gravity() * delta

	# Adjust sprite scale based on active animation to prevent shrinking/distortion
	var base_scale = Vector2(0.11191573, 0.08449935)
	if thug_animation.animation == "shoot" or thug_animation.animation == "idle":
		thug_animation.scale = base_scale * Vector2(307.0 / 158.0, 1024.0 / 529.0)
	else:
		thug_animation.scale = base_scale

	if player_detected:

		# Para completamente
		velocity.x = 0

		# Olha para o player
		if player:
			thug_animation.flip_h = player.global_position.x < global_position.x

		# Só toca idle se não estiver shooting ou morrendo
		if thug_animation.animation != "shoot" and thug_animation.animation != "death":
			if thug_animation.animation != "idle":
				thug_animation.play("idle")

	else:

		# Patrulha
		if collision_detector.is_colliding():
			direction *= -1
			collision_detector.scale.x = direction
			thug_animation.flip_h = (direction < 0)

		velocity.x = direction * speed

		if thug_animation.animation != "run":
			thug_animation.play("run")

	move_and_slide()

func shoot():

	if player == null:
		return

	thug_animation.play("shoot")

	var bullet = bullet_scene.instantiate()
	bullet.shooter = self
	bullet.global_position = shoot_point.global_position

	var direction_vec = (player.global_position - shoot_point.global_position).normalized()
	bullet.direction_vec = direction_vec

	get_tree().current_scene.add_child(bullet)

func _on_timer_timeout() -> void:

	if player_detected:
		shoot()

func _on_detection_area_body_entered(body: Node2D) -> void:

	if body.is_in_group("player"):
		player_detected = true

func _on_detection_area_body_exited(body: Node2D) -> void:

	if body.is_in_group("player"):
		player_detected = false

func _on_thug_animation_animation_finished() -> void:

	if thug_animation.animation == "death":
		if is_boss:
			if get_tree().current_scene.name == "level1":
				get_tree().change_scene_to_file("res://src/scenes/world/level2.tscn")
			else:
				get_tree().change_scene_to_file("res://src/ui/menus/victory_menu.tscn")
		else:
			queue_free()

	elif thug_animation.animation == "shoot":

		if player_detected:
			thug_animation.play("idle")
		else:
			thug_animation.play("run")

func die():
	if dead:
		return

	health -= 1
	if health_bar:
		health_bar.value = max(0, health)

	if is_boss and health > 0:
		var original_color = self.modulate
		self.modulate = Color(1.0, 1.0, 1.0)
		await get_tree().create_timer(0.15).timeout
		self.modulate = original_color
		return

	dead = true
	Global.coins += 1
	spawn_death_particles()
	thug_animation.play("death")
	set_physics_process(false)

func spawn_death_particles():
	var particles = CPUParticles2D.new()
	particles.global_position = global_position + Vector2(55, 12)
	particles.emitting = true
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.amount = 35
	particles.lifetime = 0.5
	particles.spread = 360.0
	particles.gravity = Vector2(0, 300)
	particles.initial_velocity_min = 150.0
	particles.initial_velocity_max = 280.0
	particles.color = Color(0.9, 0.1, 0.6) if is_boss else Color(1.0, 0.4, 0.1)
	particles.scale_amount_min = 2.5
	particles.scale_amount_max = 6.0
	get_tree().current_scene.add_child(particles)

	await get_tree().create_timer(0.6).timeout
	particles.queue_free()


