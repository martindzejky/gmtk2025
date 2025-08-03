extends Label

func _ready():
  Game.folks_updated.connect(_on_folks_updated)
  call_deferred('_on_folks_updated')

func _on_folks_updated():
  text = str(get_tree().get_nodes_in_group('folk').size())
