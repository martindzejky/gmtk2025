extends Node2D
class_name MeleeStrike

@export var target_rotation := 0.0
@export var sprite_rotation_node: Node2D
@export var collider_rotation_node: Node2D

func _process(_delta):
  if not is_instance_valid(sprite_rotation_node) or not is_instance_valid(collider_rotation_node): return
  sprite_rotation_node.rotation = target_rotation
  collider_rotation_node.rotation = target_rotation

func _on_hitbox_body_entered(body: Node2D):
  # duck typing to the fullest!
  if body.has_method('free_from_capture'):
    body.free_from_capture()
    collider_rotation_node.queue_free()
  elif body.has_method('hit'):
    body.hit()
    collider_rotation_node.queue_free()
