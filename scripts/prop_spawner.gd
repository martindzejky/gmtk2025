extends Node2D
class_name PropSpawner

@export var props: Array[PropChancePair]
@export var radius := 100.0
@export var amount := 10

func _ready():
  assert(props.size() > 0, 'No props defined')
  call_deferred('spawn_props')

func spawn_props():
  var total_chance = 0
  for prop in props:
    total_chance += prop.chance

  for i in range(amount):
    var random_chance = randf_range(0, total_chance)
    var current_chance = 0

    for prop in props:
      current_chance += prop.chance

      if random_chance <= current_chance:
        var prop_instance = prop.prop.instantiate()
        get_parent().add_child(prop_instance)

        # var random_position = (Vector2.RIGHT * randf_range(0, radius))
        # random_position = random_position.rotated(randf_range(0, 2 * PI))
        # prop_instance.global_position = global_position + random_position

        # https://stackoverflow.com/questions/5837572/generate-a-random-point-within-a-circle-uniformly
        var r = radius * sqrt(randf())
        var theta = randf() * 2 * PI
        var x = global_position.x + r * cos(theta)
        var y = global_position.y + r * sin(theta)

        prop_instance.global_position = Vector2(x, y)

        break
