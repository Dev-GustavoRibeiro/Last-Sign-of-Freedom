extends Control
@onready var label: Label = $margem/colunas/Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.text = str(Global.moedas)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	label.text = str(Global.moedas)
