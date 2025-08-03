extends Node
# this is the Game autoload

var player: Player
var hook: Hook

signal folks_updated
signal enemies_updated

func _process(_delta):
  if Input.is_action_just_pressed('restart'):
    get_tree().reload_current_scene()

  if Input.is_action_just_pressed('exit'):
    get_tree().quit()

func emit_folks_updated():
  folks_updated.emit()

func emit_enemies_updated():
  enemies_updated.emit()
