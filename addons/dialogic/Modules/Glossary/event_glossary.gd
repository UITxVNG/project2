# DialogicGlossaryEvent
# Summary: TODO — add brief description.
@tool
class_name DialogicGlossaryEvent
extends DialogicEvent

## Event that does nothing right now.


################################################################################
## 						EXECUTE
################################################################################

func _execute() -> void:
	pass


################################################################################
## 						INITIALIZE
################################################################################

func _init() -> void:
	event_name = "Glossary"
	set_default_color('Color6')
	event_category = "Other"
	event_sorting_index = 0


################################################################################
## 						SAVING/LOADING
################################################################################
func get_shortcode() -> String:
	return "glossary"

# Summary: TODO — describe get_shortcode_parameters.

func get_shortcode_parameters() -> Dictionary:
	return {
	}

################################################################################
## 						EDITOR REPRESENTATION
################################################################################

func build_event_editor() -> void:
	pass
