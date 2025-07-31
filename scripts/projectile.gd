extends Node2D
class_name Projectile

@export var move_speed := 220.0

func _process(delta):
  position += Vector2.RIGHT.rotated(rotation) * move_speed * delta
