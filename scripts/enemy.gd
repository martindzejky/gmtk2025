extends CharacterBody2D
class_name Enemy

var speed := 50.0

func _physics_process(_delta):
  var direction := global_position.direction_to(Game.player.global_position)
  velocity = direction * speed
  move_and_slide()

func is_hooked():
  return Game.hook.state == Hook.State.HOOKED and Game.hook.get_parent() == self
