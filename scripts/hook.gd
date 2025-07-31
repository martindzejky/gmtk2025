extends Node2D
class_name Hook

@export var player: Player
@export var lasso: Lasso
@export var progress_bar: ProgressBar
@export var max_distance_from_player := 100.0
@export var speed := 300.0

enum State {
  WITH_PLAYER,
  FLYING,
  HOOKED,
  RETURNING,
}

var state: State = State.WITH_PLAYER
var target_direction: Vector2 = Vector2.ZERO
var total_angle_change := 0.0
var starting_angle := 0.0
var last_angle := 0.0

func shoot_in_direction(new_target_direction: Vector2):
  if state != State.WITH_PLAYER:
    print('Hook is not with player so it cannot shoot')
    return

  reparent(player.get_parent())
  target_direction = new_target_direction
  state = State.FLYING

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
  starting_angle = global_position.angle_to_point(player.global_position)
  last_angle = starting_angle

func catch_enemy(enemy: Enemy):
  # TODO: what happens here?
  enemy.queue_free()

func unhook():
  if state != State.HOOKED:
    print('Hook is not hooked so it cannot unhook') # so many hooks...
    return

  state = State.RETURNING
  reparent(player.get_parent())

func _process(delta):
  queue_redraw()

  progress_bar.visible = state == State.HOOKED

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
        catch_enemy(get_parent())
        unhook()

      progress_bar.value = abs(total_angle_change) / (2 * PI)

func _draw():
  if state != State.WITH_PLAYER:
    # draw chain to the player
    draw_line(Vector2.ZERO, player.global_position - global_position, Color.WHITE, 2.0)

  if state == State.HOOKED:
    # draw the starting direction
    draw_line(Vector2.ZERO, Vector2.RIGHT.rotated(starting_angle) * 100, Color.PINK, 2.0)


func _on_body_entered(body: Node2D):
  # we hit something...

  if state != State.FLYING: return

  if body is Enemy:
    call_deferred('hook_to_enemy', body)
  else:
    state = State.RETURNING
