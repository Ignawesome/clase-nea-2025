class_name ContenedorEnemigos
extends Node2D

@export var enemigos: Array[PackedScene]

@onready var timer_spawn_enemigo: Timer = $TimerSpawnEnemigo


func _ready() -> void:
	timer_spawn_enemigo.timeout.connect(spawnear_enemigo)
	

func spawnear_enemigo():
	var escena_enemigo : PackedScene = enemigos.pick_random()
	var nodo_enemigo : Enemigo = escena_enemigo.instantiate()
	add_child(nodo_enemigo)
	nodo_enemigo.objetivo = Globales.jugador
	nodo_enemigo.global_position = get_posicion_al_azar()


func get_posicion_al_azar():
	var direccion_al_azar: Vector2 = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	var posicion_jugador: Vector2 = Globales.jugador.global_position
	var distancia: float = randf_range(500, 1000)
	
	var posicion: Vector2 = posicion_jugador + direccion_al_azar * distancia
	return posicion
