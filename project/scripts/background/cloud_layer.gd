extends Node2D

@export var cloud_color: Color = Color(1, 1, 1, 0.85)
@export var cloud_count: int = 6
@export var min_cloud_size: Vector2 = Vector2(120, 60)
@export var max_cloud_size: Vector2 = Vector2(220, 100)
@export var min_speed: float = 12.0
@export var max_speed: float = 28.0
@export var vertical_range: Vector2 = Vector2(0.15, 0.45)

var _size: Vector2 = Vector2(1920, 1080)
var _clouds: Array = []
var _rng := RandomNumberGenerator.new()

func _ready() -> void:
    _rng.randomize()
    set_process(true)
    _update_from_viewport(true)
    _create_clouds()

func _process(delta: float) -> void:
    if _update_from_viewport():
        _create_clouds()
    for cloud in _clouds:
        var pos: Vector2 = cloud["position"]
        pos.x += cloud["speed"] * delta
        if pos.x - cloud["size"].x * 0.5 > _size.x:
            pos.x = -cloud["size"].x * 0.5
        cloud["position"] = pos
        cloud["phase"] += delta * 0.25
    queue_redraw()

func _update_from_viewport(force: bool = false) -> bool:
    var viewport_size := get_viewport_rect().size
    if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
        return false
    if not force and viewport_size == _size:
        return false
    _size = viewport_size
    position = -_size * 0.5
    return true

func _create_clouds() -> void:
    _clouds.clear()
    for i in range(max(1, cloud_count)):
        var size := Vector2(
            _rng.randf_range(min_cloud_size.x, max_cloud_size.x),
            _rng.randf_range(min_cloud_size.y, max_cloud_size.y)
        )
        var pos := Vector2(
            _rng.randf_range(0.0, _size.x),
            _rng.randf_range(_size.y * vertical_range.x, _size.y * vertical_range.y)
        )
        var speed := _rng.randf_range(min_speed, max_speed)
        var phase := _rng.randf_range(0.0, PI * 2.0)
        _clouds.append({
            "position": pos,
            "size": size,
            "speed": speed,
            "phase": phase
        })

func _draw() -> void:
    for cloud in _clouds:
        _draw_cloud(cloud)

func _draw_cloud(cloud: Dictionary) -> void:
    var pos: Vector2 = cloud["position"]
    var size: Vector2 = cloud["size"]
    var wobble := sin(cloud["phase"]) * 4.0
    var base_rect := Rect2(pos - Vector2(size.x * 0.5, size.y * 0.25 + wobble), Vector2(size.x, size.y * 0.5))
    draw_rect(base_rect, cloud_color, true)

    var radius_main := size.y * 0.35
    var radius_side := size.y * 0.28
    var radius_small := size.y * 0.22
    draw_circle(pos + Vector2(-size.x * 0.2, -radius_main * 0.1 + wobble), radius_main, cloud_color)
    draw_circle(pos + Vector2(size.x * 0.05, -radius_main * 0.35 + wobble), radius_side, cloud_color)
    draw_circle(pos + Vector2(size.x * 0.25, -radius_main * 0.05 + wobble), radius_small, cloud_color)
    draw_circle(pos + Vector2(-size.x * 0.35, -radius_main * 0.25 + wobble), radius_small, cloud_color)
