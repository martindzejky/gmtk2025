extends CharacterBody2D
class_name Folk

@export_category('Dude')
@export var dude: Dude

@export_category('Flocking')
@export var nearby_area: Area2D
@export var flocking_separation_distance := 30
@export var flocking_separation_weight := 0.1
@export var flocking_alignment_weight := 0.1

@export_category('Movement')
@export var move_speed := 20.0
@export var idle_min_time := 1.0
@export var idle_max_time := 4.0
@export var wandering_min_distance := 100.0
@export var wandering_max_distance := 200.0
@export var running_away_from_enemies_min_time := 2.0

@export_category('Timers')
@export var idle_timer: Timer
@export var running_away_from_enemies_timer: Timer
@export var enemy_attack_timer: Timer

@export_category('Cutscene')
@export var cutscene := false

@export_category('Grave')
@export var grave_scene: PackedScene

enum State {
  IDLE,
  WANDERING,
  RUNNING_AWAY_FROM_ENEMIES,
  GETTING_ATTACKED_BY_ENEMY,
  DYING
}

var state: State = State.IDLE
var global_wandering_position: Vector2
var global_home_position: Vector2
var last_running_away_from_enemies_direction: Vector2

func _ready():
  global_home_position = global_position # TODO: maybe something else?
  go_to_idle_from_random_duration()

func _physics_process(_delta):
  velocity = Vector2.ZERO

  if state != State.DYING and not cutscene:
    if enemy_attack_timer.time_left > 0:
      pass
    elif are_enemies_nearby() or running_away_from_enemies_timer.time_left > 0:
      state = State.RUNNING_AWAY_FROM_ENEMIES
    elif state == State.RUNNING_AWAY_FROM_ENEMIES:
      go_to_idle_from_random_duration()

  match state:
    State.IDLE:
      dude.play_animation('idle')

    State.DYING:
      dude.play_animation('die')

    State.WANDERING:
      dude.play_animation('running')
      go_to_wandering_position()
      apply_flocking()

    State.RUNNING_AWAY_FROM_ENEMIES:
      dude.play_animation('fleeing')
      run_away_from_enemies()
      apply_flocking()

    # hacky way to try and allow enemies to actually have a chance to hit folks
    State.GETTING_ATTACKED_BY_ENEMY:
      dude.play_animation('attacked')

  move_and_slide()

  if abs(velocity.x) > 0:
    dude.scale.x = sign(velocity.x)

func apply_flocking():
  var nearby_folks := nearby_area.get_overlapping_bodies().filter(func(body): return body is Folk)

  # limit to 10 folks for performance... premature optimization?
  if nearby_folks.size() > 10:
    nearby_folks = nearby_folks.slice(0, 10)

  var separation_force := Vector2.ZERO
  var alignment_force := Vector2.ZERO
  var neighbor_count := 0

  for folk in nearby_folks:
    if folk == self:
      continue

    neighbor_count += 1
    var distance := global_position.distance_to(folk.global_position)

    if distance < flocking_separation_distance and distance > 0:
      var away_direction: Vector2 = global_position - folk.global_position
      var separation_strength := flocking_separation_distance - distance
      separation_force += away_direction.normalized() * separation_strength

    if folk.velocity.length() > 0:
      alignment_force += folk.velocity.normalized()

  if separation_force.length() > 0:
    velocity += separation_force.normalized() * move_speed * flocking_separation_weight

  if neighbor_count > 0 and alignment_force.length() > 0:
    alignment_force = alignment_force / neighbor_count
    velocity += alignment_force.normalized() * move_speed * flocking_alignment_weight

func run_away_from_enemies():
  var nearby_enemies := nearby_area.get_overlapping_bodies().filter(func(body): return body is Enemy)

  # calculate the average direction of escape
  var average_escape_direction := Vector2.ZERO

  for enemy in nearby_enemies:
    var escape_direction = enemy.global_position.direction_to(global_position)
    average_escape_direction += escape_direction

  if nearby_enemies.size() == 0:
    average_escape_direction = last_running_away_from_enemies_direction

  # try to steer back towards home slightly
  var home_direction := global_position.direction_to(global_home_position)
  average_escape_direction = average_escape_direction.normalized().lerp(home_direction, 0.2).normalized()

  velocity += average_escape_direction * move_speed
  last_running_away_from_enemies_direction = average_escape_direction

  if nearby_enemies.size() > 0:
    running_away_from_enemies_timer.start(running_away_from_enemies_min_time)

func are_enemies_nearby():
  return nearby_area.get_overlapping_bodies().any(func(body): return body is Enemy)

func go_to_idle_from_random_duration():
  state = State.IDLE

  if cutscene: return

  var random_duration := randf_range(idle_min_time, idle_max_time)
  idle_timer.start(random_duration)
  await idle_timer.timeout

  # if chased by enemies in the meantime
  if state != State.IDLE: return

  start_wandering()

func start_wandering():
  state = State.WANDERING
  global_wandering_position = global_home_position + Vector2.UP.rotated(randf_range(0, 2 * PI)) * randf_range(wandering_min_distance, wandering_max_distance)

func go_to_wandering_position():
  var direction := global_position.direction_to(global_wandering_position)
  var distance := global_position.distance_to(global_wandering_position)
  if distance < 10:
    go_to_idle_from_random_duration()
  else:
    velocity = direction * move_speed

func start_enemy_attacking_timer():
  if state != State.DYING:
    state = State.GETTING_ATTACKED_BY_ENEMY
    enemy_attack_timer.start()

func _on_enemy_attack_timer_timeout():
  if state != State.DYING:
    state = State.RUNNING_AWAY_FROM_ENEMIES

func hit():
  state = State.DYING
  Game.call_deferred('folk_dying')

func _on_dude_die_end() -> void:
  # TODO: something more grandiose

  var grave = grave_scene.instantiate()
  get_parent().add_child(grave)
  grave.global_position = global_position + Vector2(20, 0) * sign(dude.scale.x)

  queue_free()
  await tree_exited
  Game.call_deferred('emit_folks_updated')

func end_cutscene():
  cutscene = false

  if randf() < 0.3:
    start_wandering()
  else:
    go_to_idle_from_random_duration()
