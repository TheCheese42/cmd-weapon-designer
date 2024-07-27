extends CanvasLayer


var action_behavior_menu: PopupMenu
var texture_behavior_menu: PopupMenu
var rarity_menu: PopupMenu
var category_menu: PopupMenu

var rarity = null
var category = null
var action_type = null
var texture_type = null

var rarity_map: Dictionary
var category_map: Dictionary
var action_type_map: Dictionary
var texture_type_map: Dictionary

var plugin_dir = null

var rarities: Array[String]
var categories: Array[String]
var action_behaviors: Dictionary
var texture_behaviors: Dictionary
# Dictionary[
#   String (name, e.g. "gun"): Dictionary[
#     String (attr, e.g. "damage"): String (type, e.g. "int")
#   ]
# ]


func _init() -> void:
	var save: Resource = load("user://save.tres")
	if save != null:
		plugin_dir = save.plugin_dir
	if plugin_dir:
		_set_plugin_dir(plugin_dir)


func _set_plugin_dir(dir: String) -> void:
	var save = Save.new()
	save.plugin_dir = dir
	ResourceSaver.save(save, "user://save.tres")
	plugin_dir = dir
	find_child("PluginDirButton").text = "Plugins: " + plugin_dir
	_init_plugin_dir()
	_parse_plugin_dir()
	var i := 0
	for rarity_ in rarities:
		rarity_map[rarity_] = i
		i += 1
	i = 0
	for category_ in categories:
		category_map[category_] = i
		i += 1
	i = 0
	for action_behavior in action_behaviors.keys():
		action_type_map[action_behavior] = i
		i += 1
	i = 0
	for texture_behavior in texture_behaviors.keys():
		texture_type_map[texture_behavior] = i
		i += 1

	rarity_menu.clear()
	for label in rarity_map.keys():
		var id = rarity_map[label]
		rarity_menu.add_item(label, id)
	category_menu.clear()
	for label in category_map.keys():
		var id = category_map[label]
		category_menu.add_item(label, id)
	action_behavior_menu.clear()
	for label in action_type_map.keys():
		var id = action_type_map[label]
		action_behavior_menu.add_item(label, id)
	texture_behavior_menu.clear()
	for label in texture_type_map.keys():
		var id = texture_type_map[label]
		texture_behavior_menu.add_item(label, id)


func _init_plugin_dir() -> void:
	if DirAccess.open(plugin_dir).get_files() or DirAccess.open(plugin_dir).get_directories():
		return  # Not empty

	DirAccess.make_dir_absolute(plugin_dir.rstrip("/") + "/action_behaviors")
	DirAccess.make_dir_absolute(plugin_dir.rstrip("/") + "/texture_behaviors")
	var rarities_ := FileAccess.open(plugin_dir.rstrip("/") + "/rarities.json", FileAccess.WRITE)
	rarities_.store_string('["common", "rare", "epic", "legendary"]\n')
	var categories_ := FileAccess.open(plugin_dir.rstrip("/") + "/categories.json", FileAccess.WRITE)
	categories_.store_string('["gun", "rifle", "shotgun", "melee", "bow", "special"]\n')
	var gun_behavior := FileAccess.open(plugin_dir.rstrip("/") + "/action_behaviors/gun.json", FileAccess.WRITE)
	gun_behavior.store_string('{\n  "projectile_texture": "path",\n  "damage": "int",\n  "cooldown": "float",\n  "energy": "int",\n  "crit_rate": "float",\n  "penetration": "int",\n  "speed": "int",\n  "inaccuracy": "int"\n}\n')
	var regular_behavior := FileAccess.open(plugin_dir.rstrip("/") + "/texture_behaviors/regular.json", FileAccess.WRITE)
	regular_behavior.store_string('{\n  "idle": {\n    "textures": ["path"],\n    "frame_rate": "int"\n  },\n  "shoot": {\n    "textures": ["path"],\n    "frame_rate": "int"\n  }\n}\n')


func _ready() -> void:
	action_behavior_menu = find_child("ActionBehaviorTypeMenu").get_popup()
	texture_behavior_menu = find_child("TextureBehaviorTypeMenu").get_popup()
	rarity_menu = find_child("RarityMenu").get_popup()
	category_menu = find_child("CategoryMenu").get_popup()

	action_behavior_menu.id_pressed.connect(_on_action_type_item_pressed)
	texture_behavior_menu.id_pressed.connect(_on_texture_type_item_pressed)
	rarity_menu.id_pressed.connect(_on_rarity_item_pressed)
	category_menu.id_pressed.connect(_on_category_item_pressed)

func _parse_plugin_dir() -> void:
	var dir = plugin_dir.rstrip("/")
	rarities = JSON.parse_string(FileAccess.open(dir + "/rarities.json", FileAccess.READ).get_as_text())
	categories = JSON.parse_string(FileAccess.open(dir + "/categories.json", FileAccess.READ).get_as_text())
	for file in DirAccess.get_files_at(dir + "/action_behaviors"):
		var name_ = file.split("/")[-1].split(".")[0]
		var json = JSON.parse_string(FileAccess.open(file, FileAccess.READ).get_as_text())
		action_behaviors[name_] = json
	for file in DirAccess.get_files_at(dir + "/texture_behaviors"):
		var name_ = file.split("/")[-1].split(".")[0]
		var json = JSON.parse_string(FileAccess.open(file, FileAccess.READ).get_as_text())
		texture_behaviors[name_] = json


func _process(_delta: float) -> void:
	if not action_type:
		find_child("EditActionBehaviorButton").disabled = true
	else:
		find_child("EditActionBehaviorButton").disabled = false
	if not texture_type:
		find_child("EditTextureBehaviorButton").disabled = true
	else:
		find_child("EditTextureBehaviorButton").disabled = false


func _on_action_type_item_pressed(id: int) -> void:
	action_type = id


func _on_texture_type_item_pressed(id: int) -> void:
	texture_type = id


func _on_rarity_item_pressed(id: int) -> void:
	rarity = id


func _on_category_item_pressed(id: int) -> void:
	category = id


func _on_edit_action_behavior_button_pressed() -> void:
	if action_type == null:
		return


func _on_edit_texture_behavior_button_pressed() -> void:
	if texture_type == null:
		return