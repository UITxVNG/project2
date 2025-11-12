# Class
# Summary: TODO — add brief description.
@tool
extends PanelContainer

## Event block field part for the Dictionary field.

signal value_changed()


# Summary: TODO — describe set_key.


func set_key(value:String) -> void:
	%Key.text = str(value)


# Summary: TODO — describe get_key.


func get_key() -> String:
	return %Key.text


# Summary: TODO — describe set_value.


func set_value(value:Variant) -> void:
	%FlexValue.set_value(value)


# Summary: TODO — describe get_value.


func get_value() -> Variant:
	return %FlexValue.current_value


func _ready() -> void:
	%Delete.icon = get_theme_icon("Remove", "EditorIcons")


# Summary: TODO — describe focus_key.


func focus_key() -> void:
	%Key.grab_focus()


func _on_key_text_changed(new_text: String) -> void:
	value_changed.emit()


func _on_flex_value_value_changed() -> void:
	value_changed.emit()


func _on_delete_pressed() -> void:
	queue_free()
	value_changed.emit()
