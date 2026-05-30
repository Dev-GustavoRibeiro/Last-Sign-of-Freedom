extends CharacterBody2D

@onready var animacao_personagem: AnimatedSprite2D = $animacao_personagem

@onready var municao_label = $"../CanvasLayer/MunicaoLabel"
@export var bala_scene : PackedScene
@onready var marker_right = $MarkerRight
@onready var marker_left = $MarkerLeft
@onready var tempo_label = $"../CanvasLayer/TempoLabel"

const SPEED = 130.0
const JUMP_VELOCITY = -370.0

var tempo = 0.0
var atirando = false
var municao_maxima = 12
var municao_atual = 12
var shake_intensity = 0.0
var shake_decay = 7.0

# Dodge Dash variables
var dashing = false
var dash_speed = 450.0
var dash_duration = 0.2
var dash_cooldown = 0.8
var dash_timer = 0.0
var dash_cooldown_timer = 0.0
var dash_direction = 1.0

func _physics_process(delta: float) -> void:
	tempo += delta
	var minutos = int(tempo / 60)
	var segundos = int(tempo) % 60

	tempo_label.text = "%02d:%02d" % [minutos, segundos]

	# Process camera shake
	if shake_intensity > 0:
		$camera_personagem.offset = Vector2(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity)
		)
		shake_intensity = move_toward(shake_intensity, 0.0, shake_decay * delta)
	else:
		$camera_personagem.offset = Vector2.ZERO

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
			dash_direction = 1.0 if animacao_personagem.flip_h else -1.0
			
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

			# Virar personagem (only flip if not currently shooting/aiming at enemies)
			if not atirando:
				if direction > 0:
					animacao_personagem.flip_h = true
				else:
					animacao_personagem.flip_h = false
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	# Tiro
	if Input.is_action_just_pressed("shoot") and not atirando and municao_atual > 0:
		atirar()

	# Animações
	if not atirando:
		if not is_on_floor():
			animacao_personagem.play("jump")
		elif velocity.x != 0:
			animacao_personagem.play("run")
		else:
			animacao_personagem.play("idle")

	move_and_slide()

func adicionar_municao(valor):

	municao_atual += valor

	if municao_atual > municao_maxima:
		municao_atual = municao_maxima

	atualizar_municao()
	
func atualizar_municao():

	municao_label.text = str(municao_atual) + "/" + str(municao_maxima)

func _ready():
	add_to_group("player")
	atualizar_municao()
	setup_aura()
	
func atirar():
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
		animacao_personagem.flip_h = (nearest_enemy.global_position.x > global_position.x)

	atirando = true
	municao_atual -= 1
	atualizar_municao()
	shake_intensity = 3.0

	animacao_personagem.play("shoot")
	animacao_personagem.frame = 0

	var bala = bala_scene.instantiate()
	get_parent().add_child(bala)

	# Adjust bullet position and orientation based on finalized player flip
	if animacao_personagem.flip_h:
		bala.global_position = marker_right.global_position
		bala.direction = 1
	else:
		bala.global_position = marker_left.global_position
		bala.direction = -1

	await animacao_personagem.animation_finished
	atirando = false

func receber_dano():
	if dashing:
		return # Invulnerable to damage during dash!

	# Violent screen shake and HDR hitstop flash
	shake_intensity = 15.0
	self.modulate = Color(8.0, 0.1, 0.1) # Glowing HDR red
	set_physics_process(false)
	await get_tree().create_timer(0.4).timeout
	get_tree().change_scene_to_file("res://src/ui/menus/game_over.tscn")

func setup_aura():
	var aura = CPUParticles2D.new()
	aura.name = "PlayerAura"
	aura.amount = 8
	aura.lifetime = 1.0
	aura.preprocess = 1.0
	aura.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	aura.emission_sphere_radius = 20.0
	aura.gravity = Vector2(0, -25)
	aura.direction = Vector2(0, -1)
	aura.spread = 30.0
	aura.initial_velocity_min = 5.0
	aura.initial_velocity_max = 12.0
	aura.color = Color(0.4, 0.9, 1.0, 0.25) # Neon cyan glowing aura
	aura.scale_amount_min = 5.0
	aura.scale_amount_max = 10.0
	add_child(aura)
	move_child(aura, 0)

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
