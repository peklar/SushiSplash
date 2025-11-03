extends CanvasLayer

var save_path = "res://Sushi_Splash_Save.cfg" #DEFAULT
#var save_path = "user://Sushi_Splash_Save.cfg" #LINUX
#var save_path = "C:/Users/xavat/OneDrive/Desktop/Sushi_Splash_Save.cfg" #WINDOWS

var cfg = ConfigFile.new()
var load_path = cfg.load(save_path)
var playerScoreColor:String = "#FFD45E"

func _ready():
	
	#$AnimationPlayer.play("Show")
	#
	#var dayToken:String = return_day_token()
	#print(Time.get_date_dict_from_system())
	#
	#generate_scoreboard(5000,dayToken)
	$Control.visible = false
	pass

func return_day_token()->String:
	var curDate:Dictionary = Time.get_date_dict_from_system()
	return str(curDate["year"],"-",curDate["day"],"-",curDate["month"])

func generate_scoreboard(playerScore:int,dayToken:String):
	
	save_top_daily_scores(playerScore,dayToken)
	var dailyScores = return_top_daily_scores(dayToken)
	
	$Control/VBoxContainer/Text2/VBoxContainer/FinalScore.text = str(
		"[wave amp=10.0 freq=5.0 connected=0][outline_size=20][outline_size=20][font_size=100][center]Final Score:[p][wave amp=40.0 freq=10.0 connected=0][center][color=",playerScoreColor,"]",
		playerScore)
	
	var dailyScoresText:String = "[wave amp=10.0 freq=5.0 connected=0][outline_size=20][font_size=70'][center]"
	var indx2 = 1
	var playerScoreIndex = -1
	for s in dailyScores:
		var isPlayerScore:bool = false
		if s == playerScore:
			isPlayerScore = true
		if !isPlayerScore:
			dailyScoresText+=str("[p][right]",s," [/right][/p]")
		else:
			playerScoreIndex = indx2
			dailyScoresText+=str("[color=",playerScoreColor,"][wave amp=40.0 freq=10.0 connected=0][p][right]",s," [/right][/p][/wave][/color]")
			
		indx2+=1
		pass
	#print(dailyScoresText)
	$Control/VBoxContainer/Text2/DailyScores.text = dailyScoresText
	
	generate_numbers(playerScoreIndex)
	
	pass

func generate_numbers(indexOfPlayerScore:int = -1):
	var txt:String = "[outline_size=20][font_size=70]"
	for n in range(10):
		if n+1!=10:
			if indexOfPlayerScore-1!=n:
				txt+=str("[right]  ",n+1,":[/right]")
			else:
				txt+=str("[color=",playerScoreColor,"][wave amp=40.0 freq=10.0 connected=0][right]  ",n+1,":[/right][/wave][/color]")
		else:
			if indexOfPlayerScore!=n:
				txt+=str("[right] ",n+1,":[/right]")
			else:
				txt+=str("[color=",playerScoreColor,"][wave amp=40.0 freq=10.0 connected=0][right] ",n+1,":[/right][/wave][/color]")
		pass
	$Control/VBoxContainer/Text2/DailyNumbers.text = txt
	pass

func return_top_daily_scores(dayToken)->Array:
	#var scores:Array = [5842,1425,122,51256,1455,9544,3333]
	var scores:Array = cfg.get_value(dayToken,"scores",[])
	
	scores.sort_custom((func(a, b): return a > b))
	
	while scores.size()<10:
		scores.append(0)
	
	return scores

func save_top_daily_scores(playerScore:int,dayToken:String):
	var dailyScores = return_top_daily_scores(dayToken)
	var indx = 0
	
	for s in dailyScores:
		#ne bomo 2x shranli istega scora
		if playerScore==s:
			return
		#ce je score vecji ga dodaj ter shrani
		if playerScore>s:
			dailyScores.insert(indx,playerScore)
			dailyScores.remove_at(10)
			break
		indx+=1
		pass
	
	cfg.set_value(dayToken,"scores",dailyScores)
	cfg.save(save_path)
	pass

func show_scoreboard(playerScore:int):
	generate_scoreboard(playerScore,return_day_token())
	$AnimationPlayer.play("Show")
	pass

func hide_scoreboard():
	$Control.visible = false
	#$AnimationPlayer.play("Hide")
	pass
