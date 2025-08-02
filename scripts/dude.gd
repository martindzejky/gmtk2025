extends Node2D
class_name Dude

@export_category('Sprites')
@export var legs_sprite: Sprite2D
@export var body_sprite: Sprite2D
@export var head_sprite: Sprite2D
@export var hat_sprite: Sprite2D

@export_category('Animations')
@export var animation_player: AnimationPlayer

@export_category('Randomization')
@export var scale_body_node: Node2D
@export var scale_head_node: Node2D
@export var scale_body_min: float = 0.8
@export var scale_body_max: float = 1.2
@export var scale_head_min_x: float = 0.8
@export var scale_head_max_x: float = 1.2
@export var scale_head_min_y: float = 0.8
@export var scale_head_max_y: float = 1.2
@export var legs_color_gradient: Gradient
@export var body_color_gradient: Gradient
@export var head_color_gradient: Gradient
@export var hat_color_gradient: Gradient

func _ready():
  self.randomize()

func play_animation(animation_name: String):
  animation_player.play(animation_name)

func randomize():
  # scaling
  var scale_body = randf_range(scale_body_min, scale_body_max)
  scale_body_node.scale = Vector2(scale_body, 1)

  var scale_head_x = randf_range(scale_head_min_x, scale_head_max_x)
  var scale_head_y = randf_range(scale_head_min_y, scale_head_max_y)
  scale_head_node.scale = Vector2(scale_head_x, scale_head_y)

  # colors
  legs_sprite.self_modulate = legs_color_gradient.sample(randf())
  body_sprite.self_modulate = body_color_gradient.sample(randf())
  head_sprite.self_modulate = head_color_gradient.sample(randf())
  hat_sprite.self_modulate = hat_color_gradient.sample(randf())

  # TODO: sprites, hats, bandanas, etc.
