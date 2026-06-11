extends Node

const CENA_FASE_1 := "res://src/scenes/mundo/mundo.tscn"

var moedas = 0
var checkpoint_scene_path := CENA_FASE_1
var checkpoint_position := Vector2.ZERO
var checkpoint_tem_posicao := false

func definir_checkpoint(cena: String, posicao := Vector2.ZERO, usar_posicao := false) -> void:
	checkpoint_scene_path = cena
	checkpoint_position = posicao
	checkpoint_tem_posicao = usar_posicao

func resetar_checkpoint() -> void:
	definir_checkpoint(CENA_FASE_1)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
