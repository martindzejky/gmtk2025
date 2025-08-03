extends Label

func _ready():
  Game.enemies_updated.connect(_on_enemies_updated)
  call_deferred('_on_enemies_updated')

func _on_enemies_updated():
  text = str(get_tree().get_nodes_in_group('enemy').filter(func(enemy: Enemy): return not enemy.is_captured()).size())
