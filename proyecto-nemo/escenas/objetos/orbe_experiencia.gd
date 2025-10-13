class_name OrbeExperiencia
extends Area2D

@export var cantidad_de_experiencia := 1.0

const ORBE_XP_ESCENA = preload("uid://bkmeox5n8r0w")

static func crear_orbe_xp(cantidad_xp: float = 1.0):
	var orbe_nodo: OrbeExperiencia = ORBE_XP_ESCENA.instantiate()
	orbe_nodo.cantidad_de_experiencia = cantidad_xp
	return orbe_nodo

func _on_body_entered(body: Node2D) -> void:
	if body is Jugador:
		body.ganar_experiencia(cantidad_de_experiencia)
		queue_free()
