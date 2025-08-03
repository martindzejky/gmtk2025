extends Node

@export var gradient_color: Gradient
@export var target: Sprite2D

func _ready():
  target.self_modulate = gradient_color.sample(randf())
