extends Node

@export var sprites: Array[Texture2D]
@export var target: Sprite2D

func _ready():
  target.texture = sprites.pick_random()
