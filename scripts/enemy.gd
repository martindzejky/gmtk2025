extends CharacterBody2D
class_name Enemy

var speed := 50.0

func _physics_process(_delta):
  if global_position.distance_to(Game.player.global_position) > 20:
    var direction := global_position.direction_to(Game.player.global_position)
    velocity = direction * get_speed()
    move_and_slide()

func is_hooked():
  return Game.hook.state == Hook.State.HOOKED and Game.hook.get_parent() == self

func get_speed():
  if not is_hooked():
    return speed

  return lerpf(speed/2, speed/10, Game.hook.get_catch_percentage())
