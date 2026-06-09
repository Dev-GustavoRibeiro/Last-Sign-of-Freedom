extends CharacterBody2D

@onready var animacao_personagem: AnimatedSprite2D = $animacao_personagem

@onready var municao_label = $"../CanvasLayer/MunicaoLabel"
@export var bala_scene : PackedScene
@onready var marker_right = $MarkerRight
@onready var marker_left = $MarkerLeft
@onready var tempo_label = $"../CanvasLayer/TempoLabel"
@export var limite_queda_y = 900.0

const SPEED = 130.0
const JUMP_VELOCITY = -370.0

var tempo = 0.0
var atirando = false
var municao_maxima = 12
var municao_atual = 12
var morto = false

func _physics_process(delta: float) -> void:
	if morto:
		return

	tempo += delta
	var minutos = int(tempo / 60)
	var segundos = int(tempo) % 60

	tempo_label.text = "%02d:%02d" % [minutos, segundos]

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

		# Virar personagem
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

		elif direction != 0:
			animacao_personagem.play("run")

		else:
			animacao_personagem.play("idle")

	move_and_slide()

	if global_position.y > limite_queda_y:
		morrer()

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
	
func atirar():
	if morto:
		return

	atirando = true
	municao_atual -= 1
	atualizar_municao()

	animacao_personagem.play("shoot")
	animacao_personagem.frame = 0

	var bala = bala_scene.instantiate()

	get_parent().add_child(bala)

	if animacao_personagem.flip_h:
		bala.global_position = marker_right.global_position
	else:
		bala.global_position = marker_left.global_position

	if animacao_personagem.flip_h:
		bala.direction = 1
	else:
		bala.direction = -1

	await animacao_personagem.animation_finished

	atirando = false

func morrer():
	if morto:
		return

	morto = true
	var erro := get_tree().change_scene_to_file("res://src/ui/menus/game_over.tscn")
	if erro != OK:
		push_error("Erro ao carregar a cena de game over: " + str(erro))
