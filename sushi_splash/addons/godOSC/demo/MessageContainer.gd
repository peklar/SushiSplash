extends GridContainer
@onready var cube_slider = get_parent().get_node("Cube 1 Slider")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	cube_slider.value = val
	pass



var val:float = 0.0
var indx = 0
# Signal sent from OSCServer that sends the Address, Value, and System Time
func _on_osc_server_message_received(address, value, time):
	print(indx)
	#indx+=1
	val = float(value)
	#get_parent().get_node("Cube 1 Slider").value = value
	$Add1.text = address
	$Val1.text = str(value)
	$Time1.text = str(time)
	pass # Replace with function body.
