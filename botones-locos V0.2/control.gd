extends Control

@export var buttons_data := [
	{
		"name": "Disparo",
		"sound": preload("res://audio/so.mp3"),
		"image": preload("res://imagenes/foto.jpg"),
		"pitch": 1.0,
		"volume": 0.0,
		"favorite": true,
		"tag": "arma",
		"color": Color(0.3,0.6,1.0)
	},
	{
		"name": "Explosión",
		"sound": preload("res://audio/so.mp3"),
		"pitch": 0.8,
		"tag": "boom",
		"color": Color(1.0,0.5,0.3)
	},
	{
		"name": "Laser",
		"sound": preload("res://audio/so.mp3"),
		"pitch": 1.4,
		"tag": "sci-fi",
		"color": Color(0.5,1.0,1.0)
	}
]

@export var button_height := 144
@export var image_size := Vector2i(96,96)

var default_icon
var current_player
var current_panel

var search_bar
var container
var scroll

func _ready():

	randomize()

	default_icon = get_theme_icon("Node","EditorIcons")

	_create_background()
	_create_topbar()
	_create_scroll()

	buttons_data.sort_custom(
		func(a,b):
			return a.get("favorite",false) and !b.get("favorite",false)
	)

	for data in buttons_data:
		_create_button(data)

func _create_background():

	var bg := ColorRect.new()

	bg.anchor_right = 1
	bg.anchor_bottom = 1

	bg.color = Color(0.05,0.05,0.06)

	add_child(bg)

	var gradient := ColorRect.new()

	gradient.anchor_right = 1
	gradient.anchor_bottom = 1

	gradient.color = Color(0.08,0.09,0.12,0.92)

	add_child(gradient)

func _create_topbar():

	var top := HBoxContainer.new()

	top.anchor_right = 1
	top.offset_left = 20
	top.offset_right = -20
	top.offset_top = 20

	top.add_theme_constant_override("separation",10)

	add_child(top)

	search_bar = LineEdit.new()

	search_bar.placeholder_text = "Buscar..."
	search_bar.size_flags_horizontal = SIZE_EXPAND_FILL
	search_bar.custom_minimum_size.y = 42

	search_bar.text_changed.connect(_filter_buttons)

	top.add_child(search_bar)

	var clear := Button.new()

	clear.text = "✖"

	clear.pressed.connect(
		func():
			search_bar.text = ""
			_filter_buttons("")
	)

	top.add_child(clear)

	var stop_all := Button.new()

	stop_all.text = "⏹ Stop"

	stop_all.pressed.connect(_stop_all)

	top.add_child(stop_all)

func _create_scroll():

	scroll = ScrollContainer.new()

	scroll.anchor_right = 1
	scroll.anchor_bottom = 1

	scroll.offset_top = 80
	scroll.offset_left = 20
	scroll.offset_right = -20
	scroll.offset_bottom = -20

	add_child(scroll)

	container = VBoxContainer.new()

	container.add_theme_constant_override("separation",16)

	scroll.add_child(container)

func _filter_buttons(text):

	text = text.strip_edges().to_lower()

	for child in container.get_children():

		var n = child.get_meta("name")
		var t = child.get_meta("tag")

		if text == "":
			child.visible = true
			continue

		child.visible = (
			text in n.to_lower()
			or text in t.to_lower()
		)

func _stop_all():

	if current_player:
		current_player.stop()

func _create_button(data):

	var panel := PanelContainer.new()

	panel.custom_minimum_size.y = button_height
	panel.size_flags_horizontal = SIZE_EXPAND_FILL

	panel.set_meta("name",data.get("name",""))
	panel.set_meta("tag",data.get("tag",""))

	var style := StyleBoxFlat.new()

	style.bg_color = Color(0.12,0.12,0.15,0.98)

	style.corner_radius_top_left = 24
	style.corner_radius_top_right = 24
	style.corner_radius_bottom_left = 24
	style.corner_radius_bottom_right = 24

	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2

	style.border_color = data.get("color",Color.CORNFLOWER_BLUE)

	panel.add_theme_stylebox_override("panel",style)

	var hbox := HBoxContainer.new()

	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation",16)

	panel.add_child(hbox)

	var image_holder := PanelContainer.new()

	image_holder.custom_minimum_size = Vector2(100,100)

	var image_style := StyleBoxFlat.new()

	image_style.corner_radius_top_left = 20
	image_style.corner_radius_top_right = 20
	image_style.corner_radius_bottom_left = 20
	image_style.corner_radius_bottom_right = 20

	image_style.bg_color = Color(0.16,0.16,0.18)

	image_holder.add_theme_stylebox_override("panel",image_style)

	var texture := TextureRect.new()

	texture.texture = data.get("image",default_icon)

	texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED

	texture.custom_minimum_size = image_size

	texture.clip_contents = true

	texture.size_flags_horizontal = SIZE_SHRINK_CENTER
	texture.size_flags_vertical = SIZE_SHRINK_CENTER

	image_holder.clip_contents = true

	image_holder.add_child(texture)

	hbox.add_child(image_holder)

	var info := VBoxContainer.new()

	info.size_flags_horizontal = SIZE_EXPAND_FILL

	hbox.add_child(info)

	var title := Label.new()

	title.text = data.get("name","")

	title.add_theme_font_size_override("font_size",24)

	info.add_child(title)

	var tag := Label.new()

	tag.text = "#" + data.get("tag","audio")

	tag.modulate = data.get("color",Color.CYAN)

	info.add_child(tag)

	var progress := ProgressBar.new()

	progress.show_percentage = false
	progress.max_value = 100
	progress.value = 0

	info.add_child(progress)

	var timer := Label.new()

	timer.text = "00:00"

	info.add_child(timer)

	var controls := HBoxContainer.new()

	info.add_child(controls)

	var play := Button.new()

	play.text = "▶"

	controls.add_child(play)

	var stop := Button.new()

	stop.text = "⏹"

	controls.add_child(stop)

	var favorite := Button.new()

	favorite.text = "⭐" if data.get("favorite",false) else "☆"

	controls.add_child(favorite)

	var pitch_slider := HSlider.new()

	pitch_slider.min_value = 0.3
	pitch_slider.max_value = 3.0
	pitch_slider.step = 0.01
	pitch_slider.value = data.get("pitch",1.0)

	pitch_slider.custom_minimum_size.x = 180
	pitch_slider.size_flags_horizontal = SIZE_EXPAND_FILL

	controls.add_child(pitch_slider)

	var pitch_label := Label.new()

	pitch_label.text = "Pitch %.2f" % pitch_slider.value

	controls.add_child(pitch_label)

	var volume_slider := HSlider.new()

	volume_slider.min_value = -30
	volume_slider.max_value = 10
	volume_slider.value = data.get("volume",0)

	volume_slider.custom_minimum_size.x = 120

	controls.add_child(volume_slider)

	var player := AudioStreamPlayer.new()

	player.stream = data.get("sound",null)

	add_child(player)

	pitch_slider.value_changed.connect(
		func(v):

			player.pitch_scale = v

			pitch_label.text = "Pitch %.2f" % v
	)

	volume_slider.value_changed.connect(
		func(v):
			player.volume_db = v
	)

	play.pressed.connect(
		func():

			if current_player and current_player.playing:
				current_player.stop()

			current_player = player
			current_panel = panel

			player.pitch_scale = pitch_slider.value

			player.play()

			scroll.ensure_control_visible(panel)

			panel.pivot_offset = panel.size / 2.0

			var tween := create_tween()

			tween.parallel().tween_property(
				panel,
				"scale",
				Vector2(1.015,1.015),
				0.08
			)

			tween.parallel().tween_property(
				panel,
				"modulate",
				Color(1.15,1.15,1.15),
				0.08
			)

			tween.tween_property(
				panel,
				"scale",
				Vector2.ONE,
				0.12
			)

			tween.parallel().tween_property(
				panel,
				"modulate",
				Color.WHITE,
				0.12
			)

			var visual := create_tween()

			visual.set_loops()

			visual.tween_property(
				progress,
				"value",
				randi_range(15,100),
				0.1
			)

			if player.stream:
				var length = player.stream.get_length()

				var time_tween := create_tween()

				time_tween.set_loops()

				time_tween.tween_callback(
					func():

						if player.playing:

							var pos = player.get_playback_position()

							timer.text = "%02d:%02d" % [
								int(pos / 60),
								int(pos) % 60
							]

							progress.value = (pos / length) * 100.0
				).set_delay(0.05)
	)

	stop.pressed.connect(
		func():

			player.stop()

			progress.value = 0

			timer.text = "00:00"
	)

	favorite.pressed.connect(
		func():

			data["favorite"] = !data.get("favorite",false)

			favorite.text = "⭐" if data["favorite"] else "☆"

			if data["favorite"]:
				style.border_color = Color.GOLD
			else:
				style.border_color = data.get(
					"color",
					Color.CORNFLOWER_BLUE
				)
	)

	panel.mouse_entered.connect(
		func():

			var tween := create_tween()

			tween.parallel().tween_property(
				panel,
				"scale",
				Vector2(1.01,1.01),
				0.08
			)

			tween.parallel().tween_property(
				panel,
				"modulate",
				Color(1.05,1.05,1.05),
				0.08
			)
	)

	panel.mouse_exited.connect(
		func():

			if current_panel == panel and player.playing:
				return

			var tween := create_tween()

			tween.parallel().tween_property(
				panel,
				"scale",
				Vector2.ONE,
				0.08
			)

			tween.parallel().tween_property(
				panel,
				"modulate",
				Color.WHITE,
				0.08
			)
	)

	container.add_child(panel)
