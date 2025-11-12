# Class
# Summary: TODO — add brief description.
@tool
extends DialogicIndexer


func _get_events() -> Array:
	return [this_folder.path_join('event_wait.gd')]
