class_name Burbuja
extends Area2D

@export var velocidad := 100.0
@export var altura_maxima := -6000

func _physics_process(delta: float) -> void:
	global_position.y -= velocidad * delta
	
	# Desaparece si sale de pantalla para evitar un memory leak
	if global_position.y > altura_maxima:
		queue_free()
