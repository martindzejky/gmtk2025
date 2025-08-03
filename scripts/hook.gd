extends Node2D
class_name Hook

@export var player: Player
@export var lasso: Lasso
@export var progress_bar: ProgressBar
@export var raycast: RayCast2D
@export var max_distance_from_player := 100.0
@export var speed := 300.0
@export var segment_object: PackedScene
@export var rotation_node: Node2D
@export var line_start_marker: Marker2D
@export var shadow_node: Node2D

@export_category('Sounds')
@export var rope_sound_player: AudioStreamPlayer
@export var rope_tied_sound_player: AudioStreamPlayer
@export var swoosh_sound_player: AudioStreamPlayer
@export var rope_sound_chance: float = 0.2

enum State {
  WITH_PLAYER,
  FLYING,
  HOOKED,
  RETURNING,
}

var state: State = State.WITH_PLAYER
var target_direction: Vector2 = Vector2.ZERO
var total_angle_change := 0.0
var last_angle := 0.0
var segments: Array[Segment] = [] # segments go from hook to player

func _ready():
  Game.hook = self

func shoot_in_direction(new_target_direction: Vector2):
  if state != State.WITH_PLAYER:
    print('Hook is not with player so it cannot shoot')
    return

  reparent(player.get_parent())
  target_direction = new_target_direction
  state = State.FLYING
  swoosh_sound_player.play()
  rope_sound_player.play()

  print('Shooting in direction: ', target_direction)

func hook_to_enemy(enemy: Enemy):
  if state != State.FLYING:
    print('Hook is not flying so it cannot hook to enemy')
    return

  state = State.HOOKED

  print('Hooking to enemy: ', enemy)
  reparent(enemy)
  position = Vector2.ZERO
  total_angle_change = 0.0
  last_angle = global_position.angle_to_point(player.global_position)
  update_raycast_exceptions()
  rope_tied_sound_player.play()

func catch_all_enemies():
  if state != State.HOOKED:
    print('Hook is not hooked so it cannot catch all enemies')
    return

  catch_enemy(get_parent())

  for segment in segments:
    catch_enemy(segment.get_parent())

  rope_tied_sound_player.play()

func catch_enemy(enemy: Enemy):
  enemy.capture()

func unhook():
  if state != State.HOOKED:
    print('Hook is not hooked so it cannot unhook') # so many hooks...
    return

  delete_segments()
  update_raycast_exceptions()

  state = State.RETURNING
  reparent(player.get_parent())

  swoosh_sound_player.play()
  rope_sound_player.play()

func _process(delta):
  queue_redraw()

  visible = state != State.WITH_PLAYER
  rotation_node.visible = state != State.HOOKED
  rotation_node.rotation = player.global_position.angle_to_point(global_position)
  progress_bar.visible = state == State.HOOKED
  shadow_node.visible = rotation_node.visible

  match state:
    State.FLYING:
      global_position += target_direction * speed * delta

      if global_position.distance_to(player.global_position) > max_distance_from_player:
        state = State.RETURNING

    State.RETURNING:
      var direction := global_position.direction_to(player.global_position)
      global_position += direction * speed * delta

      if global_position.distance_to(player.global_position) < 10:
        state = State.WITH_PLAYER
        reparent(lasso)
        position = Vector2.ZERO

    State.HOOKED:
      calculate_loop_around_progress()
      progress_bar.value = get_catch_percentage()

      if segments.size() > 0:
        raycast.target_position = segments[0].global_position - global_position
      else:
        raycast.target_position = player.global_position - global_position

      if randf() < rope_sound_chance:
        rope_sound_player.play()

func _draw():
  if state == State.WITH_PLAYER: return
  if player.dead or player.dying or Game.game_is_failed or player.cutscene:
    return

  var line_start := line_start_marker.global_position - global_position
  if state == State.HOOKED:
    line_start = Vector2(0, -20)

  var line_end = player.dude.melee_slot.global_position - global_position

  if segments.size() > 0:
    line_end = segments[0].global_position - global_position
    line_end.y -= 20

  draw_line(line_start, line_end, '#734234', 1.5)


func _on_body_entered(body: Node2D):
  # we hit something...

  if state != State.FLYING: return

  if body is Enemy:
    call_deferred('hook_to_enemy', body)
  else:
    state = State.RETURNING

func calculate_loop_around_progress():
  if state != State.HOOKED: return

  var current_angle := global_position.angle_to_point(player.global_position)
  var angle_diff := current_angle - last_angle

  # handle the -PI to PI angle wrap
  if angle_diff > PI:
    angle_diff -= 2 * PI
  elif angle_diff < -PI:
    angle_diff += 2 * PI

  total_angle_change += angle_diff
  last_angle = current_angle

  # have we wrapped around yet?
  if abs(total_angle_change) >= 2 * PI:
    catch_all_enemies()
    unhook()

func get_catch_percentage():
  if state != State.HOOKED:
    return 0.0

  return abs(total_angle_change) / (2 * PI)

func delete_segments():
  for segment in segments:
    segment.free() # TODO: had to use free() instead of queue_free()... will there be any problems?
  segments.clear()

func update_segment_indices():
  for i in range(segments.size()):
    segments[i].index = i

func update_raycast_exceptions():
  raycast.clear_exceptions()

  if state == State.HOOKED:
    raycast.add_exception(get_parent())

  for segment in segments:
    raycast.add_exception(segment.get_parent())
    segment.update_raycast_exceptions()

func _physics_process(_delta):
  match state:
    State.HOOKED:
      if raycast.is_colliding():
        if raycast.get_collider() is Enemy:
          print('New enemy hit by hook raycast, adding a segment at index 0')
          add_segment_to_enemy(raycast.get_collider(), raycast.get_collision_point(), 0)
        else:
          print('Cutting rope')
          unhook()

func add_segment_to_enemy(enemy: Enemy, _point_of_collision: Vector2, insert_segment_at_index: int):
  # test: recalculate the starting angle but only if this is a newly hooked enemy
  # result: it feels nice!
  if enemy != get_parent() and segments.all(func(segment: Segment): return segment.get_parent() != enemy):
    total_angle_change = 0.0
    last_angle = global_position.angle_to_point(player.global_position)

  var new_segment := segment_object.instantiate()

  enemy.add_child(new_segment)
  new_segment.hook = self
  # new_segment.global_position = point_of_collision

  segments.insert(insert_segment_at_index, new_segment)
  update_segment_indices()
  update_raycast_exceptions()

  rope_tied_sound_player.play()
