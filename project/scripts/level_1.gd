extends Node2D

const TILE_SIZE: Vector2i = Vector2i(64, 64)
const TILE_SOURCE_ID := 0
const TILE_TOP := Vector2i(0, 0)
const TILE_FILL := Vector2i(1, 0)
const GROUND_START_X := -8
const GROUND_END_X := 52
const GROUND_HEIGHT := 6
const GROUND_DEPTH := 6

@onready var _tile_map: TileMap = $TileMap
@onready var _ground_body: StaticBody2D = $Environment/GroundBody
@onready var _ground_collision: CollisionShape2D = $Environment/GroundBody/GroundCollision
@onready var _platform_container: Node2D = $Environment/Platforms

func _ready() -> void:
    _configure_tilemap()
    _build_world()
    _configure_ground_collision()
    _create_platforms()

func _configure_tilemap() -> void:
    var tile_set := _build_tileset()
    _tile_map.tile_set = tile_set
    _tile_map.rendering_quadrant_size = 16

func _build_tileset() -> TileSet:
    var tile_set := TileSet.new()
    tile_set.tile_size = TILE_SIZE
    var atlas := TileSetAtlasSource.new()
    atlas.texture = _create_tiles_texture()
    atlas.texture_region_size = TILE_SIZE
    atlas.use_texture_padding = false
    atlas.create_tile(TILE_TOP)
    atlas.create_tile(TILE_FILL)
    tile_set.add_source(TILE_SOURCE_ID, atlas)
    return tile_set

func _create_tiles_texture() -> Texture2D:
    var width := TILE_SIZE.x * 2
    var height := TILE_SIZE.y
    var image := Image.create(width, height, false, Image.FORMAT_RGBA8)
    image.lock()
    for x in range(width):
        for y in range(height):
            var color: Color
            if x < TILE_SIZE.x:
                color = _grass_tile_color(x, y)
            else:
                color = _dirt_tile_color(x - TILE_SIZE.x, y)
            image.set_pixel(x, y, color)
    image.unlock()
    return ImageTexture.create_from_image(image)

func _grass_tile_color(x: int, y: int) -> Color:
    var normalized_y := float(y) / float(TILE_SIZE.y - 1)
    if normalized_y < 0.22:
        var t := normalized_y / 0.22
        return Color(0.38, 0.67, 0.21).lerp(Color(0.62, 0.82, 0.31), t)
    return Color(0.45, 0.29, 0.16).lerp(Color(0.33, 0.2, 0.11), normalized_y)

func _dirt_tile_color(x: int, y: int) -> Color:
    var normalized_y := float(y) / float(TILE_SIZE.y - 1)
    var base := Color(0.37, 0.23, 0.12).lerp(Color(0.26, 0.16, 0.09), normalized_y)
    if int(normalized_y * 8.0 + float(x) * 0.1) % 2 == 0:
        base = base.darkened(0.08)
    return base

func _build_world() -> void:
    _tile_map.clear()
    for x in range(GROUND_START_X, GROUND_END_X):
        _tile_map.set_cell(0, Vector2i(x, GROUND_HEIGHT), TILE_SOURCE_ID, TILE_TOP)
        for y in range(1, GROUND_DEPTH + 1):
            _tile_map.set_cell(0, Vector2i(x, GROUND_HEIGHT + y), TILE_SOURCE_ID, TILE_FILL)

func _configure_ground_collision() -> void:
    var tile_count := GROUND_END_X - GROUND_START_X
    var width := float(tile_count) * TILE_SIZE.x
    var left_edge := float(GROUND_START_X) * TILE_SIZE.x
    var right_edge := float(GROUND_END_X) * TILE_SIZE.x
    var center_x := (left_edge + right_edge) * 0.5
    var center_y := float(GROUND_HEIGHT) * TILE_SIZE.y + TILE_SIZE.y * 0.5
    _ground_body.position = Vector2(center_x, center_y)
    var shape := RectangleShape2D.new()
    shape.size = Vector2(width, TILE_SIZE.y)
    _ground_collision.shape = shape
    _ground_collision.position = Vector2.ZERO

func _create_platforms() -> void:
    for child in _platform_container.get_children():
        child.queue_free()
    _add_platform(Vector2i(6, GROUND_HEIGHT - 2), 4)
    _add_platform(Vector2i(16, GROUND_HEIGHT - 3), 5)
    _add_platform(Vector2i(28, GROUND_HEIGHT - 4), 3)
    _add_platform(Vector2i(38, GROUND_HEIGHT - 2), 6)

func _add_platform(origin: Vector2i, length: int) -> void:
    for i in range(length):
        _tile_map.set_cell(0, Vector2i(origin.x + i, origin.y), TILE_SOURCE_ID, TILE_TOP)
    var left_edge := float(origin.x) * TILE_SIZE.x
    var right_edge := float(origin.x + length) * TILE_SIZE.x
    var center_x := (left_edge + right_edge) * 0.5
    var center_y := float(origin.y) * TILE_SIZE.y + TILE_SIZE.y * 0.5
    var body := StaticBody2D.new()
    body.position = Vector2(center_x, center_y)
    var shape := RectangleShape2D.new()
    shape.size = Vector2((right_edge - left_edge), TILE_SIZE.y)
    var collision := CollisionShape2D.new()
    collision.shape = shape
    body.add_child(collision)
    _platform_container.add_child(body)
