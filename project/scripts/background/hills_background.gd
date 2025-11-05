extends Node2D

@export var far_color: Color = Color(0.647, 0.839, 0.607)
@export var near_color: Color = Color(0.439, 0.733, 0.439)
@export var far_height_ratio: float = 0.55
@export var near_height_ratio: float = 0.7
@export var far_amplitude: float = 90.0
@export var near_amplitude: float = 120.0
@export var hill_sections: int = 6

var _size: Vector2 = Vector2(1920, 1080)

func _ready() -> void:
    set_process(true)
    _update_from_viewport()

func _process(_delta: float) -> void:
    _update_from_viewport()

func _update_from_viewport() -> void:
    var viewport_size := get_viewport_rect().size
    if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
        return
    if viewport_size == _size:
        return
    _size = viewport_size
    position = -_size * 0.5
    queue_redraw()

func _draw() -> void:
    _draw_hill(far_color, far_height_ratio, far_amplitude, 0.3)
    _draw_hill(near_color, near_height_ratio, near_amplitude, 1.2)

func _draw_hill(color: Color, height_ratio: float, amplitude: float, phase_offset: float) -> void:
    var points := PackedVector2Array()
    var width := _size.x
    var base_y := _size.y * height_ratio
    points.append(Vector2(0, _size.y))
    var steps := max(2, hill_sections)
    for i in range(steps + 1):
        var t := float(i) / float(steps)
        var x := width * t
        var y := base_y - sin(t * PI * 1.5 + phase_offset) * amplitude
        points.append(Vector2(x, y))
    points.append(Vector2(width, _size.y))
    draw_colored_polygon(points, color)
