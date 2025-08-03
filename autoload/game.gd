extends Node
# this is the Game autoload

var player: Player
var hook: Hook

signal folks_updated
signal enemies_updated
signal wave_starts(number: int)
signal wave_ends(number: int)

func _process(_delta):
  if Input.is_action_just_pressed('restart'):
    get_tree().reload_current_scene()

  if Input.is_action_just_pressed('exit'):
    get_tree().quit()

func emit_folks_updated():
  folks_updated.emit()

func emit_enemies_updated():
  enemies_updated.emit()

func emit_wave_starts(number: int):
  wave_starts.emit(number)

func emit_wave_ends(number: int):
  wave_ends.emit(number)
