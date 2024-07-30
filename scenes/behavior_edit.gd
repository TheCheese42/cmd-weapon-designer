extends CanvasLayer


var content_box: VBoxContainer

var header: String
var type: String
var data: Dictionary
var values: Dictionary
var callback: Callable


func init(header_: String, type_: String, data_: Dictionary, values_: Dictionary, callback_: Callable) -> void:
	header = header_
	type = type_
	data = data_
	values = values_
	callback = callback_


func _ready() -> void:
	content_box = find_child("ContentBox")
	find_child("Header").text = header
	find_child("TypeLabel").text = "Type: " + type
	_rebuild_content(content_box, data, values)


func _rebuild_content(content_box_: VBoxContainer, data_: Dictionary, values_: Dictionary) -> void:
	for child in content_box_.get_children():
		child.queue_free()

	for attr: String in data_.keys():
		var strtype = data_[attr]
		var label = Label.new()
		label.text = attr.replace("_", " ").capitalize() + ": "
		var conf: Control
		match strtype:
			"filepath":
				conf = HBoxContainer.new()
				var input = LineEdit.new()
				input.placeholder_text = "Enter Filepath"
				if values_.get(attr) != null:
					input.text = values_.get(attr)
				input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				var btn = Button.new()
				btn.text = "Select file"
				btn.pressed.connect(
					func():
						var dialog = _create_filedialog(FileDialog.FILE_MODE_OPEN_FILE)
						dialog.file_selected.connect(
							func(file: String):
								input.text = file
						)
						dialog.show()
				)
				conf.add_child(input)
				conf.add_child(btn)
			"filepaths":
				conf = HBoxContainer.new()
				var input = LineEdit.new()
				input.placeholder_text = "Enter Filepaths"
				if values_.get(attr) != null:
					input.text = ":".join(values_.get(attr))
				input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				var btn = Button.new()
				btn.text = "Select files"
				btn.pressed.connect(
					func():
						var dialog = _create_filedialog(FileDialog.FILE_MODE_OPEN_FILES)
						dialog.files_selected.connect(
							func(files: Array[String]):
								input.text = ":".join(files)
						)
						dialog.show()
				)
				conf.add_child(input)
				conf.add_child(btn)
			"int":
				conf = LineEdit.new()
				conf.placeholder_text = "Enter an integer number"
				if values_.get(attr) != null:
					conf.text = str(values_.get(attr))
				conf.text_changed.connect(
					func(new: String):
						var modified = ""
						for char_ in new:
							if char_ in ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]:
								modified += char_
						conf.text = modified
						conf.caret_column = 99999
				)
			"float":
				conf = LineEdit.new()
				conf.placeholder_text = "Enter a decimal number"
				if values_.get(attr) != null:
					conf.text = str(values_.get(attr))
				conf.text_changed.connect(
					func(new: String):
						var modified = ""
						var had_period := false
						for char_ in new:
							if char_ in ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "."]:
								if char_ == ".":
									if had_period:
										continue
								modified += char_
						conf.text = modified
						conf.caret_column = 99999
				)
			"str":
				conf = LineEdit.new()
				conf.placeholder_text = "Enter text"
				if values_.get(attr) != null:
					conf.text = values_.get(attr)
			_:
				if typeof(strtype) == TYPE_DICTIONARY:
					conf = MarginContainer.new()
					conf.add_theme_constant_override("margin_left", 20)
					var vbox = VBoxContainer.new()
					vbox.add_theme_constant_override("separation", 10)
					conf.add_child(vbox)
					_rebuild_content(vbox, strtype, values_.get(attr, {}))
				else:print(strtype)

		conf.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var box = HBoxContainer.new()
		box.add_child(label)
		box.add_child(conf)
		if typeof(strtype) == TYPE_DICTIONARY:
			content_box_.add_child(HSeparator.new())
		content_box_.add_child(box)
		if typeof(strtype) == TYPE_DICTIONARY:
			content_box_.add_child(HSeparator.new())


func _create_filedialog(file_mode: FileDialog.FileMode) -> FileDialog:
	var dialog := FileDialog.new()
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	dialog.file_mode = file_mode
	dialog.use_native_dialog = true
	if file_mode == FileDialog.FILE_MODE_OPEN_FILE:
		dialog.title = "Select a file"
	elif file_mode == FileDialog.FILE_MODE_OPEN_DIR:
		dialog.title = "Select a directory"
	else:
		dialog.title = "Select files"
	return dialog


func _collect_values(vbox: VBoxContainer, data_: Dictionary) -> Dictionary:
	var values_ = {}
	var idx := 0
	for key in data_.keys():
		var value
		var strtype = data_[key]
		var hbox = vbox.get_child(idx)
		while is_instance_of(hbox, HSeparator):
			idx += 1
			hbox = vbox.get_child(idx)
		if strtype in ["filepath", "filepaths"]:
			value = hbox.get_child(1).get_child(0).text if hbox.get_child(1).get_child(0).text else null
			if strtype == "filepaths" and value != null:
				value = value.split(":", false)
				var nvalue = []
				for p in value:
					nvalue.append("/".join(p.rsplit("/", false, 2).slice(-2)))
				value = nvalue
			elif value:
				value = "/".join(value.rsplit("/", false, 2).slice(-2))
		elif strtype in ["int", "float", "str"]:
			value = hbox.get_child(1).text if hbox.get_child(1).text else null
			if strtype == "int" and value != null:
				value = int(value)
			elif strtype == "float" and value != null:
				value = float(value)
		elif typeof(strtype) == TYPE_DICTIONARY:
			value = _collect_values(hbox.get_child(1).get_child(0), strtype)
		values_[key] = value
		idx += 1

	return values_


func _on_done_button_pressed() -> void:
	callback.call(_collect_values(content_box, data))
	queue_free()
