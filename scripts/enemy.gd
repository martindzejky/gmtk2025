extends CharacterBody2D
class_name Enemy

@export var speed := 50.0
@export var hook_pull_speed := 20.0

func _physics_process(_delta):
  velocity = Vector2.ZERO

  # move towards player
  if global_position.distance_to(Game.player.global_position) > 20:
    var direction := global_position.direction_to(Game.player.global_position)
    velocity += direction * get_movement_speed()

  # lasso segment pull
  if is_hooked_by_segment():
    var direction := global_position.direction_to(Game.hook.global_position)
    velocity += direction * hook_pull_speed

  move_and_slide()

func is_hooked():
  var groups := ['hook', 'segment']

  for child in get_children():
    for group in groups:
      if child.is_in_group(group):
        return true
  return false

func is_hooked_by_hook():
  for child in get_children():
    if child.is_in_group('hook'):
      return true
  return false

func is_hooked_by_segment():
  for child in get_children():
    if child.is_in_group('segment'):
      return true
  return false

func get_movement_speed():
  if not is_hooked():
    return speed

  return lerpf(speed/2, speed/10, Game.hook.get_catch_percentage())
