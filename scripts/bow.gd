extends Node
class_name Bow

@export var sprite: Sprite2D
@export var default_frame: int
@export var active_frame: int

func set_default_frame():
  sprite.frame = default_frame

func set_active_frame():
  sprite.frame = active_frame
