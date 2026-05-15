# SoundButtonList.gd
# Godot 4.5.1
# Poner este script en un Control vacío o ScrollContainer.

extends ScrollContainer

# ==================================================
# LISTA DE BOTONES
# ==================================================
# image es opcional.
# Si no tiene image usa la imagen default de Godot.
#
# pitch también es opcional.
#
# Para agregar más botones:
# duplicá un bloque y cambiá valores.
# ==================================================

@export var buttons_data := [
	{
		"name": "Disparo",
		"sound": preload("res://audio/so.mp3"),
		"image": preload("res://imagenes/icon.svg"),
		"pitch": 1.0
	},
	{
		"name": "Explosión",
		"sound": preload("res://audio/so.mp3"),
		"pitch": 0.8
	},
	{
		"name": "Laser",
		"sound": preload("res://audio/so.mp3"),
		"pitch": 1.4
	}
]

# ==================================================
# CONFIG VISUAL
# ==================================================

@export var button_height := 80
@export var image_size := Vector2i(64, 64)
@export var separation := 8

# ==================================================
# INTERNOS
# ==================================================

var default_icon: Texture2D
var container: VBoxContainer

func _ready():
	# Icono default de Godot
	default_icon = get_theme_icon("Node", "EditorIcons")

	# Crear contenedor principal
	container = VBoxContainer.new()
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.add_theme_constant_override("separation", separation)

	add_child(container)

	# Crear botones
	_create_buttons()

# ==================================================
# CREAR TODOS LOS BOTONES
# ==================================================

func _create_buttons():
	# Limpiar
	for child in container.get_children():
		child.queue_free()

	# Crear botones ordenados
	for data in buttons_data:
		_create_single_button(data)

# ==================================================
# CREAR UN BOTÓN
# ==================================================

func _create_single_button(data: Dictionary):

	# --------------------------------------
	# Contenedor horizontal
	# --------------------------------------
	var hbox := HBoxContainer.new()
	hbox.custom_minimum_size.y = button_height
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	# --------------------------------------
	# IMAGEN
	# --------------------------------------
	var texture_rect := TextureRect.new()

	texture_rect.custom_minimum_size = image_size
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	# Imagen personalizada o default
	texture_rect.texture = data.get("image", default_icon)

	# --------------------------------------
	# BOTÓN
	# --------------------------------------
	var button := Button.new()

	button.text = data.get("name", "Botón")
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size.y = button_height

	# --------------------------------------
	# AUDIO
	# --------------------------------------
	var player := AudioStreamPlayer.new()

	player.stream = data.get("sound", null)

	# Pitch opcional
	player.pitch_scale = data.get("pitch", 1.0)

	# --------------------------------------
	# EVENTO
	# --------------------------------------
	button.pressed.connect(
		func():
			if player.stream:
				player.play()
	)

	# --------------------------------------
	# ARMAR TODO
	# --------------------------------------
	hbox.add_child(texture_rect)
	hbox.add_child(button)

	button.add_child(player)

	container.add_child(hbox)
