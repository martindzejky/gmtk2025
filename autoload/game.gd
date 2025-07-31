extends Node
# this is the Game autoload

var player: Player
var hook: Hook

func _process(_delta):
  if Input.is_action_just_pressed('restart'):
    get_tree().reload_current_scene()

  if Input.is_action_just_pressed('exit'):
    get_tree().quit()
