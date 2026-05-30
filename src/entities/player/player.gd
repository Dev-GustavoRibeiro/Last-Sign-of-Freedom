extends CharacterBody2D

@onready var player_animation: AnimatedSprite2D = $player_animation

@onready var ammo_label = $"../CanvasLayer/MunicaoLabel"
@export var bullet_scene : PackedScene
@onready var marker_right = $MarkerRight
@onready var marker_left = $MarkerLeft
@onready var time_label = $"../CanvasLayer/TempoLabel"

const SPEED = 130.0
const JUMP_VELOCITY = -370.0

var time = 0.0
var shooting = false
var max_ammo = 12
var current_ammo = 12
var shake_intensity = 0.0
var shake_decay = 7.0

# Cyberpunk Health System
var max_health = 5
var current_health = 5
var invulnerable = false
var player_health_bar: ProgressBar

# Dodge Dash variables
var dashing = false
var dash_speed = 450.0
var dash_duration = 0.2
var dash_cooldown = 0.8
var dash_timer = 0.0
var dash_cooldown_timer = 0.0
var dash_direction = 1.0

func _physics_process(delta: float) -> void:
	time += delta
	var minutes = int(time / 60)
	var seconds = int(time) % 60

	time_label.text = "%02d:%02d" % [minutes, seconds]

	# Process camera shake
	if shake_intensity > 0:
		$player_camera.offset = Vector2(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity)
		)
		shake_intensity = move_toward(shake_intensity, 0.0, shake_decay * delta)
	else:
		$player_camera.offset = Vector2.ZERO

	# Update dash cooldown timer
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta

	# Check dash trigger: holding Shift key!
	if Input.is_key_pressed(KEY_SHIFT) and not dashing and dash_cooldown_timer <= 0:
		dashing = true
		dash_timer = dash_duration
		dash_cooldown_timer = dash_cooldown
		
		# Premium Combat Dash: dash in input direction if moving, otherwise face direction
		var walk_dir = Input.get_axis("Left", "Right")
		if walk_dir != 0:
			dash_direction = walk_dir
		else:
			dash_direction = 1.0 if player_animation.flip_h else -1.0
			
		spawn_dash_trail()

	# Apply dash physics or standard movement
	if dashing:
		velocity.x = dash_direction * dash_speed
		velocity.y = 0  # Ignore gravity during dash
		dash_timer -= delta
		if dash_timer <= 0:
			dashing = false
	else:
		# Gravidade
		if not is_on_floor():
			velocity += get_gravity() * delta

		# Pulo
		if Input.is_action_just_pressed("Jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		# Movimento
		var direction := Input.get_axis("Left", "Right")

		if direction:
			velocity.x = direction * SPEED

			# Virar player (only flip if not currently shooting/aiming at enemies)
			if not shooting:
				if direction > 0:
					player_animation.flip_h = true
				else:
					player_animation.flip_h = false
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	# Tiro
	if Input.is_action_just_pressed("shoot") and not shooting and current_ammo > 0:
		shoot()

	# Animações
	if not shooting:
		if not is_on_floor():
			player_animation.play("jump")
		elif velocity.x != 0:
			player_animation.play("run")
		else:
			player_animation.play("idle")

	move_and_slide()

func add_ammo(valor):

	current_ammo += valor

	if current_ammo > max_ammo:
		current_ammo = max_ammo

	update_ammo()
	
func update_ammo():

	ammo_label.text = str(current_ammo) + "/" + str(max_ammo)

func _ready():
	add_to_group("player")
	update_ammo()
	setup_health_bar()
	
func setup_health_bar():
	var canvas = get_parent().get_node_or_null("CanvasLayer")
	if canvas:
		player_health_bar = ProgressBar.new()
		player_health_bar.show_percentage = false
		player_health_bar.size = Vector2(250, 16)
		player_health_bar.position = Vector2(1640, 35) # Shifted to top-right to avoid top-left labels
		
		# Custom premium styling for Cyberpunk Health Bar
		var sb_bg = StyleBoxFlat.new()
		sb_bg.bg_color = Color(0.08, 0.08, 0.1, 0.8)
		sb_bg.set_border_width_all(2)
		sb_bg.border_color = Color(0.0, 0.5, 0.8, 0.8)
		sb_bg.set_corner_radius_all(4)
		player_health_bar.add_theme_stylebox_override("background", sb_bg)
		
		var sb_fill = StyleBoxFlat.new()
		sb_fill.bg_color = Color(0.0, 0.9, 0.6) # Cyberpunk emerald neon green
		sb_fill.set_corner_radius_all(3)
		player_health_bar.add_theme_stylebox_override("fill", sb_fill)
		
		player_health_bar.max_value = max_health
		player_health_bar.value = current_health
		canvas.add_child(player_health_bar)
		
		# Add a beautiful Label "HP" above or next to the bar
		var hp_label = Label.new()
		hp_label.text = "SYSTEM HP"
		hp_label.position = Vector2(1640, 10)
		hp_label.add_theme_color_override("font_color", Color(0.0, 0.9, 1.0))
		canvas.add_child(hp_label)

func shoot():
	# Caiting (Kiting) auto-aim: face the nearest enemy within 400px before firing
	var nearest_enemy = null
	var min_dist = 400.0
	var enemy_groups = ["inimigos", "inimigo"]
	for grp in enemy_groups:
		for enemy in get_tree().get_nodes_in_group(grp):
			if is_instance_valid(enemy):
				var dist = global_position.distance_to(enemy.global_position)
				if dist < min_dist:
					min_dist = dist
					nearest_enemy = enemy

	if nearest_enemy != null:
		# Auto-face the target
		player_animation.flip_h = (nearest_enemy.global_position.x > global_position.x)

	shooting = true
	current_ammo -= 1
	update_ammo()
	shake_intensity = 3.0

	player_animation.play("shoot")
	player_animation.frame = 0

	var bullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)

	# Adjust bullet position and orientation based on finalized player flip
	if player_animation.flip_h:
		bullet.global_position = marker_right.global_position
		bullet.direction = 1
	else:
		bullet.global_position = marker_left.global_position
		bullet.direction = -1

	await player_animation.animation_finished
	shooting = false

func take_damage():
	if dashing or invulnerable:
		return # Invulnerable to damage during dash or recovery!

	current_health -= 1
	if player_health_bar:
		player_health_bar.value = current_health

	# Hitstop screen shake & flash
	shake_intensity = 8.0
	self.modulate = Color(5.0, 0.2, 0.2) # Glowing HDR red flash

	if current_health <= 0:
		# Violent screen shake and HDR hitstop death flash
		shake_intensity = 18.0
		self.modulate = Color(8.0, 0.1, 0.1) # Extreme glowing HDR red
		set_physics_process(false)
		await get_tree().create_timer(0.4).timeout
		get_tree().change_scene_to_file("res://src/ui/menus/game_over.tscn")
	else:
		# Flashing invulnerability recovery phase
		invulnerable = true
		for i in range(6):
			self.modulate = Color(1.0, 1.0, 1.0, 0.2)
			await get_tree().create_timer(0.1).timeout
			self.modulate = Color(1.0, 1.0, 1.0, 1.0)
			await get_tree().create_timer(0.1).timeout
		invulnerable = false



func spawn_dash_trail():
	var particles = CPUParticles2D.new()
	particles.global_position = global_position + Vector2(200, -71)
	particles.emitting = true
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.amount = 25
	particles.lifetime = 0.3
	particles.spread = 45.0
	particles.gravity = Vector2(0, 0)
	particles.initial_velocity_min = 120.0
	particles.initial_velocity_max = 220.0
	particles.direction = Vector2(-dash_direction, 0.2)
	particles.color = Color(0.0, 0.8, 1.0, 0.7) # Glowing cyan trail particles
	particles.scale_amount_min = 2.0
	particles.scale_amount_max = 4.0
	get_tree().current_scene.add_child(particles)

	await get_tree().create_timer(0.35).timeout
	particles.queue_free()
