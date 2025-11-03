extends Node2D



func _on_gate_on_button_down():
	$"OSCClient - OUT".send_message("/synth1/gate", [1])
	pass # Replace with function body.


func _on_gate_off_button_down():
	$"OSCClient - OUT".send_message("/synth1/gate", [0])
	pass # Replace with function body.
