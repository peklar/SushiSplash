extends Node2D

@export var waterResolution:float = 6
@export var waterWidth:int = 1920
@export var waterDepth:int = 500

var waterPoints:Array = []

var dampening = 0.03

func _ready() -> void:
	if waterResolution <2:
		waterResolution = 2
	var waterDetectionSize:Vector2 = Vector2(waterWidth/waterResolution*1.2,50)
	for x in range(waterResolution):
		var inst = load("res://WaterSim/waterPoint.tscn").instantiate()
		inst.position = Vector2(waterWidth/(waterResolution-1)*x,0)
		print(inst.position)
		waterPoints.append(inst)
		inst.setup_area_size(waterDetectionSize)
		#if x==15:
			#inst.velocity = 800
			#inst.targetHeight = inst.position.y+80
		$PointsContainer.add_child(inst)
		pass
	pass


func _physics_process(delta: float) -> void:
	var indx = 0
	for point in waterPoints:
		point.update_water(delta)
		pass
	indx = 0
	for point in waterPoints:
		var neigh = return_water_point_neighbours(indx)
		point.check_neighbours(neigh[0],neigh[1])
		indx+=1
		pass
	for point in waterPoints:
		point.apply_neighbour_vel()
		pass
	update_polygon()
	pass

func return_water_point_neighbours(indx)->Array:
	var l = []
	var r = []
	if indx!=0:
		l.append(waterPoints[indx-1])
	if indx+1<waterPoints.size():
		l.append(waterPoints[indx+1])
	return [l,r]

func update_polygon():
	var points:PackedVector2Array = []
	for point in waterPoints:
		points.append(point.position)
		pass
	$Line2D.points = points.duplicate()
	points.append(Vector2(waterWidth,waterDepth))
	points.append(Vector2(0,waterDepth))
	$Polygon2D.polygon = points
	pass
