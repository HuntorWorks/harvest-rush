extends Node2D

# Class to represent a debug line in 3D space
class Line3D:
	var Start
	var End
	var LineColor
	var time

	func _init(_start, _end, _color, _time):
		Start = _start
		End = _end
		LineColor = _color
		time = _time

# Renamed to avoid conflict with native Line2D
class DebugLine2D:
	var Start
	var End
	var LineColor
	var time

	func _init(_start, _end, _color, _time):
		Start = _start
		End = _end
		LineColor = _color
		time = _time

# List of 3D debug lines
var Lines3D = []

# List of 2D debug lines (screen-space)
var Lines2D = []

# Used to track whether we removed any line this frame
var RemovedLine = false

func _process(delta):
	for i in range(Lines3D.size()):
		Lines3D[i].time -= delta

	for i in range(Lines2D.size()):
		Lines2D[i].time -= delta

	if Lines3D.size() > 0 or Lines2D.size() > 0 or RemovedLine:
		queue_redraw()
		RemovedLine = false

func _draw():
	var Cam = get_viewport().get_camera_3d()

	if Cam:
		for i in range(Lines3D.size()):
			var start = Lines3D[i].Start
			var end = Lines3D[i].End

			if Cam.is_position_behind(start) or Cam.is_position_behind(end):
				continue

			var screen_start = Cam.unproject_position(start)
			var screen_end = Cam.unproject_position(end)
			draw_line(screen_start, screen_end, Lines3D[i].LineColor)

	# Remove expired 3D lines
	var i = Lines3D.size() - 1
	while i >= 0:
		if Lines3D[i].time < 0.0:
			Lines3D.remove_at(i)
			RemovedLine = true
		i -= 1

	# Draw 2D lines directly
	for j in range(Lines2D.size()):
		draw_line(Lines2D[j].Start, Lines2D[j].End, Lines2D[j].LineColor)

	# Remove expired 2D lines
	var j = Lines2D.size() - 1
	while j >= 0:
		if Lines2D[j].time < 0.0:
			Lines2D.remove_at(j)
			RemovedLine = true
		j -= 1

# === 3D Debug Line Drawing ===

func DrawLine(Start: Vector3, End: Vector3, LineColor: Color, time := 0.0):
	Lines3D.append(Line3D.new(Start, End, LineColor, time))

func DrawRay(Start: Vector3, Ray: Vector3, LineColor: Color, time := 0.0):
	Lines3D.append(Line3D.new(Start, Start + Ray, LineColor, time))

func DrawCube(Center: Vector3, HalfExtents: float, LineColor: Color, time := 0.0):
	var LinePointStart = Center - Vector3(HalfExtents, -HalfExtents, HalfExtents)
	var LinePointEnd = LinePointStart + Vector3(0, 0, HalfExtents * 2.0)
	DrawLine(LinePointStart, LinePointEnd, LineColor, time)
	LinePointStart = LinePointEnd
	LinePointEnd += Vector3(HalfExtents * 2.0, 0, 0)
	DrawLine(LinePointStart, LinePointEnd, LineColor, time)
	LinePointStart = LinePointEnd
	LinePointEnd += Vector3(0, 0, -HalfExtents * 2.0)
	DrawLine(LinePointStart, LinePointEnd, LineColor, time)
	LinePointStart = LinePointEnd
	LinePointEnd += Vector3(-HalfExtents * 2.0, 0, 0)
	DrawLine(LinePointStart, LinePointEnd, LineColor, time)

	LinePointStart = LinePointEnd + Vector3(0, -HalfExtents * 2.0, 0)
	LinePointEnd = LinePointStart + Vector3(0, 0, HalfExtents * 2.0)
	DrawLine(LinePointStart, LinePointEnd, LineColor, time)
	LinePointStart = LinePointEnd
	LinePointEnd += Vector3(HalfExtents * 2.0, 0, 0)
	DrawLine(LinePointStart, LinePointEnd, LineColor, time)
	LinePointStart = LinePointEnd
	LinePointEnd += Vector3(0, 0, -HalfExtents * 2.0)
	DrawLine(LinePointStart, LinePointEnd, LineColor, time)
	LinePointStart = LinePointEnd
	LinePointEnd += Vector3(-HalfExtents * 2.0, 0, 0)
	DrawLine(LinePointStart, LinePointEnd, LineColor, time)

	LinePointStart = LinePointEnd
	DrawRay(LinePointStart, Vector3(0, HalfExtents * 2.0, 0), LineColor, time)
	LinePointStart += Vector3(0, 0, HalfExtents * 2.0)
	DrawRay(LinePointStart, Vector3(0, HalfExtents * 2.0, 0), LineColor, time)
	LinePointStart += Vector3(HalfExtents * 2.0, 0, 0)
	DrawRay(LinePointStart, Vector3(0, HalfExtents * 2.0, 0), LineColor, time)
	LinePointStart += Vector3(0, 0, -HalfExtents * 2.0)
	DrawRay(LinePointStart, Vector3(0, HalfExtents * 2.0, 0), LineColor, time)

func DrawCircle(Center: Vector3, Radius: float, LineColor: Color, num_segments := 32, time := 0.0):
	var angle_step = 2 * PI / num_segments
	var points = []
	for i in range(num_segments):
		var angle = i * angle_step
		points.append(Vector3(
			Center.x + Radius * cos(angle),
			Center.y,
			Center.z + Radius * sin(angle)
		))
	for i in range(num_segments):
		DrawLine(points[i], points[(i + 1) % num_segments], LineColor, time)

# === 2D Debug Line Drawing ===

func DrawLine2D(Start: Vector2, End: Vector2, LineColor: Color, time := 0.0):
	Lines2D.append(DebugLine2D.new(Start, End, LineColor, time))

func DrawCircle2D(Center: Vector2, Radius: float, LineColor: Color, num_segments := 32, time := 0.0):
	var angle_step = 2 * PI / num_segments
	var points = []
	for i in range(num_segments):
		var angle = i * angle_step
		points.append(Vector2(
			Center.x + Radius * cos(angle),
			Center.y + Radius * sin(angle)
		))
	for i in range(num_segments):
		DrawLine2D(points[i], points[(i + 1) % num_segments], LineColor, time)

func DrawBox2D(TopLeft: Vector2, Size: Vector2, LineColor: Color, time := 0.0):
	var p1 = TopLeft
	var p2 = TopLeft + Vector2(Size.x, 0)
	var p3 = TopLeft + Size
	var p4 = TopLeft + Vector2(0, Size.y)
	DrawLine2D(p1, p2, LineColor, time)
	DrawLine2D(p2, p3, LineColor, time)
	DrawLine2D(p3, p4, LineColor, time)
	DrawLine2D(p4, p1, LineColor, time)
