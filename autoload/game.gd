extends Node
# this is the Game autoload

var player: Player
var hook: Hook

func _ready():
  set_globals()

func set_globals():
  player = get_tree().get_first_node_in_group('player')
  hook = get_tree().get_first_node_in_group('hook')

func _process(_delta):
  if Input.is_action_just_pressed('restart'):
    get_tree().reload_current_scene()
    call_deferred('set_globals')

  if Input.is_action_just_pressed('exit'):
    get_tree().quit()
