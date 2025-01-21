extends RigidBody2D

var drag_behavior: Global.DragBehavior = Global.DragBehavior.FREEZE_AND_REPOSITION
var drag_pos_start: Vector2
var drag_touch_start: Vector2
var drag_touch_last: Vector2
var dragging: bool                     = false
var dragging_force_factor: float   = 10 # How much force is applied when dragging

@onready var collision_polygon = $CollisionPolygon2D # Cache the reference


func _ready() -> void:
	if not collision_polygon:
		push_error("CollisionPolygon2D node is missing!")
		return


func _input(event) -> void:
	if not collision_polygon:
		return # Prevent errors if the node is missing

	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if event.is_pressed(): # Touch or mouse press
			var touch_pos: Vector2 = event.position
			if Geometry2D.is_point_in_polygon(to_local(touch_pos), collision_polygon.polygon):
				_drag_start(touch_pos)
		else: # Release
			_drag_stop()

	elif event is InputEventScreenDrag or event is InputEventMouseMotion:
		if dragging:
			_drag(event.position)


func _drag_start(touch_pos: Vector2):
	drag_behavior = Global.get_drag_behavior()
	dragging = true
	drag_touch_start = touch_pos
	drag_touch_last = touch_pos
	drag_pos_start = position
	match drag_behavior:
		Global.DragBehavior.FREEZE_AND_REPOSITION:
			freeze = true
			lock_rotation = true
			
			
func _drag_stop():
	dragging = false
	freeze = false
	lock_rotation = false


func _drag(touch_pos: Vector2):
	match drag_behavior:
		Global.DragBehavior.FREEZE_AND_REPOSITION:
			var touch_offset_since_start: Vector2 = touch_pos - drag_touch_start
			position = drag_pos_start + touch_offset_since_start
		Global.DragBehavior.APPLY_DAMPENED_FORCE:
			var touch_offset_since_last: Vector2 = touch_pos - drag_touch_last
			var force: Vector2 = touch_offset_since_last * dragging_force_factor
			apply_central_impulse(force)
	drag_touch_last = touch_pos
