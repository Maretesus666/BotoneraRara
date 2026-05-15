extends Control

const SAVE_PATH := "user://soundboard_save.json"

@export var button_height := 185
@export var image_size := Vector2i(130,130)
@export var card_width_padding := 40

var default_icon

var container
var scroll
var search_bar

var audio_dialog
var image_dialog

var current_player
var selected_data = null
var selected_panel = null

var buttons_data := []

func _ready():

	randomize()

	default_icon = get_theme_icon("Node","EditorIcons")

	_create_background()
	_create_topbar()
	_create_scroll()
	_create_dialogs()

	_load_data()

func _notification(what):

	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_save_data()

func _exit_tree():
	_save_data()

func _create_background():

	var bg := ColorRect.new()

	bg.anchor_right = 1
	bg.anchor_bottom = 1

	bg.color = Color(0.05,0.05,0.06)

	add_child(bg)

	var overlay := ColorRect.new()

	overlay.anchor_right = 1
	overlay.anchor_bottom = 1

	overlay.color = Color(0.08,0.09,0.12,0.96)

	add_child(overlay)

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
	search_bar.custom_minimum_size.y = 48

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

	var add := Button.new()

	add.text = "＋ Audio"

	add.custom_minimum_size.x = 130

	add.pressed.connect(
		func():
			selected_data = null
			audio_dialog.popup_centered_ratio()
	)

	top.add_child(add)

func _create_scroll():

	scroll = ScrollContainer.new()

	scroll.anchor_right = 1
	scroll.anchor_bottom = 1

	scroll.offset_top = 90
	scroll.offset_left = 15
	scroll.offset_right = -15
	scroll.offset_bottom = -15

	add_child(scroll)

	container = VBoxContainer.new()

	container.size_flags_horizontal = SIZE_EXPAND_FILL

	container.add_theme_constant_override("separation",18)

	scroll.add_child(container)

func _create_dialogs():

	audio_dialog = FileDialog.new()

	audio_dialog.access = FileDialog.ACCESS_FILESYSTEM
	audio_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE

	audio_dialog.filters = PackedStringArray([
		"*.mp3 ; MP3",
		"*.wav ; WAV",
		"*.ogg ; OGG"
	])

	audio_dialog.file_selected.connect(_audio_selected)

	add_child(audio_dialog)

	image_dialog = FileDialog.new()

	image_dialog.access = FileDialog.ACCESS_FILESYSTEM
	image_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE

	image_dialog.filters = PackedStringArray([
		"*.png ; PNG",
		"*.jpg ; JPG",
		"*.jpeg ; JPEG",
		"*.webp ; WEBP"
	])

	image_dialog.file_selected.connect(_image_selected)

	add_child(image_dialog)

func _audio_selected(path):

	var stream = load(path)

	if stream == null:
		return

	selected_data = {
		"name": path.get_file().get_basename(),
		"sound_path": path,
		"image_path": "",
		"pitch": 1.0,
		"volume": 0.0,
		"favorite": false,
		"tag": "importado",
		"color": [
			randf_range(0.4,1.0),
			randf_range(0.4,1.0),
			randf_range(0.4,1.0)
		]
	}

	image_dialog.popup_centered_ratio()

func _image_selected(path):

	if selected_data == null:
		return

	selected_data["image_path"] = path

	buttons_data.append(selected_data)

	_create_button(selected_data)

	_save_data()

func _save_data():

	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)

	if file == null:
		return

	file.store_string(JSON.stringify(buttons_data))

	file.close()

func _load_data():

	if !FileAccess.file_exists(SAVE_PATH):
		return

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)

	if file == null:
		return

	var text = file.get_as_text()

	file.close()

	var parsed = JSON.parse_string(text)

	if typeof(parsed) != TYPE_ARRAY:
		return

	buttons_data = parsed

	for data in buttons_data:
		_create_button(data)

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

func _create_button(data):

	var panel := PanelContainer.new()

	panel.custom_minimum_size.y = button_height
	panel.custom_minimum_size.x = size.x - card_width_padding

	panel.size_flags_horizontal = SIZE_EXPAND_FILL

	panel.set_meta("name",data.get("name",""))
	panel.set_meta("tag",data.get("tag",""))

	var color_data = data.get("color",[0.3,0.6,1.0])

	var accent = Color(
		color_data[0],
		color_data[1],
		color_data[2]
	)

	var style := StyleBoxFlat.new()

	style.bg_color = Color(0.12,0.12,0.15)
	style.corner_radius_top_left = 28
	style.corner_radius_top_right = 28
	style.corner_radius_bottom_left = 28
	style.corner_radius_bottom_right = 28

	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2

	style.border_color = accent

	panel.add_theme_stylebox_override("panel",style)

	var margin := MarginContainer.new()

	margin.add_theme_constant_override("margin_left",14)
	margin.add_theme_constant_override("margin_right",14)
	margin.add_theme_constant_override("margin_top",14)
	margin.add_theme_constant_override("margin_bottom",14)

	panel.add_child(margin)

	var hbox := HBoxContainer.new()

	hbox.add_theme_constant_override("separation",18)

	margin.add_child(hbox)

	var image_panel := PanelContainer.new()

	image_panel.custom_minimum_size = Vector2(140,140)

	image_panel.clip_contents = true

	var image_style := StyleBoxFlat.new()

	image_style.bg_color = Color(0.18,0.18,0.2)

	image_style.corner_radius_top_left = 24
	image_style.corner_radius_top_right = 24
	image_style.corner_radius_bottom_left = 24
	image_style.corner_radius_bottom_right = 24

	image_panel.add_theme_stylebox_override("panel",image_style)

	var texture := TextureRect.new()

	var image_path = data.get("image_path","")

	if image_path != "" and ResourceLoader.exists(image_path):
		texture.texture = load(image_path)
	else:
		texture.texture = default_icon

	texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED

	texture.custom_minimum_size = image_size

	texture.anchor_right = 1
	texture.anchor_bottom = 1

	texture.clip_contents = true

	image_panel.add_child(texture)

	hbox.add_child(image_panel)

	var info := VBoxContainer.new()

	info.size_flags_horizontal = SIZE_EXPAND_FILL

	hbox.add_child(info)

	var title := LineEdit.new()

	title.text = data.get("name","")

	title.custom_minimum_size.y = 42

	title.text_changed.connect(
		func(v):
			data["name"] = v
			panel.set_meta("name",v)
			_save_data()
	)

	info.add_child(title)

	var tag := LineEdit.new()

	tag.placeholder_text = "Tag"

	tag.text = data.get("tag","")

	tag.text_changed.connect(
		func(v):
			data["tag"] = v
			panel.set_meta("tag",v)
			_save_data()
	)

	info.add_child(tag)

	var progress := ProgressBar.new()

	progress.show_percentage = false
	progress.max_value = 100

	info.add_child(progress)

	var controls := GridContainer.new()

	controls.columns = 2

	info.add_child(controls)

	var play := Button.new()

	play.text = "▶ Play"

	controls.add_child(play)

	var stop := Button.new()

	stop.text = "⏹ Stop"

	controls.add_child(stop)

	var favorite := Button.new()

	favorite.text = "⭐ Favorite" if data.get("favorite",false) else "☆ Favorite"

	controls.add_child(favorite)

	var change_image := Button.new()

	change_image.text = "🖼 Cambiar"

	controls.add_child(change_image)

	var pitch_label := Label.new()

	pitch_label.text = "Pitch %.2f" % data.get("pitch",1.0)

	info.add_child(pitch_label)

	var pitch_slider := HSlider.new()

	pitch_slider.min_value = 0.3
	pitch_slider.max_value = 3.0
	pitch_slider.step = 0.01
	pitch_slider.value = data.get("pitch",1.0)

	info.add_child(pitch_slider)

	var volume_label := Label.new()

	volume_label.text = "Volumen %.1f dB" % data.get("volume",0.0)

	info.add_child(volume_label)

	var volume_slider := HSlider.new()

	volume_slider.min_value = -30
	volume_slider.max_value = 10
	volume_slider.step = 0.1
	volume_slider.value = data.get("volume",0.0)

	info.add_child(volume_slider)

	var player := AudioStreamPlayer.new()

	var sound_path = data.get("sound_path","")

	if ResourceLoader.exists(sound_path):
		player.stream = load(sound_path)

	player.pitch_scale = data.get("pitch",1.0)
	player.volume_db = data.get("volume",0.0)

	add_child(player)

	pitch_slider.value_changed.connect(
		func(v):

			player.pitch_scale = v

			data["pitch"] = v

			pitch_label.text = "Pitch %.2f" % v

			_save_data()
	)

	volume_slider.value_changed.connect(
		func(v):

			player.volume_db = v

			data["volume"] = v

			volume_label.text = "Volumen %.1f dB" % v

			_save_data()
	)

	play.pressed.connect(
		func():

			if current_player and current_player.playing:
				current_player.stop()

			current_player = player
			selected_panel = panel

			player.play()

			scroll.ensure_control_visible(panel)

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
				Color(1.12,1.12,1.12),
				0.08
			)

			tween.tween_property(
				panel,
				"scale",
				Vector2.ONE,
				0.15
			)

			tween.parallel().tween_property(
				panel,
				"modulate",
				Color.WHITE,
				0.15
			)

			var visual := create_tween()

			visual.set_loops()

			visual.tween_property(
				progress,
				"value",
				randi_range(10,100),
				0.1
			)
	)

	stop.pressed.connect(
		func():

			player.stop()

			progress.value = 0
	)

	favorite.pressed.connect(
		func():

			data["favorite"] = !data.get("favorite",false)

			favorite.text = (
				"⭐ Favorite"
				if data["favorite"]
				else "☆ Favorite"
			)

			style.border_color = (
				Color.GOLD
				if data["favorite"]
				else accent
			)

			_save_data()
	)

	change_image.pressed.connect(
		func():

			selected_data = data

			image_dialog.popup_centered_ratio()
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

			if selected_panel == panel and player.playing:
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
