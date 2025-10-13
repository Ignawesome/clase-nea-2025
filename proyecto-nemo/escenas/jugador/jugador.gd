class_name Jugador
extends CharacterBody2D

# ==============================================================================
# PROPIEDADES EXPORTADAS (Visible en el Inspector)
# ==============================================================================

# Movimiento
@export var velocidad_de_movimiento: float = 200.0 # Velocidad horizontal/vertical base
@export var peso_submarino: float = 8.0            # Fuerza constante que hunde al submarino (gravedad)

# Ataque
@export var fuerza_de_ataque := 1.0                # Daño base de los misiles
@export var velocidad_de_ataque := 1.0             # Frecuencia de disparo (ej: 1.0 por segundo)

# Defensa
@export var puntos_de_salud_maximos := 5.0         # Vida máxima del personaje
@export var probabilidad_de_esquiva: float = 0.05  # Probabilidad de no recibir daño (5%)

# ==============================================================================
# SISTEMA DE NIVELACIÓN Y ESTADÍSTICAS
# ==============================================================================

var nivel: int = 1
var experiencia_actual: float = 0.0
var experiencia_para_subir: float = 10.0 # Cantidad de XP necesaria para Nivel 2

# ==============================================================================
# VARIABLES Y SEÑALES
# ==============================================================================

var salud_actual: float: set = al_cambiar_de_salud

signal derrotado 
signal salud_cambiada(salud_nueva, salud_maxima)
signal nivel_subido(nuevo_nivel)
signal experiencia_ganada(cantidad)

@onready var animated_sprite = $AnimatedSprite2D

# ==============================================================================
# FUNCIONES NATIVAS DE GODOT
# ==============================================================================

func _ready():
	# Inicializar la salud
	salud_actual = puntos_de_salud_maximos
	salud_cambiada.emit(salud_actual, puntos_de_salud_maximos)
	
func _physics_process(_delta) -> void:
	# 1. Obtener input del jugador
	var direccion = Vector2.ZERO
	direccion.x = Input.get_action_strength("derecha") - Input.get_action_strength("izquierda")
	direccion.y = Input.get_action_strength("abajo") - Input.get_action_strength("arriba")
	
	direccion = direccion.normalized()
	
	# 2. Aplicar el movimiento base (control del jugador)
	velocity = direccion * velocidad_de_movimiento
	
	# 3. LÓGICA DE HUNDIMIENTO: Aplicar fuerza descendente constante
	# El submarino siempre se hunde (velocity.y aumenta)
	velocity.y += peso_submarino 
	# El jugador puede contrarrestar esto empujando "arriba"
	
	# 4. Mover el personaje
	move_and_slide()

# ==============================================================================
# SISTEMA DE SALUD
# ==============================================================================

func al_cambiar_de_salud(nueva_salud: float) -> void:
	
	if nueva_salud > puntos_de_salud_maximos:
		nueva_salud = puntos_de_salud_maximos
	
	salud_actual = nueva_salud
	
	salud_cambiada.emit(salud_actual, puntos_de_salud_maximos)
	
	if salud_actual <= 0:
		derrotado.emit()
		queue_free()

func recibir_danio(cantidad_de_danio: float) -> void:
	if salud_actual <= 0:
		return
		
	# Lógica de Probabilidad de Esquiva
	if randf() < probabilidad_de_esquiva:
		# Feedback: Mostrar un mensaje de 'ESQUIVADO' (para implementar después)
		print("¡Esquivado!")
		return
		
	# Aplicar daño si no se esquiva
	salud_actual -= cantidad_de_danio
	# Aquí se puede agregar lógica de feedback visual (parpadeo)

# ==============================================================================
# SISTEMA DE PROGRESIÓN (XP y Nivelación)
# ==============================================================================

func ganar_experiencia(cantidad: float) -> void:
	experiencia_actual += cantidad
	experiencia_ganada.emit(cantidad)
	
	# Verificar si se sube de nivel
	if experiencia_actual >= experiencia_para_subir:
		subir_de_nivel()

func subir_de_nivel() -> void:
	# Ajustar XP restante y aumentar nivel
	experiencia_actual -= experiencia_para_subir
	nivel += 1
	
	# Aumentar la XP necesaria para el próximo nivel (ej: 10% más difícil)
	experiencia_para_subir *= 1.1 
	
	# Aumentar capacidades (el núcleo del juego!)
	puntos_de_salud_maximos += 1
	fuerza_de_ataque += 0.5
	velocidad_de_ataque += 0.1
	probabilidad_de_esquiva = min(probabilidad_de_esquiva + 0.05, 0.5) # Máximo 50% de esquiva
	
	# Curar al máximo y emitir señal de nivel subido
	salud_actual = puntos_de_salud_maximos
	nivel_subido.emit(nivel)
	print("¡Nivel subido a %d!" % nivel)

# ==============================================================================
# SISTEMA DE ATAQUE (Para sesión 4)
# ==============================================================================
# La lógica del Timer para disparar misiles irá aquí.
# Se usa 'fuerza_de_ataque' y 'velocidad_de_ataque' para controlar el proyectil.
