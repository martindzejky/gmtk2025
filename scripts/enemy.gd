extends CharacterBody2D
class_name Enemy

@export_category('Movement')
@export var can_move := true
@export var move_speed := 50.0
@export var hook_pull_speed := 20.0

@export_category('Melee')
@export var can_attack_melee := true
@export var melee_strike_distance := 20.0
@export var melee_strike_object: PackedScene

@export_category('Ranged')
@export var can_attack_ranged := true
@export var min_ranged_attack_distance := 20.0
@export var max_ranged_attack_distance := 100.0
@export var projectile_object: PackedScene

@export_category('Timers')
@export var melee_cooldown_timer: Timer
@export var shoot_cooldown_timer: Timer

@export_category('Sprites')
@export var sprite: Sprite2D
@onready var default_sprite: Texture2D = sprite.texture
@export var captured_sprite: Texture2D

enum State {
  ATTACKING_PLAYER,
  CAPTURED,
}

var state := State.ATTACKING_PLAYER

func _physics_process(_delta):
  velocity = Vector2.ZERO

  match state:
    State.ATTACKING_PLAYER:
      attack_player()

  if is_hooked_by_segment():
    lasso_segment_pull()

  if can_move and state != State.CAPTURED:
    move_and_slide()

func attack_player():
  var distance_to_player := global_position.distance_to(Game.player.global_position)

  if melee_cooldown_timer.time_left <= 0 and shoot_cooldown_timer.time_left <= 0:
    if can_attack_ranged:
      if distance_to_player > max_ranged_attack_distance:
        move_towards_player()
      elif distance_to_player < min_ranged_attack_distance:
        if can_attack_melee:
          if distance_to_player > melee_strike_distance:
            move_towards_player()
        else:
          move_away_from_player()
    elif can_attack_melee:
      if distance_to_player > melee_strike_distance:
        move_towards_player()

  if not is_hooked():
    if can_attack_melee and melee_cooldown_timer.time_left <= 0 and distance_to_player <= melee_strike_distance:
      attack_melee()

    if can_attack_ranged and shoot_cooldown_timer.time_left <= 0 and distance_to_player >= min_ranged_attack_distance and distance_to_player <= max_ranged_attack_distance:
      shoot_ranged()

func move_towards_player():
  var direction := global_position.direction_to(Game.player.global_position)
  velocity += direction * get_movement_speed()

func move_away_from_player():
  var direction := Game.player.global_position.direction_to(global_position)
  velocity += direction * get_movement_speed()

func lasso_segment_pull():
  var direction := global_position.direction_to(Game.hook.global_position)
  velocity += direction * hook_pull_speed

func is_hooked():
  var groups := ['hook', 'segment']

  for child in get_children():
    for group in groups:
      if child.is_in_group(group):
        return true
  return false

func is_hooked_by_hook():
  for child in get_children():
    if child.is_in_group('hook'):
      return true
  return false

func is_hooked_by_segment():
  for child in get_children():
    if child.is_in_group('segment'):
      return true
  return false

func get_movement_speed():
  if not is_hooked():
    return move_speed

  return lerpf(move_speed/2, move_speed/10, Game.hook.get_catch_percentage())

func attack_melee():
  melee_cooldown_timer.start()

  var melee_strike = melee_strike_object.instantiate()
  get_parent().add_child(melee_strike)

  melee_strike.global_position = global_position
  melee_strike.global_rotation = global_position.angle_to_point(Game.player.global_position)

func shoot_ranged():
  shoot_cooldown_timer.start()

  var projectile = projectile_object.instantiate()
  get_parent().add_child(projectile)

  projectile.global_position = global_position
  projectile.global_rotation = global_position.angle_to_point(Game.player.global_position)

func is_captured():
  return state == State.CAPTURED

func capture():
  state = State.CAPTURED
  sprite.texture = captured_sprite

  # this is a quick hack to save time:
  # I want to change the collision layer from 'enemy' to 'captured_enemy' which is the next layer
  # so just shift the layer bit by 1
  collision_layer = collision_layer << 1

  Game.enemies_updated.emit()

func free_from_capture():
  state = State.ATTACKING_PLAYER
  sprite.texture = default_sprite

  # again the hack mentioned above
  collision_layer = collision_layer >> 1

  Game.enemies_updated.emit()

func collect_captured():
  # TODO: animation and add some points or something
  queue_free()
