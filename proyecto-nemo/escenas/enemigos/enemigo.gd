class_name Enemigo
extends CharacterBody2D

# ==============================================================================
# PROPIEDADES BASE DEL ENEMIGO (Configurable por cada criatura)
# ==============================================================================

@export var velocidad_de_movimiento: float = 100.0  # Velocidad de persecución hacia el jugador
@export var puntos_de_salud_maximos: float = 3.0    # Vida inicial del enemigo
@export var danio_por_contacto: float = 1.0         # Daño que hace al tocar al jugador
@export var recompensa_xp: float = 1.0              # Cantidad de XP que suelta al morir

# ==============================================================================
# VARIABLES Y REFERENCIAS
# ==============================================================================

var salud_actual: float
var objetivo: Node2D = null # Referencia al Jugador
var esta_muerto: bool = false

# Asegúrate de que tu escena Enemigo.tscn tenga un Area2D llamado "Hitbox"

@onready var hitbox: Area2D = %Hitbox
@onready var hurtbox: Area2D = %Hurtbox

# ==============================================================================
# FUNCIONES NATIVAS DE GODOT
# ==============================================================================

func _ready():
	salud_actual = puntos_de_salud_maximos
	
	# Conectar la señal para detectar cuando el enemigo toca al jugador
	if hitbox:
		hitbox.body_entered.connect(_on_hitbox_body_entered)


func _physics_process(delta):
	# Si el enemigo está muerto o no encuentra al jugador, no hace nada
	if esta_muerto or not objetivo:
		return

	# Lógica de I.A.: Persecución Simple
	var direccion = global_position.direction_to(objetivo.global_position).normalized()
	
	# Aplicar el movimiento
	velocity.x = direccion.x * velocidad_de_movimiento
	velocity.y = direccion.y * velocidad_de_movimiento
	
	move_and_slide()

# ==============================================================================
# COMBATE Y DAÑO
# ==============================================================================

# Se llama desde el Misil.gd cuando golpea a este enemigo
func recibir_danio(cantidad_de_danio: float):
	if esta_muerto:
		return
		
	salud_actual -= cantidad_de_danio
	# print("Enemigo golpeado, HP restante: %f" % salud_actual) # Mostrar en consola
	
	if salud_actual <= 0:
		morir.call_deferred()

# Se activa cuando el Hitbox del enemigo toca un CharacterBody2D
func _on_hitbox_body_entered(body: Node2D):
	# Verificamos si lo que golpeamos es el jugador (usando el class_name)
	if body is Jugador:
		var jugador_detectado: Jugador = body
		# Llamar a la función del jugador para hacerle daño y activar la lógica de esquiva
		jugador_detectado.recibir_danio(danio_por_contacto)
		
		# Eliminamos al enemigo por contacto (como en Vampire Survivors)
		# En una versión más avanzada, se podría usar un cooldown
		morir.call_deferred()

# ==============================================================================
# MUERTE Y RECOMPENSAS
# ==============================================================================

func morir():
	if esta_muerto:
		return
		
	esta_muerto = true

	# 1. Lógica para soltar el OrbeXP (implementar en Sesión 6)
	var nueva_orbe: OrbeExperiencia = OrbeExperiencia.crear_orbe_xp(recompensa_xp)
	Globales.contenedor_objetos.add_child(nueva_orbe)
	nueva_orbe.global_position = global_position

	# 2. Eliminar el nodo de la escena
	queue_free()
