@tool
# DialogicStyleEvent
# Summary: Handles style-related dialog events.
# Details: Provides shortcode parsing, execution, and editor integration for style changes.
class_name DialogicStyleEvent
extends DialogicEvent

## Event that allows changing the currently displayed style.


### Settings

## The name of the style to change to. Can be set on the DialogicNode_Style.
var style_name := ""


################################################################################
## 						EXECUTE
################################################################################

# Summary: Executes the style event logic when the timeline runs.
func _execute() -> void:
	dialogic.Styles.change_style(style_name)
	# we need to wait till the new layout is ready before continuing
	await dialogic.get_tree().process_frame
	finish()


################################################################################
## 						INITIALIZE
################################################################################

# Summary: Initializes default values for the style event.
func _init() -> void:
	event_name = "Change Style"
	set_default_color('Color8')
	event_category = "Visuals"
	event_sorting_index = 1


################################################################################
## 						SAVING/LOADING
################################################################################
# Summary: Returns the shortcode used to represent this event in timelines.
# Returns: String — The event shortcode.
func get_shortcode() -> String:
	return "style"


# Summary: Describes supported shortcode parameters for this event.
# Returns: Dictionary — Parameter specs keyed by name.
func get_shortcode_parameters() -> Dictionary:
	return {
		#param_name : property_info
		"name" 		: {"property": "style_name", "default": "", 'suggestions':get_style_suggestions},
	}


################################################################################
## 						EDITOR REPRESENTATION
################################################################################

# Summary: Builds the inspector/editor UI for configuring this event.
# Summary: TODO — describe build_event_editor.
func build_event_editor() -> void:
	add_header_edit('style_name', ValueType.DYNAMIC_OPTIONS, {
			'left_text'			:'Use style',
			'placeholder'		: 'Default',
			'suggestions_func' 	: get_style_suggestions,
			'editor_icon' 		: ["PopupMenu", "EditorIcons"],
			'autofocus'			: true})


# Summary: Provides a map of style suggestions filtered by text.
# Params:
# - _filter: Optional text to narrow suggestions.
# Returns: Dictionary — Suggestions grouped by category.
func get_style_suggestions(_filter := "") -> Dictionary:
	var styles: Array = ProjectSettings.get_setting('dialogic/layout/style_list', [])

	var suggestions := {}
	suggestions['<Default Style>'] = {'value':'', 'editor_icon':["MenuBar", "EditorIcons"]}
	for i in styles:
		var style: DialogicStyle = load(i)
		suggestions[style.name] = {'value': style.name, 'editor_icon': ["PopupMenu", "EditorIcons"]}
	return suggestions
