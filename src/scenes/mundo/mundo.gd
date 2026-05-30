extends Node2D

@onready var area2d: StaticBody2D = $Area2D
@onready var collision_shape: CollisionShape2D = $Area2D/CollisionShape2D
@onready var personagem: CharacterBody2D = $personagem

# Preload esqueleto scene to spawn more enemies
const ESQUELETO_SCENE = preload("res://src/entities/enemy/esqueleto.tscn")
const MOEDA_SCENE = preload("res://src/objects/collectibles/moeda.tscn")

func _ready() -> void:
	# 1. Dynamically expand the ground collision shape to 4200 width
	if collision_shape and collision_shape.shape is RectangleShape2D:
		var rect_shape = collision_shape.shape as RectangleShape2D
		rect_shape.size = Vector2(4200, 50)
		collision_shape.position = Vector2(2000, 422)

	# 2. Adjust player camera limits to lock viewport vertically and eliminate empty bars
	if personagem:
		var camera = personagem.get_node_or_null("camera_personagem")
		if camera and camera is Camera2D:
			camera.limit_left = 0
			camera.limit_top = -105
			camera.limit_right = 4000
			camera.limit_bottom = 435

	# 3. Dynamic Visual Theme Shift for Level 2
	if name == "fase2":
		# Modulate backgrounds to a hot glowing Cyberpunk Magenta/Pink sector!
		var bg_nodes = [
			$backgound/textura,
			$Parallax2D/Sprite2D,
			$Parallax2D2/Sprite2D,
			$Parallax2D3/Sprite2D
		]
		for node in bg_nodes:
			if is_instance_valid(node):
				node.modulate = Color(1.2, 0.4, 0.8) # Hot neon cyberpunk pink tint!

	# 4. Dynamically spawn floating platforms, covers, coins, and enemies in the extended area
	_spawn_obstacles()

func _spawn_obstacles() -> void:
	var is_fase2 = (name == "fase2")
	
	# Define platforms in the extended region: (position, size)
	var platforms = []
	if is_fase2:
		# Fase 2 is a harder layout with challenging and tighter platforms
		platforms = [
			{"pos": Vector2(1900, 290), "size": Vector2(120, 20)},
			{"pos": Vector2(2100, 210), "size": Vector2(100, 20)},
			{"pos": Vector2(2300, 140), "size": Vector2(120, 20)},
			{"pos": Vector2(2500, 250), "size": Vector2(80, 20)},
			{"pos": Vector2(2700, 180), "size": Vector2(140, 20)},
			{"pos": Vector2(2950, 270), "size": Vector2(100, 20)},
			{"pos": Vector2(3150, 190), "size": Vector2(120, 20)},
			{"pos": Vector2(3350, 270), "size": Vector2(80, 20)},
			{"pos": Vector2(3550, 200), "size": Vector2(150, 20)},
		]
	else:
		# Fase 1 layout
		platforms = [
			{"pos": Vector2(1950, 270), "size": Vector2(160, 20)},
			{"pos": Vector2(2200, 200), "size": Vector2(160, 20)},
			{"pos": Vector2(2450, 270), "size": Vector2(160, 20)},
			{"pos": Vector2(2750, 180), "size": Vector2(200, 20)},
			{"pos": Vector2(3050, 260), "size": Vector2(160, 20)},
			{"pos": Vector2(3300, 190), "size": Vector2(180, 20)},
			{"pos": Vector2(3550, 270), "size": Vector2(160, 20)},
		]

	# Platform visual style
	var border_color = Color(1.0, 0.1, 0.6, 1.0) if is_fase2 else Color(0.0, 0.9, 1.0, 1.0)
	var bottom_color = Color(0.8, 0.0, 0.5, 0.8) if is_fase2 else Color(0.0, 0.4, 0.8, 0.8)

	for plat in platforms:
		var static_body = StaticBody2D.new()
		static_body.position = plat["pos"]
		
		# Collision Shape
		var col = CollisionShape2D.new()
		var shape = RectangleShape2D.new()
		shape.size = plat["size"]
		col.shape = shape
		static_body.add_child(col)
		
		# Cyberpunk neon floating metal platform
		var visual = ColorRect.new()
		visual.size = plat["size"]
		visual.position = -plat["size"] / 2.0
		visual.color = Color(0.05, 0.08, 0.12, 0.95) if is_fase2 else Color(0.05, 0.1, 0.15, 0.95)
		static_body.add_child(visual)

		# Glowing top edge
		var border = ColorRect.new()
		border.size = Vector2(plat["size"].x, 3)
		border.position = Vector2(-plat["size"].x / 2.0, -plat["size"].y / 2.0)
		border.color = border_color
		static_body.add_child(border)

		# Glowing bottom edge
		var bottom_border = ColorRect.new()
		bottom_border.size = Vector2(plat["size"].x, 2)
		bottom_border.position = Vector2(-plat["size"].x / 2.0, plat["size"].y / 2.0 - 2)
		bottom_border.color = bottom_color
		static_body.add_child(bottom_border)

		add_child(static_body)

		# Spawn a coin on top
		if randf() > 0.3:
			var coin = MOEDA_SCENE.instantiate()
			coin.position = plat["pos"] + Vector2(0, -40)
			add_child.call_deferred(coin)

	# 5. Spawn intermediate patrol enemies (capangas)
	var enemy_positions = []
	if is_fase2:
		enemy_positions = [
			Vector2(1900, 230),
			Vector2(2100, 350),
			Vector2(2300, 80),
			Vector2(2500, 190),
			Vector2(2700, 350),
			Vector2(2950, 210),
			Vector2(3150, 130),
			Vector2(3350, 350),
			Vector2(3550, 140),
			Vector2(3700, 350),
		]
	else:
		enemy_positions = [
			Vector2(2000, 350),
			Vector2(2200, 150),
			Vector2(2450, 350),
			Vector2(2750, 120),
			Vector2(2900, 350),
			Vector2(3050, 200),
			Vector2(3400, 350),
			Vector2(3550, 210),
		]

	for i in range(enemy_positions.size()):
		var enemy = ESQUELETO_SCENE.instantiate()
		enemy.name = "esqueleto_dinamico_" + str(i)
		enemy.position = enemy_positions[i]
		add_child.call_deferred(enemy)
