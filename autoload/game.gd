extends Node
# this is the Game autoload

var player: Player
var hook: Hook

func _ready():
  player = get_tree().get_first_node_in_group('player')
  hook = get_tree().get_first_node_in_group('hook')
