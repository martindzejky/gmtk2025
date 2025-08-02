extends CharacterBody2D
class_name Enemy

@export_category('Dude')
@export var dude: Dude

@export_category('Movement')
@export var can_move := true
@export var move_speed := 50.0
@export var hook_pull_speed := 20.0

@export_category('Melee')
@export var can_attack_melee := true
@export var melee_strike_distance := 20.0
@export var melee_strike_object: PackedScene

@export_category('Release captured')
@export var can_release_captured := true
@export var release_captured_bias := 0.1

@export_category('Ranged')
@export var can_attack_ranged := true
@export var min_ranged_attack_distance := 20.0
@export var max_ranged_attack_distance := 100.0
@export var projectile_object: PackedScene

@export_category('Weapons')
@export var melee_weapons: Array[PackedScene]
@export var ranged_weapons: Array[PackedScene]
@export var melee_weapon_attack_animation := 'melee'
@export var ranged_weapon_attack_animation := 'shoot'

@export_category('Timers')
@export var melee_cooldown_timer: Timer
@export var shoot_cooldown_timer: Timer

@export_category('Flocking')
@export var nearby_area: Area2D
@export var flocking_separation_distance := 30
@export var flocking_separation_weight := 0.1
@export var flocking_alignment_weight := 0.1

enum State {
  ATTACKING_PLAYER,
  RELEASING_CAPTURED,
  CAPTURED,
}

var state := State.ATTACKING_PLAYER
var release_captured_target: Enemy
var attack_target: Node2D
var performing_attack: String

func _ready():
  if can_attack_melee and melee_weapons.size() > 0:
    var melee_weapon = melee_weapons.pick_random()
    var melee_weapon_instance = melee_weapon.instantiate()
    dude.equip_melee_weapon(melee_weapon_instance)

  if can_attack_ranged and ranged_weapons.size() > 0:
    var ranged_weapon = ranged_weapons.pick_random()
    var ranged_weapon_instance = ranged_weapon.instantiate()
    dude.equip_bow_weapon(ranged_weapon_instance)

func _process(_delta):
  update_dude_animation()

func _physics_process(_delta):
  velocity = Vector2.ZERO

  match state:
    State.ATTACKING_PLAYER:
      go_attack_player()
      apply_flocking()

    State.RELEASING_CAPTURED:
      go_release_captured()
      apply_flocking()

  if is_hooked_by_segment():
    lasso_segment_pull()

  if can_move and state != State.CAPTURED:
    move_and_slide()

func go_attack_player():
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
      attack_melee(Game.player)

    if can_attack_ranged and shoot_cooldown_timer.time_left <= 0 and distance_to_player >= min_ranged_attack_distance and distance_to_player <= max_ranged_attack_distance:
      shoot_ranged(Game.player)

func go_release_captured():
  if not is_instance_valid(release_captured_target) or not release_captured_target.is_captured() or not can_release_captured or not can_attack_melee:
    state = State.ATTACKING_PLAYER
    release_captured_target = null
    return

  if melee_cooldown_timer.time_left > 0 or shoot_cooldown_timer.time_left > 0: return

  var distance_to_release_captured_target := global_position.distance_to(release_captured_target.global_position)

  if distance_to_release_captured_target > melee_strike_distance:
    move_towards_release_captured_target()
  else:
    attack_melee(release_captured_target)
    state = State.ATTACKING_PLAYER

func move_towards_player():
  var direction := global_position.direction_to(Game.player.global_position)
  velocity += direction * get_movement_speed()

func move_away_from_player():
  var direction := Game.player.global_position.direction_to(global_position)
  velocity += direction * get_movement_speed()

func move_towards_release_captured_target():
  var direction := global_position.direction_to(release_captured_target.global_position)
  velocity += direction * get_movement_speed()

func apply_flocking():
  if melee_cooldown_timer.time_left > 0 or shoot_cooldown_timer.time_left > 0: return

  var nearby_enemies := nearby_area.get_overlapping_bodies()

  # limit to 10 enemies for performance... premature optimization?
  if nearby_enemies.size() > 10:
    nearby_enemies = nearby_enemies.slice(0, 10)

  var separation_force := Vector2.ZERO
  var alignment_force := Vector2.ZERO
  var neighbor_count := 0

  for enemy in nearby_enemies:
    if enemy == self or not enemy is Enemy:
      continue

    neighbor_count += 1
    var distance := global_position.distance_to(enemy.global_position)

    if distance < flocking_separation_distance and distance > 0:
      var away_direction := global_position - enemy.global_position
      var separation_strength := flocking_separation_distance - distance
      separation_force += away_direction.normalized() * separation_strength

    if enemy.velocity.length() > 0:
      alignment_force += enemy.velocity.normalized()

  if separation_force.length() > 0:
    velocity += separation_force.normalized() * get_movement_speed() * flocking_separation_weight

  if neighbor_count > 0 and alignment_force.length() > 0:
    alignment_force = alignment_force / neighbor_count
    velocity += alignment_force.normalized() * get_movement_speed() * flocking_alignment_weight

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

func attack_melee(target):
  attack_target = target
  performing_attack = 'melee'
  melee_cooldown_timer.start()
  dude_melee_animation(target)

func shoot_ranged(target):
  attack_target = target
  performing_attack = 'ranged'
  shoot_cooldown_timer.start()
  dude_shoot_animation(target)

func is_captured():
  return state == State.CAPTURED

func capture():
  if state == State.CAPTURED: return

  state = State.CAPTURED

  # this is a quick hack to save time:
  # I want to change the collision layer from 'enemy' to 'captured_enemy' which is the next layer
  # so just shift the layer bit by 1
  collision_layer = collision_layer << 1

  Game.enemies_updated.emit()

func free_from_capture():
  if state != State.CAPTURED: return

  state = State.ATTACKING_PLAYER

  # again the hack mentioned above
  collision_layer = collision_layer >> 1

  Game.enemies_updated.emit()

func collect_captured():
  # TODO: animation and add some points or something
  queue_free()

func _on_ai_decision_timer_timeout():
  if state != State.ATTACKING_PLAYER: return

  if not can_release_captured: return
  if not can_attack_melee: return

  var decision := randf()
  if decision < release_captured_bias:
    print('Decided to release captured enemies')
    state = State.RELEASING_CAPTURED

    var all_captured_enemies := get_tree().get_nodes_in_group('enemy').filter(func(enemy): return enemy.is_captured())
    if all_captured_enemies.size() <= 0:
      print('There are no captured enemies to release, returning to attacking player')
      state = State.ATTACKING_PLAYER
      release_captured_target = null
      return

    var closest_captured_enemy := all_captured_enemies[0] as Enemy
    var closest_distance := global_position.distance_squared_to(closest_captured_enemy.global_position)

    for enemy in all_captured_enemies:
      var distance := global_position.distance_squared_to(enemy.global_position)
      if distance < closest_distance:
        closest_distance = distance
        closest_captured_enemy = enemy

    release_captured_target = closest_captured_enemy

func dude_melee_animation(target):
  dude.play_animation(melee_weapon_attack_animation)

  var dir := global_position.direction_to(target.global_position)
  if abs(dir.x) > 0:
    dude.scale.x = sign(dir.x)

func dude_shoot_animation(target):
  dude.play_animation(ranged_weapon_attack_animation)
  var dir := global_position.direction_to(target.global_position)
  if abs(dir.x) > 0:
    dude.scale.x = sign(dir.x)

func update_dude_animation():
  if melee_cooldown_timer.time_left > 0: return
  if shoot_cooldown_timer.time_left > 0: return

  match state:
    State.CAPTURED:
      dude.play_animation('captured')

    _:
      if velocity.length() > 0:
        dude.play_animation('running')
      else:
        dude.play_animation('idle')

      if abs(velocity.x) > 0:
        dude.scale.x = sign(velocity.x)

func _on_dude_melee_attack():
  if performing_attack == 'melee':
    perform_melee_attack()
  elif performing_attack == 'ranged':
    perform_ranged_attack()

func _on_dude_shoot_attack():
  if performing_attack == 'melee':
    perform_melee_attack()
  elif performing_attack == 'ranged':
    perform_ranged_attack()

func perform_melee_attack():
  var melee_strike = melee_strike_object.instantiate()
  get_parent().add_child(melee_strike)

  melee_strike.global_position = global_position
  melee_strike.global_rotation = global_position.angle_to_point(attack_target.global_position)

  if attack_target == release_captured_target:
    release_captured_target.free_from_capture() # TODO: this should be done in the melee strike object
    release_captured_target = null

func perform_ranged_attack():
  var projectile = projectile_object.instantiate()
  get_parent().add_child(projectile)

  projectile.global_position = global_position
  projectile.target_rotation = global_position.angle_to_point(attack_target.global_position)
