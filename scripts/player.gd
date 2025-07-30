extends CharacterBody2D
class_name Player

var speed := 200.0

func _physics_process(_delta):
  var input_vector = Input.get_vector('move_left', 'move_right', 'move_up', 'move_down')
  velocity = input_vector * speed
  move_and_slide()
