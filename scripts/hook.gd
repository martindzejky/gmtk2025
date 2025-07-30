extends Node2D
class_name Hook

@export var player: Player
@export var lasso: Lasso
@export var max_distance_from_player := 100.0

enum State {
  WITH_PLAYER,
  FLYING,
  HOOKED,
  RETURNING,
}

var state: State = State.WITH_PLAYER
var target_direction: Vector2 = Vector2.ZERO
var speed := 300.0

func shoot_in_direction(new_target_direction: Vector2):
  if state != State.WITH_PLAYER:
    print('Hook is not with player so it cannot shoot')
    return

  reparent(player.get_parent())
  target_direction = new_target_direction
  state = State.FLYING

  print('Shooting in direction: ', target_direction)

func _process(delta):
  queue_redraw()

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

func _draw():
  if state != State.WITH_PLAYER:
    # draw chain to the player
    draw_line(Vector2.ZERO, player.global_position - global_position, Color.WHITE, 2.0)


func _on_body_entered(body: Node2D):
  # we hit something...

  if state != State.FLYING: return

  print('Hook hit: ', body)

  if body is Enemy:
    state = State.HOOKED
    reparent(body)
    position = Vector2.ZERO
  else:
    state = State.RETURNING
