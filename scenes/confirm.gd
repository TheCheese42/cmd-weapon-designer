extends CanvasLayer


var containing_dir: String


func init(containing_dir_: String) -> void:
	containing_dir = containing_dir_


func _on_confirm_okay_pressed() -> void:
	queue_free()


func _on_confirm_show_pressed() -> void:
	OS.shell_open(containing_dir)
