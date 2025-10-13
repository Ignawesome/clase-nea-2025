class_name Misil
extends Area2D

# ==============================================================================
# PROPIEDADES EXPORTADAS
# ==============================================================================

@export var velocidad_misil: float = 800.0  # El misil es rápido, idealmente más rápido que los enemigos.
@export var tiempo_maximo_de_vida: float = 0.5 # Se autodestruye después de 0.5 segundos.

# ==============================================================================
# VARIABLES Y REFERENCIAS
# ==============================================================================

# Esta variable debe ser configurada por el Jugador.gd al momento de instanciar
# el misil. Permite que el daño del misil escale con el nivel del jugador.
var danio_a_infligir: float = 1.0 
var direccion: Vector2 = Vector2.RIGHT

@onready var tiempo_de_vida = $TiempoDeVida # Debe ser un nodo Timer hijo

# ==============================================================================
# FUNCIONES NATIVAS DE GODOT
# ==============================================================================

#static func crear_misil(duracion, danio, )

func _ready():
	# 1. Configurar y empezar el temporizador de autodestrucción
	tiempo_de_vida.wait_time = tiempo_maximo_de_vida
	tiempo_de_vida.one_shot = true # Solo se ejecuta una vez
	tiempo_de_vida.start()
	
	# 2. Conectar la señal de colisión (body_entered)
	# Esta señal detecta cuando un CharacterBody2D (el enemigo) entra en el Area2D.
	body_entered.connect(_on_body_entered)

func _process(delta):
	# Mover el misil constantemente en la dirección asignada
	global_position += direccion * velocidad_misil * delta

# ==============================================================================
# MANEJADORES DE SEÑALES
# ==============================================================================

# Se llama cuando el temporizador de tiempo de vida se agota
func _on_tiempo_de_vida_timeout():
	# Si no golpeó a nadie a tiempo, se elimina solo
	queue_free()

# Se llama cuando el misil golpea un cuerpo físico
func _on_body_entered(body: Node2D):
	# Usamos 'is' para verificar si el cuerpo golpeado es una instancia de la clase Enemigo
	if body is Enemigo:
		var enemigo_golpeado: Enemigo = body
		
		# 1. Aplicar daño al enemigo
		enemigo_golpeado.recibir_danio(danio_a_infligir)
		
		# 2. Destruir el misil (ya cumplió su propósito)
		queue_free()
		
	# Importante: Si golpea otros cuerpos (como rocas o corales, que son StaticBody2D)
	# el misil simplemente debe atravesarlos, o bien podrías agregar aquí un "queue_free()"
	# si quisieras que el misil se destruya contra rocas. Por ahora, solo se destruye
	# al golpear un enemigo.
