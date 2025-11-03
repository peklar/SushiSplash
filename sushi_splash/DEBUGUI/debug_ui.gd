extends CanvasLayer

var packetLine2DJumpValue:int = -35
var packetLine2DLeapValue = 5*2
var numberOfLine2Dpackets = 120/2

@export var turnedOn:bool = true
@export var trackPacket:bool = true
@export var trackPosx:bool = true
@export var trackPosy:bool = true



func _ready() -> void:
	
	if !turnedOn:
		queue_free()
		pass
	
	var p:PackedVector2Array = []
	lastPacketMsgTime = Time.get_ticks_msec()
	
	for n in numberOfLine2Dpackets:
		p.append(Vector2(n*packetLine2DLeapValue,28))
	
	$MainPanel/VBoxContainer/packet/Line2D.points = p
	$MainPanel/VBoxContainer/posx/Line2D.points = p
	$MainPanel/VBoxContainer/posy/Line2D.points = p
	
	if !trackPacket:
		$MainPanel/VBoxContainer/packet.visible = false
	if !trackPosx:
		$MainPanel/VBoxContainer/posx.visible = false
	if !trackPosy:
		$MainPanel/VBoxContainer/posy.visible = false
	
	pass


func _process(delta: float) -> void:
	if trackPacket:
		update_packet_panel()
	if trackPosx:
		update_posx_panel()
	if trackPosy:
		update_posy_panel()
	pass

var posXReceived:bool = false
var posYReceived:bool = false
var packetReceived:bool = false

var latestPacketValue:Vector2 = Vector2(0,0)
var latestPosxValue:float = 0
var latestPosyValue:float = 0


var lastPacketMsgTime:float = 0

var discardedPackets:Array = []
var allPackets:Array = []

func packet_recieved(address: Variant, value: Variant, time: Variant):
	if address == "/packet":
		packetReceived = true
		latestPacketValue = Vector2(value[0],value[1])
		pass
	elif address == "/posx":
		posXReceived = true
		latestPosxValue = value
	elif address == "/posy":
		posYReceived = true
		latestPosyValue = value
	else:
		discardedPackets.append(str("\n",address," value: ",value," time: ",time))
		if discardedPackets.size()>19:
			discardedPackets.remove_at(0)
		$DiscardedValuesList/RichTextLabel.text = "[font_size=25]Discarded values:"
		for p in discardedPackets:
			$DiscardedValuesList/RichTextLabel.text+=p
		pass
	
	allPackets.append(str("\n",address," value: ",value," time: ",time))
	if allPackets.size()>30:
		allPackets.remove_at(0)
	$AllValues/RichTextLabel.text = "[font_size=25]Discarded values:"
	for p in allPackets:
		$AllValues/RichTextLabel.text+=p
	pass

func update_packet_panel():
	var packetPoints:PackedVector2Array = $MainPanel/VBoxContainer/packet/Line2D.points
	
	for indx in numberOfLine2Dpackets:
		packetPoints[indx].x = packetPoints[indx].x-packetLine2DLeapValue
		indx+=1
	#print(packetPoints)
	packetPoints.remove_at(0)
	if packetReceived:
		packetReceived = false
		#print("packet got")
		packetPoints.append(Vector2((numberOfLine2Dpackets-1)*packetLine2DLeapValue,28+packetLine2DJumpValue))
		$MainPanel/VBoxContainer/packet/TimeBetweenPackets.text = str("TimeBetweenPackets:\n[left]",Time.get_ticks_msec()-lastPacketMsgTime," ms")
		lastPacketMsgTime = Time.get_ticks_msec()
		$MainPanel/VBoxContainer/packet/PacketValue.text = str("[font_size=20]PacketValue:\n",latestPacketValue)
	else:
		packetPoints.append(Vector2((numberOfLine2Dpackets-1)*packetLine2DLeapValue,28))
		#print("packet not got")
	$MainPanel/VBoxContainer/packet/Line2D.points = packetPoints
	pass


func update_posx_panel():
	var packetPoints:PackedVector2Array = $MainPanel/VBoxContainer/posx/Line2D.points
	
	for indx in numberOfLine2Dpackets:
		packetPoints[indx].x = packetPoints[indx].x-packetLine2DLeapValue
		indx+=1
	#print(packetPoints)
	packetPoints.remove_at(0)
	if posXReceived:
		posXReceived = false
		#print("packet got")
		packetPoints.append(Vector2((numberOfLine2Dpackets-1)*packetLine2DLeapValue,28+packetLine2DJumpValue))
		$MainPanel/VBoxContainer/posx/TimeBetweenPackets.text = str("TimeBetweenPackets:\n[left]",Time.get_ticks_msec()-lastPacketMsgTime," ms")
		lastPacketMsgTime = Time.get_ticks_msec()
		$MainPanel/VBoxContainer/posx/PacketValue.text = str("[font_size=20]PacketValue:\n",latestPosxValue)
	else:
		packetPoints.append(Vector2((numberOfLine2Dpackets-1)*packetLine2DLeapValue,28))
		#print("packet not got")
	$MainPanel/VBoxContainer/posx/Line2D.points = packetPoints
	pass


func update_posy_panel():
	var packetPoints:PackedVector2Array = $MainPanel/VBoxContainer/posy/Line2D.points
	
	for indx in numberOfLine2Dpackets:
		packetPoints[indx].x = packetPoints[indx].x-packetLine2DLeapValue
		indx+=1
	#print(packetPoints)
	packetPoints.remove_at(0)
	if posYReceived:
		posYReceived = false
		#print("packet got")
		packetPoints.append(Vector2((numberOfLine2Dpackets-1)*packetLine2DLeapValue,28+packetLine2DJumpValue))
		$MainPanel/VBoxContainer/posy/TimeBetweenPackets.text = str("TimeBetweenPackets:\n[left]",Time.get_ticks_msec()-lastPacketMsgTime," ms")
		lastPacketMsgTime = Time.get_ticks_msec()
		$MainPanel/VBoxContainer/posy/PacketValue.text = str("[font_size=20]PacketValue:\n",latestPosyValue)
	else:
		packetPoints.append(Vector2((numberOfLine2Dpackets-1)*packetLine2DLeapValue,28))
		#print("packet not got")
	$MainPanel/VBoxContainer/posy/Line2D.points = packetPoints
	pass
