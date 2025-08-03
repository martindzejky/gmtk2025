extends Node2D
class_name Effect

@export var particles: GPUParticles2D
@export var height_node: Node2D

func set_height(height: float):
  height_node.position.y = -height

func set_amount(amount: int):
  particles.process_material.emission_sphere_radius *= clampf(float(amount) / particles.amount * 0.3, 1.0, 10.0)
  particles.amount = amount

func play():
  particles.restart()

func _on_particles_finished():
  queue_free()
