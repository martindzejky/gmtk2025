extends Node2D
class_name Segment

@export var raycast: RayCast2D

var index := 0
var hook: Hook

func _process(_delta):
  queue_redraw()

  if is_last_segment():
    raycast.target_position = hook.player.global_position - global_position
  else:
    raycast.target_position = get_next_segment().global_position - global_position

func _draw():
  # draw chain to the player or next segment
  if is_last_segment():
    draw_line(Vector2.ZERO, hook.player.global_position - global_position, Color.WHITE, 2.0)
  else:
    draw_line(Vector2.ZERO, get_next_segment().global_position - global_position, Color.WHITE, 2.0)

func is_last_segment():
  return index == hook.segments.size() - 1

func get_previous_segment():
  return hook.segments[index - 1]

func get_next_segment():
  return hook.segments[index + 1]

func update_raycast_exceptions():
  raycast.clear_exceptions()
  raycast.add_exception(get_parent())

  if not is_last_segment():
    raycast.add_exception(get_next_segment().get_parent())

  # alternative to consider: add as exception all other segments' parents

func _physics_process(_delta):
  if raycast.is_colliding():
    print('New enemy hit by segment raycast, adding a segment at index ', index + 1)
    hook.add_segment_to_enemy(raycast.get_collider(), raycast.get_collision_point(), index + 1)
