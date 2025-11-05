extends Control

@onready var _start_button: Button = $MarginContainer/VBoxContainer/StartButton
@onready var _quit_button: Button = $MarginContainer/VBoxContainer/QuitButton

const LEVEL_SCENE: PackedScene = preload("res://scenes/level_1.tscn")

func _ready() -> void:
    _start_button.grab_focus()

func _on_start_button_pressed() -> void:
    get_tree().change_scene_to_packed(LEVEL_SCENE)

func _on_quit_button_pressed() -> void:
    get_tree().quit()
