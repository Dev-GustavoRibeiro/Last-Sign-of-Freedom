extends Button

@export var hover_alpha := 0.16
@export var press_alpha := 0.28
@export var hover_scale := Vector2(1.012, 1.012)
@export var press_scale := Vector2(0.988, 0.988)

var _overlay: ColorRect
var _tween: Tween

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	focus_mode = Control.FOCUS_NONE
	clip_contents = true

	_overlay = ColorRect.new()
	_overlay.color = Color(0.75, 1.0, 1.0, 1.0)
	_overlay.modulate.a = 0.0
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_overlay)
	move_child(_overlay, 0)

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)
	resized.connect(_atualizar_pivo)
	call_deferred("_atualizar_pivo")

func _atualizar_pivo() -> void:
	pivot_offset = size * 0.5

func _on_mouse_entered() -> void:
	_animar(hover_scale, hover_alpha, 0.12)

func _on_mouse_exited() -> void:
	_animar(Vector2.ONE, 0.0, 0.14)

func _on_button_down() -> void:
	_animar(press_scale, press_alpha, 0.07)

func _on_button_up() -> void:
	var alvo_alpha := hover_alpha if is_hovered() else 0.0
	var alvo_scale := hover_scale if is_hovered() else Vector2.ONE
	_animar(alvo_scale, alvo_alpha, 0.10)

func _animar(alvo_scale: Vector2, alvo_alpha: float, duracao: float) -> void:
	if _tween:
		_tween.kill()

	_tween = create_tween()
	_tween.set_parallel(true)
	_tween.tween_property(self, "scale", alvo_scale, duracao).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween.tween_property(_overlay, "modulate:a", alvo_alpha, duracao).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
