extends Node2D

@export var top_color: Color = Color(0.596, 0.835, 0.996)
@export var bottom_color: Color = Color(0.894, 0.964, 1.0)
@export var gradient_steps: int = 32

var _size: Vector2 = Vector2(1920, 1080)

func _ready() -> void:
    set_process(true)
    _update_size_from_viewport()

func _process(_delta: float) -> void:
    _update_size_from_viewport()

func _update_size_from_viewport() -> void:
    var viewport_size := get_viewport_rect().size
    if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
        return
    if viewport_size == _size:
        return
    _size = viewport_size
    position = -_size * 0.5
    queue_redraw()

func _draw() -> void:
    if gradient_steps <= 1:
        draw_rect(Rect2(Vector2.ZERO, _size), bottom_color, true)
        return

    var band_height := _size.y / float(gradient_steps - 1)
    for i in range(gradient_steps):
        var t := float(i) / float(gradient_steps - 1)
        var color := top_color.lerp(bottom_color, t)
        var y := max(0.0, i * band_height - band_height * 0.5)
        draw_rect(Rect2(Vector2(0, y), Vector2(_size.x, band_height + 1.0)), color, true)
