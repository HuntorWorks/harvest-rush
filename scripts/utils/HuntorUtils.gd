extends Node
class_name HuntorUtils

# --- Component Retrieval ---

## Finds the first direct child node with the exact built-in Godot class name.
## Example: "CharacterBody3D", "Node3D", "RigidBody3D".
## Only checks direct children (not recursive).
## 
## @param parent Node to search under (must be a live scene node).
## @param component_type Built-in Godot class name as a string.
## @returns First matching child node or null if not found.
static func try_get_component_base(parent: Node, component_type: String) -> Node:
	for child in parent.get_children():
		if child.get_class() == component_type:
			return child
	return null

## Finds the first direct child node with a custom script that defines `get_class_name()` returning a specific value.
## Only works on custom `class_name` scripts or if the script manually defines `get_class_name()`.
##
## @param parent Node to search under.
## @param component_type Custom class name as a string (e.g. "Player").
## @returns First matching child node or null if not found.
static func try_get_child_component_by_script(parent: Node, component_type: String) -> Node:
	for child in parent.get_children():
		if child.has_method("get_class_name") and child.get_class_name() == component_type:
			return child
	return null

## Checks if a node itself (not its children) has a custom script that matches `component_type`.
## The script must define `get_class_name()` or use `class_name` syntax.
##
## @param parent_node Node to check.
## @param component_type Custom class name as a string.
## @returns The node itself if matched, otherwise null.
static func try_get_component_by_script(parent_node: Node, component_type: String) -> Node:
	if (parent_node.has_method("get_class_name") or parent_node.has_method("get_base_class_name")) and parent_node.get_class_name() == component_type:
		return parent_node
	return null

# --- Scene Graph Traversal ---

## Recursively finds the first node of a given built-in class type starting from a node and its children.
##
## @param node Starting node.
## @param type_name Built-in class name (e.g. "Camera2D").
## @returns First matching node or null.
static func find_node_by_type(node: Node, type_name: String) -> Node:
	if node == null:
		push_error("ArgumentNullException: node parameter is null")
		return null
	return find_node_by_type_recursive(node, type_name)

## Helper function for recursive node search by type.
static func find_node_by_type_recursive(node: Node, type_name: String) -> Node:
	if node.get_class() == type_name:
		return node
	for child in node.get_children():
		var result = find_node_by_type_recursive(child, type_name)
		if result != null:
			return result
	return null
	
## Recursively searches all descendants of the provided node for a script with `get_class_name()` that matches the given value.
## Works for dynamically spawned nodes and nested scenes.
##
## @param root_node Node to start search from (typically `get_tree().get_root()`).
## @param class_name The `class_name` string to look for (e.g. "Player").
## @returns The first matching node or null if not found.
static func find_node_by_script_class_name(root_node: Node, target_class_name: String) -> Node:
	if root_node.has_method("get_class_name") and root_node.get_class_name() == target_class_name:
		return root_node

	for child in root_node.get_children():
		var result = find_node_by_script_class_name(child, target_class_name)
		if result != null:
			return result

	return null

## Searches direct children for one with a specific `name`.
##
## @param node Node whose children will be searched.
## @param _name Name of the child to find (What its called in the Heirarchy).
## @returns Matching child node or null.
static func get_child_node_by_name(parent_node: Node, _name: String) -> Node:
	if parent_node == null:
		push_error("ArgumentNullException: node parameter is null")
		return null
	for child in parent_node.get_children():
		if child.name == _name:
			return child
	return null

## Gets a child node using a relative slash-delimited path.
## Safer than `get_node()` — returns null instead of erroring if path fails.
##
## @param node Root node to start from.
## @param path Path like "Enemies/Boss".
## @returns Node at path or null if not found.
static func get_child_by_path(node: Node, path: String) -> Node:
	if node == null:
		push_error("ArgumentNullException: node parameter is null")
		return null
	var path_parts = path.split("/")
	var current_node = node
	for path_part in path_parts:
		current_node = get_child_node_by_name(current_node, path_part)
		if current_node == null:
			return null
	return current_node

## Retrieves a node from the scene using a safe traversal method based on a path.
## Similar to `get_node(path)` but avoids runtime errors.
##
## @param root_node Root node to begin search from.
## @param path Slash-separated node path (e.g. "Main/Player").
## @returns Target node or null if not found.
static func get_node_by_path(root_node: Node, path: String) -> Node:
	if root_node == null:
		push_error("ArgumentNullException: root_node parameter is null")
		return null
	var path_parts = path.split("/")
	var current_node = root_node
	for path_part in path_parts:
		current_node = get_child_node_by_name(current_node, path_part)
		if current_node == null:
			return null
	return current_node

# --- Mouse Input Utilities ---

## Gets the screen-space position of the mouse in the specified viewport.
##
## @param viewport The viewport to query.
## @returns Mouse position in screen coordinates.
static func get_mouse_screen_position(viewport: Viewport) -> Vector2:
	return viewport.get_mouse_position()

# --- 2D Utilities ---

## Calculates the angle in radians between two 2D vectors.
##
## @param vec1 First vector.
## @param vec2 Second vector.
## @returns Angle in radians.
static func get_angle_from_vector2D(vec1: Vector2, vec2: Vector2) -> float:
	return vec1.angle_to(vec2)

## Gets the global world position of the mouse in 2D using a Camera2D.
##
## @param camera The active Camera2D.
## @returns Mouse position in world coordinates.
static func get_mouse_world_position2D(camera: Camera2D) -> Vector2:
	return camera.get_global_mouse_position()

## Gets a normalized direction vector from a point to the 2D mouse position.
##
## @param from_position World-space position to start from.
## @param camera The active Camera2D.
## @returns Normalized direction to mouse.
static func get_dir_to_mouse2D(from_position: Vector2, camera: Camera2D) -> Vector2:
	var mouse_world_position = get_mouse_world_position2D(camera)
	return (mouse_world_position - from_position).normalized()

## Gets a random 2D position just offscreen from the camera’s visible rect.
## Useful for spawning enemies or effects just outside view.
## ----------
## @param viewport The active viewport.
## @param camera The active Camera2D.
## @param buffer Optional buffer offset (default: 100.0).
## @returns A Vector2 outside the camera's view bounds.
## ---------
static func get_offscreen_position_2D(viewport: Viewport, camera: Camera2D, buffer: float = 100.0) -> Vector2:
	if camera == null:
		push_error("HuntorUtils.get_offscreen_position: No Camera2D found in viewport!")
		return Vector2.ZERO
	var cam_pos = camera.global_position
	var half_size = viewport.get_visible_rect().size / 2.0
	var min_x = cam_pos.x - half_size.x
	var max_x = cam_pos.x + half_size.x
	var min_y = cam_pos.y - half_size.y
	var max_y = cam_pos.y + half_size.y

	var outside_x := randi() % 2 == 0
	var spawn_x: float
	var spawn_y: float

	if outside_x:
		spawn_x = min_x - buffer if randi() % 2 == 0 else max_x + buffer
		spawn_y = randf_range(min_y - buffer, max_y + buffer)
	else:
		spawn_y = min_y - buffer if randi() % 2 == 0 else max_y + buffer
		spawn_x = randf_range(min_x - buffer, max_x + buffer)

	return Vector2(spawn_x, spawn_y)

# --- 3D Utilities ---

## Gets the 3D world position of the mouse by raycasting from the camera.
##
## @param viewport The active Viewport.
## @param camera The active Camera3D.
## @returns Position in 3D space or Vector3.ZERO if nothing hit.
static func get_mouse_world_position3D(viewport: Viewport, camera: Camera3D) -> Vector3:
	var mouse_pos = viewport.get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000

	var space_state = camera.get_world_3d().direct_space_state
	var ray_params = PhysicsRayQueryParameters3D.new()
	ray_params.from = from
	ray_params.to = to

	var result = space_state.intersect_ray(ray_params)
	if result.size() > 0 and result.has("position"):
		return result["position"]
	return Vector3.ZERO

## Gets a normalized direction vector from a 3D point to the mouse cursor in world space.
##
## @param from_position Origin point in world space.
## @param camera The active Camera3D.
## @returns Normalized direction to mouse cursor.
static func get_dir_to_mouse3D(from_position: Vector3, camera: Camera3D) -> Vector3:
	var mouse_world_position = get_mouse_world_position3D(camera.get_viewport(), camera)
	return (mouse_world_position - from_position).normalized()

## Performs a raycast from the camera to the mouse cursor and returns collision info.
##
## @param ray_length Maximum distance of the ray.
## @param camera The active Camera3D.
## @returns Dictionary with hit info, or empty if nothing hit.
static func raycast_to_cursor_3D(ray_length: float, camera: Camera3D) -> Dictionary:
	var viewport = camera.get_viewport()
	var mouse_position = get_mouse_screen_position(viewport)
	var origin: Vector3 = camera.project_ray_origin(mouse_position)
	var target: Vector3 = origin + camera.project_ray_normal(mouse_position) * ray_length
	var world_space = camera.get_world_3d().direct_space_state

	var query = PhysicsRayQueryParameters3D.new()
	query.from = origin
	query.to = target

	return world_space.intersect_ray(query)
