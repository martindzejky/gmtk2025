extends Node2D
class_name Dude

signal melee_attack
signal shoot_attack

@export_category('Sprites')
@export var legs_sprite: Sprite2D
@export var body_sprite: Sprite2D
@export var head_sprite: Sprite2D
@export var hat_sprite: Sprite2D
@export var bandana_sprite: Sprite2D
@export var sheriff_star_sprite: Sprite2D

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
@export var bandana_color_gradient: Gradient

@export_category('Features')
@export var hat_chance: float = 0.4
@export var bandana_chance: float = 0.4
@export var has_sheriff_star := false
@export var force_first_hat := false

@export_category('Sprites')
@export var hat_sprites: Array[Texture2D]
@export var bandana_sprites: Array[Texture2D]

@export_category('Weapons')
@export var melee_slot: Node2D
@export var bow_back_slot: Node2D
@export var bow_front_slot: Node2D

func _ready():
  self.randomize()

func play_animation(animation_name: String):
  if animation_name != animation_player.current_animation:
    animation_player.play('RESET')
    animation_player.queue(animation_name)

func randomize():
  # sheriff star
  sheriff_star_sprite.visible = has_sheriff_star

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
  bandana_sprite.self_modulate = bandana_color_gradient.sample(randf())

  # hat and bandana
  hat_sprite.visible = randf() < hat_chance
  bandana_sprite.visible = randf() < bandana_chance

  if hat_sprite.visible:
    bandana_sprite.visible = false

  # sprites
  hat_sprite.texture = hat_sprites.pick_random()
  bandana_sprite.texture = bandana_sprites.pick_random()

  if force_first_hat:
    hat_sprite.texture = hat_sprites[0]

func emit_melee_attack():
  melee_attack.emit()

func emit_shoot_attack():
  shoot_attack.emit()

func equip_melee_weapon(weapon: Node2D):
  melee_slot.add_child(weapon)

func equip_bow_weapon(weapon: Node2D):
  bow_back_slot.add_child(weapon)
  bow_front_slot.add_child(weapon.duplicate())

func set_bow_active():
  for child in bow_back_slot.get_children():
    if child is Bow:
      child.set_active_frame()
  for child in bow_front_slot.get_children():
    if child is Bow:
      child.set_active_frame()

func set_bow_default():
  for child in bow_back_slot.get_children():
    if child is Bow:
      child.set_default_frame()
  for child in bow_front_slot.get_children():
    if child is Bow:
      child.set_default_frame()
