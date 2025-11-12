@tool
# DialogicLayoutBase
# Summary: Base node for Dialogic UI layouts.
# Details: Manages layout layers and applies exported override settings across scenes.
class_name DialogicLayoutBase
extends Node

## Base class that should be extended by custom layouts.


## Method that adds a node as a layer
# Summary: Adds a Dialogic layout layer to this layout.
# Params:
# - layer: Layer instance to add.
# Returns: Node — The added layer node.
func add_layer(layer:DialogicLayoutLayer) -> Node:
	add_child(layer)
	return layer


## Method that returns the given child
# Summary: Retrieves a layout layer by index.
# Params:
# - index: Zero-based layer index.
# Returns: Node — The layer node or null.
func get_layer(index:int) -> Node:
	return get_child(index)


## Method to return all the layers
# Summary: Returns all layout layers in order.
# Returns: Array — List of layer nodes.
func get_layers() -> Array:
	var layers := []
	for child in get_children():
		if child is DialogicLayoutLayer:
			layers.append(child)
	return layers


## Method that is called to load the export overrides.
## This happens when the style is first introduced,
## but also when switching to a different style using the same scene!
# Summary: Applies exported override settings to the layout and layers.
func apply_export_overrides() -> void:
	_apply_export_overrides()
	for child in get_children():
		if child.has_method('_apply_export_overrides'):
			child._apply_export_overrides()


## Returns a setting on this base.
## This is useful so that layers can share settings like base_color, etc.
# Summary: Reads a global Dialogic setting with a default fallback.
# Params:
# - setting: The setting key.
# - default: Fallback value if not found.
# Returns: Variant — The resolved value.
func get_global_setting(setting:StringName, default:Variant) -> Variant:
	if setting in self:
		return get(setting)

	if str(setting).to_lower() in self:
		return get(setting.to_lower())

	if 'global_'+str(setting) in self:
		return get('global_'+str(setting))

	return default


## To be overwritten. Apply the settings to your scene here.
# Summary: Hook for subclasses to apply export overrides.
func _apply_export_overrides() -> void:
	pass


#region HANDLE PERSISTENT DATA
################################################################################

# Summary: Initializes the layout base.
func _init() -> void:
	_load_persistent_info(Engine.get_meta("dialogic_persistent_style_info", {}))


# Summary: Cleans up references when the node exits the scene tree.
func _exit_tree() -> void:
	var info: Dictionary = Engine.get_meta("dialogic_persistent_style_info", {})
	info.merge(_get_persistent_info(), true)
	Engine.set_meta("dialogic_persistent_style_info", info)


## To be overwritten. Return any info that a later used style might want to know.
# Summary: Collects persistent state of the layout to be saved.
# Returns: Dictionary — Serializable state.
func _get_persistent_info() -> Dictionary:
	return {}


## To be overwritten. Apply any info that a previous style might have stored and this style should use.
# Summary: Restores persistent state into the layout.
# Params:
# - _info: Previously saved state dictionary.
func _load_persistent_info(_info: Dictionary) -> void:
	pass

#endregion
