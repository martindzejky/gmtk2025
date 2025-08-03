extends Node
# this is the Effects autoload

@export var cloud_effect: PackedScene
@export var smoke_effect: PackedScene

func create_cloud_effect(pos: Vector2, height: float, amount: int = 1):
  spawn_effect(cloud_effect, pos, height, amount)

func create_smoke_effect(pos: Vector2, height: float, amount: int = 1):
  spawn_effect(smoke_effect, pos, height, amount)

func spawn_effect(effect_scene: PackedScene, pos: Vector2, height: float, amount: int):
  var effect = effect_scene.instantiate()
  get_tree().current_scene.add_child(effect)

  effect.global_position = pos
  effect.set_height(height)
  effect.set_amount(amount)
  effect.play()
