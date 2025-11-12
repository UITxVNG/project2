# Class
# Summary: TODO — add brief description.
@tool
extends DialogicIndexer


func _get_layout_parts() -> Array[Dictionary]:
	return scan_for_layout_parts()
