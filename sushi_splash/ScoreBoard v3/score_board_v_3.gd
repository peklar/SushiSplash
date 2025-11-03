extends CanvasLayer

var deviceID:String = ""
var deviceKey:String = ""
var data:Dictionary

@onready var allTimeLabel:RichTextLabel = $ScoresContainer/Scores/AllTime/ScaleContainer/RichTextLabel
@onready var dailyLabel:RichTextLabel = $ScoresContainer/Scores/Daily/ScaleContainer/RichTextLabel
@onready var monthlyLabel:RichTextLabel = $ScoresContainer/Scores/Monthly/ScaleContainer/RichTextLabel

@export var maxTimeForHTTPRequest:float = 3
var numberOfScores:float = 5

@export var debugLabelShown:bool = false

#@export var highlightColor:Color = Color("FFC700")
var highlightColorHex:String

var httpMaxTimeReached: bool = false
var playerScore:int = 0
var gamename:String = "sushisplash"

#/tmp/mac device_id

func _ready():
	highlightColorHex = "FFC700"#highlightColor.to_html()
	deviceID = await get_device_id()
	deviceKey = get_key("/tmp/key.txt")
	$DebugLabel.text+=str("using device_id: '",deviceID,"'\n")
	$HTTPRequestGET.set_tls_options(TLSOptions.client_unsafe())
	$DebugLabel.text+=str("HTTPRequestGET and HTTPRequestPOST set to: client_unsafe\n")
	$HTTPRequestPOST.set_tls_options(TLSOptions.client_unsafe())
	
	if !debugLabelShown:
		$DebugLabel.visible = false
	
	#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	#generate_scoreboard(400)
	pass



func generate_scoreboard(PS:int):
	playerScore = PS
	$DebugLabel.text+=str("api call: http://highscore.visiorgames.com/api/highscore/scoreboard?device_id=",deviceID,"&game_type=",gamename,"\n")
	$HTTPRequestGET.request(str("http://highscore.visiorgames.com/api/highscore/scoreboard?device_id=",deviceID,"&game_type=",gamename))
	$GetTimer.start(maxTimeForHTTPRequest)
	pass

func get_device_id():
	var file := FileAccess.open("/tmp/mac", FileAccess.READ)
	if file == null:
		$DebugLabel.text+=str("file was NULL. could not find /tmp/mac\n")
		return "100%an_invalid_id"
	# preberi vsebino in odstrani whitespace/newline okoli
	var text := file.get_as_text()
	file.close()
	return text.strip_edges()  # odstrani začetne/končne whitespace in newline

func get_key(path: String) -> String:
	if not FileAccess.file_exists(path):
		print(str("File not found: ",path))
		$DebugLabel.text+=str("File not found: ", path,"\n")
		return ""
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		print(str("Failed to open file: ", path))
		$DebugLabel.text+=str("Failed to open file: ", path,"\n")
		return ""
	var text := f.get_as_text()
	f.close()
	$DebugLabel.text+=str("Key is: ", text,"\n")
	return text


func post_score():
	if !playerScore == 0:
		var postString:String = ""
		if deviceKey != "":
			postString = str("http://highscore.visiorgames.com/api/highscore/post/?device_id=",deviceID,"&score=",playerScore,"&game_type=",gamename)
			pass
		else:
			postString = str("http://highscore.visiorgames.com/api/highscore/post/?device_id=",deviceID,"&score=",playerScore,"&game_type=",gamename,"&key=",deviceKey)
			pass
		
		$DebugLabel.text+=str(postString,"\n")
		$HTTPRequestPOST.request(postString)
	pass


func update_scores(allTimeArr:Array,todayArr:Array,monthlyArr:Array):
	var labelPlayerScoreStyle:String = str("[color=",highlightColorHex,"][wave amp=20.0 freq=10.0 connected=0][outline_size=20][font_size=120]")
	
	$YourScoreContainer/PlayerScoreScaleContainer2/RichTextLabel.text = str(labelPlayerScoreStyle,"[center]",playerScore)
	
	var allTime:Array = fill_array_if_not_full(allTimeArr,10)
	var today:Array = fill_array_if_not_full(todayArr,10)
	var monthly:Array = fill_array_if_not_full(monthlyArr,10)
	
	
	#appends the player socore to them
	var playerValue:Dictionary = { "user_id": 0, "user_name": null, "score": playerScore, "time_score": 0, "timestamp": null }
	allTime.append(playerValue)
	today.append(playerValue)
	monthly.append(playerValue)
	
	#sorts them by size to accommodate player score
	allTime.sort_custom(func(a, b): return a["score"] > b["score"])
	today.sort_custom(func(a, b): return a["score"] > b["score"])
	monthly.sort_custom(func(a, b): return a["score"] > b["score"])
	
	var labelDescriptorStyle:String = "[outline_size=25][font_size=110]"
	var labelScoreStyle:String = "[wave amp=10 freq=7.0 connected=1][outline_size=20][font_size=80]"
	
	var indx = 0
	var alreadyYellow:bool =false
	
	
	#All Time
	var textForLabel:String = str(labelDescriptorStyle,"[center]All Time",labelScoreStyle)
	for d in allTime:
		indx+=1
		if !alreadyYellow and d["score"] == playerScore:
			textForLabel+=str("[center][color=",highlightColorHex,"]",d["score"])
			alreadyYellow = true
		else:
			textForLabel+=str("[center][color=white]",d["score"])
		if indx >= numberOfScores:
			break
		pass
	allTimeLabel.text = textForLabel
	
	#Today
	indx = 0
	alreadyYellow =false
	textForLabel = str("[outline_size=25][font_size=120]","[center]Today",labelScoreStyle)
	for d in today:
		indx+=1
		if !alreadyYellow and d["score"] == playerScore:
			textForLabel+=str("[center][color=",highlightColorHex,"]",d["score"])
			alreadyYellow = true
		else:
			textForLabel+=str("[center][color=white]",d["score"])
		if indx >= numberOfScores:
			break
		pass
	dailyLabel.text = textForLabel
	
	
	#Monthly
	indx = 0
	alreadyYellow =false
	textForLabel = str(labelDescriptorStyle,"[center]Monthly",labelScoreStyle)
	for d in monthly:
		indx+=1
		if !alreadyYellow and d["score"] == playerScore:
			textForLabel+=str("[center][color=",highlightColorHex,"]",d["score"])
			alreadyYellow = true
		else:
			textForLabel+=str("[center][color=white]",d["score"])
		if indx >= numberOfScores:
			break
		pass
	monthlyLabel.text = textForLabel
	
	$AnimationPlayer.play("LoadScoreboard")
	
	pass

func fill_array_if_not_full(arr:Array,wantedNumber:int=10) -> Array:
	while arr.size()<10:
		arr.append(
			{
				"user_id": 0,
				"user_name": null,
				"score": 0,
				"time_score": 0,
				"timestamp": null
			}
		)
		pass
	return arr


func _on_http_request_post_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	
	if !body.get_string_from_utf8().length()==0:
		print("score posted:")
		print(JSON.parse_string(body.get_string_from_utf8()))
		$DebugLabel.text+=str("POST SENT: ",JSON.parse_string(body.get_string_from_utf8()))
	#var r = JSON.parse_string(body.get_string_from_utf8())
	#print(data)
	#if r.keys().has("status"):
		#if str(r["status"]) == "ok":
			##bil je post
			#pass
		#pass
	pass # Replace with function body.

func _on_http_request_get_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	
	if httpMaxTimeReached:
		return
	post_score()
	
	$GetTimer.stop()
	print("Http Get recieved")
	
	print()
	if !body.get_string_from_utf8().length()==0:
		data = check_gotten_data_is_ok(JSON.parse_string(body.get_string_from_utf8()))
	else:
		data = {
			"status":"0",
			"alltime":[],
			"today":[],
			"thismonth":[]
		}
	
	update_scores(data["alltime"],data["today"],data["thismonth"])
	pass # Replace with function body.

func check_gotten_data_is_ok(recievedData)->Dictionary:
	
	#27 = dict
	#https://docs.godotengine.org/en/4.3/classes/class_%40globalscope.html#enum-globalscope-variant-type
	if typeof(recievedData)!=27:
		#print("GOTTEN HTTP DATA IS NOT A DICT BUT ",typeof(recievedData)," ",recievedData)
		$DebugLabel.text+=str("\nGOTTEN HTTP DATA IS NOT A DICT BUT ",typeof(recievedData)," ",recievedData)
		$DebugLabel.text+=str("USED DEVICE ID: '",deviceID,"'")
		return {
			"status":"0",
			"alltime":[],
			"today":[],
			"thismonth":[]
		}
	
	if !recievedData.keys().has("status"):
		$DebugLabel.text+=str("\nGOTTEN HTTP DATA DOES NOT HAVE 'status' OF '0' ",recievedData)
		$DebugLabel.text+=str("USED DEVICE ID: '",deviceID,"'")
		return {
			"status":"0",
			"alltime":[],
			"today":[],
			"thismonth":[]
		}
	
	if !recievedData.keys().has("alltime"):
		$DebugLabel.text+=str("\nGOTTEN HTTP DATA DOES NOT HAVE 'alltime' ARRAY ",recievedData)
		$DebugLabel.text+=str("USED DEVICE ID: '",deviceID,"'")
		print("GOTTEN HTTP DATA DOES NOT HAVE 'alltime' ARRAY ",recievedData)
		recievedData["alltime"] = []
	if !recievedData.keys().has("today"):
		$DebugLabel.text+=str("\nGOTTEN HTTP DATA DOES NOT HAVE 'today' ARRAY ",recievedData)
		$DebugLabel.text+=str("USED DEVICE ID: '",deviceID,"'")
		print("GOTTEN HTTP DATA DOES NOT HAVE 'today' ARRAY ",recievedData)
		recievedData["today"] = []
	if !recievedData.keys().has("thismonth"):
		$DebugLabel.text+=str("\nGOTTEN HTTP DATA DOES NOT HAVE 'thismonth' ARRAY ",recievedData)
		$DebugLabel.text+=str("USED DEVICE ID: '",deviceID,"'")
		print("GOTTEN HTTP DATA DOES NOT HAVE 'thismonth' ARRAY ",recievedData)
		recievedData["thismonth"] = []
	
	return recievedData


func _on_get_timer_timeout() -> void:
	httpMaxTimeReached = true
	data = check_gotten_data_is_ok([])
	update_scores(data["alltime"],data["today"],data["thismonth"])
	pass # Replace with function body.
