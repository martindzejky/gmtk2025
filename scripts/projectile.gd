extends Node2D
class_name Projectile

@export var move_speed := 220.0
@export var target_rotation := 0.0
@export var set_target_rotation_to: Node2D

func _process(delta):
  position += Vector2.RIGHT.rotated(target_rotation) * move_speed * delta

  if set_target_rotation_to:
    set_target_rotation_to.rotation = target_rotation
