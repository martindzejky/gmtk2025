extends Node2D
class_name Projectile

@export var move_speed := 220.0
@export var target_rotation := 0.0
@export var set_target_rotation_to: Node2D

func _process(delta):
  position += Vector2.RIGHT.rotated(target_rotation) * move_speed * delta

  if set_target_rotation_to:
    set_target_rotation_to.rotation = target_rotation

func _on_hitbox_body_entered(body: Node2D):
  # duck typing to the fullest!
  if body.has_method('hit'):
    body.hit()
    queue_free()
