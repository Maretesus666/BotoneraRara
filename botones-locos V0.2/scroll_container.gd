# SoundButtonList.gd
# Godot 4.5.1
# UI visual mejorada con:
# - Fondo
# - Tarjetas modernas
# - Hover
# - Colores
# - Bordes redondeados
# - Imagen default
# - Scroll
# - Pitch individual
# - Fácil de expandir

extends Control

# ==================================================
# LISTA DE SONIDOS
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

@export var button_height := 90
@export var image_size := Vector2i(70, 70)
@export var separation := 12
@export var corner_radius := 18

# ==================================================
# INTERNOS
# ==================================================

var default_icon: Texture2D
var background_texture: Texture2D

var scroll: ScrollContainer
var container: VBoxContainer

# ==================================================
# READY
# ==================================================

func _ready():

	# --------------------------------------
	# ICONOS DEFAULT
	# --------------------------------------

	default_icon = get_theme_icon("Node", "EditorIcons")
	background_texture = get_theme_icon("GuiTabMenuHl", "EditorIcons")

	# --------------------------------------
	# FONDO
	# --------------------------------------

	var bg := TextureRect.new()
	bg.texture = background_texture
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_SCALE
	bg.anchor_right = 1.0
	bg.anchor_bottom = 1.0
	bg.modulate = Color(0.15, 0.15, 0.18, 1.0)

	add_child(bg)

	# Oscurecer fondo
	var dark_overlay := ColorRect.new()
	dark_overlay.color = Color(0, 0, 0, 0.45)
	dark_overlay.anchor_right = 1.0
	dark_overlay.anchor_bottom = 1.0

	add_child(dark_overlay)

	# --------------------------------------
	# SCROLL
	# --------------------------------------

	scroll = ScrollContainer.new()
	scroll.anchor_right = 1.0
	scroll.anchor_bottom = 1.0
	scroll.offset_left = 20
	scroll.offset_top = 20
	scroll.offset_right = -20
	scroll.offset_bottom = -20

	add_child(scroll)

	# --------------------------------------
	# CONTENEDOR
	# --------------------------------------

	container = VBoxContainer.new()
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.add_theme_constant_override("separation", separation)

	scroll.add_child(container)

	# --------------------------------------
	# CREAR BOTONES
	# --------------------------------------

	_create_buttons()

# ==================================================
# CREAR TODOS
# ==================================================

func _create_buttons():

	for child in container.get_children():
		child.queue_free()

	for data in buttons_data:
		_create_single_button(data)

# ==================================================
# CREAR UNO
# ==================================================

func _create_single_button(data: Dictionary):

	# --------------------------------------
	# TARJETA
	# --------------------------------------

	var panel := PanelContainer.new()
	panel.custom_minimum_size.y = button_height
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var panel_style := StyleBoxFlat.new()

	panel_style.bg_color = Color(0.12, 0.12, 0.15, 0.92)
	panel_style.corner_radius_top_left = corner_radius
	panel_style.corner_radius_top_right = corner_radius
	panel_style.corner_radius_bottom_left = corner_radius
	panel_style.corner_radius_bottom_right = corner_radius

	panel_style.border_width_left = 2
	panel_style.border_width_top = 2
	panel_style.border_width_right = 2
	panel_style.border_width_bottom = 2

	panel_style.border_color = Color(0.3, 0.5, 1.0, 0.4)

	panel.add_theme_stylebox_override("panel", panel_style)

	# --------------------------------------
	# HBOX
	# --------------------------------------

	var hbox := HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER

	panel.add_child(hbox)

	# --------------------------------------
	# IMAGEN
	# --------------------------------------

	var image_container := PanelContainer.new()

	var image_style := StyleBoxFlat.new()
	image_style.bg_color = Color(0.18, 0.18, 0.22)
	image_style.corner_radius_top_left = 12
	image_style.corner_radius_top_right = 12
	image_style.corner_radius_bottom_left = 12
	image_style.corner_radius_bottom_right = 12

	image_container.add_theme_stylebox_override("panel", image_style)

	var texture_rect := TextureRect.new()

	texture_rect.texture = data.get("image", default_icon)

	texture_rect.custom_minimum_size = image_size
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	image_container.add_child(texture_rect)

	# --------------------------------------
	# BOTÓN
	# --------------------------------------

	var button := Button.new()

	button.text = "▶  " + data.get("name", "Botón")

	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size.y = button_height

	button.add_theme_font_size_override("font_size", 22)

	var normal_style := StyleBoxFlat.new()
	normal_style.bg_color = Color(0.22, 0.22, 0.28, 0)

	var hover_style := StyleBoxFlat.new()
	hover_style.bg_color = Color(0.3, 0.45, 1.0, 0.12)

	var pressed_style := StyleBoxFlat.new()
	pressed_style.bg_color = Color(0.4, 0.6, 1.0, 0.2)

	button.add_theme_stylebox_override("normal", normal_style)
	button.add_theme_stylebox_override("hover", hover_style)
	button.add_theme_stylebox_override("pressed", pressed_style)

	# --------------------------------------
	# AUDIO
	# --------------------------------------

	var player := AudioStreamPlayer.new()

	player.stream = data.get("sound", null)
	player.pitch_scale = data.get("pitch", 1.0)

	button.add_child(player)

	# --------------------------------------
	# EVENTO
	# --------------------------------------

	button.pressed.connect(
		func():

			# Efecto visual flash
			panel.modulate = Color(1.3, 1.3, 1.3)

			var tween := create_tween()
			tween.tween_property(
				panel,
				"modulate",
				Color(1, 1, 1),
				0.15
			)

			# Sonido
			if player.stream:
				player.play()
	)

	# --------------------------------------
	# ARMAR
	# --------------------------------------

	hbox.add_child(image_container)
	hbox.add_child(button)

	container.add_child(panel)
