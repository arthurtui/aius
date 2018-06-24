extends Control

# would be preferrable not to change these numbers
const KB_CUSTOM_ID_1 = 100
const KB_CUSTOM_ID_2 = 200

onready var quit_bar = $CSS/Back/VBox/QuitBar

var active_devices = {} # which device controls which player
var selected_characters = [null,null,null,null,null]
var available_characters = ["skeleton", "broleton", "sealeton", "bloodyskel",
	"char 1", "char 2"]
var ready_players = [] # which players are ready


func _ready():
	set_process_input(true)
	set_physics_process(true)


func _physics_process(delta):
	# adds progress to a quit progress bar. When full, quits to the main menu
	if Input.is_action_pressed("ui_cancel"):
		quit_bar.show()
		quit_bar.value += 1
		if quit_bar.get_value() >= quit_bar.get_max():
			get_tree().change_scene("res://menus/main menu/main_menu.tscn")
	
	# if cancel is not being held, subtracts from the quit bar
	else:
		quit_bar.value -= 1
		if quit_bar.get_value() <= 0:
			quit_bar.hide()



func _input(event):
	var id
	# detects a keyboard event and changes id so that the first
	# controller and the keyboard don't overlap inputs
	if Input.is_action_just_pressed("d100_enter"):
		id = KB_CUSTOM_ID_1
	elif Input.is_action_just_pressed("d100_left") or Input.is_action_just_pressed("d100_right"):
		id = KB_CUSTOM_ID_1
	elif Input.is_action_just_pressed("d100_cancel"):
		id = KB_CUSTOM_ID_1
	elif Input.is_action_just_pressed("d200_enter"):
		id = KB_CUSTOM_ID_2
	elif Input.is_action_just_pressed("d200_left") or Input.is_action_just_pressed("d200_right"):
		id = KB_CUSTOM_ID_2
	elif Input.is_action_just_pressed("d200_cancel"):
		id = KB_CUSTOM_ID_2
	else:
		 id = event.device
	
	
	if Input.is_action_just_pressed("pause") or Input.is_action_just_pressed("ui_accept"):
	    player_start(id)
	
	
	elif Input.is_action_just_pressed("ui_right") or Input.is_action_just_pressed("ui_left"):
	    player_change_char(id)
	
	
	elif Input.is_action_just_pressed("ui_cancel"):
	    player_exit(id)


# player enters the game
func player_start(id):
	# Adds the player in the screen
	if not id in active_devices and active_devices.size() < 4:
		for pl in range(4):
			# searches for the first empty slot in the CSS
			# and adds the player there
			if selected_characters[pl] == null:
				selected_characters[pl] = available_characters.pop_front()
				active_devices[id] = pl + 1
				
				var character = selected_characters[pl]
				get_node(str("CSS/P", pl + 1,"/Items/bg/anim")).play("enter")
				get_node(str("CSS/P", pl + 1,"/Items/character")).set_animation(character)
				break
	
	# Removes the player if he's already there
	else:
		var player = active_devices[id]
		
		# updates the global variables, because we might leave
		# this scene after this point (after the animations end)
		player_data.active_devices = active_devices
		player_data.selected_characters = selected_characters
		
		# Ready
		if not player in ready_players:
			ready_players.append(player)
			player_data.ready_players = ready_players
			get_node(str("CSS/P", player, "/Items/anim")).play("ready")
		# Unready
		else:
			ready_players.remove(ready_players.find(player))
			player_data.ready_players = ready_players
			get_node(str("CSS/P", player, "/Items/anim")).play("unready")


# player changes character
func player_change_char(id):
	if active_devices.size() > 0 and id in active_devices:
		var player = active_devices[id]
		
		# ready players cannot change character
		if not player in ready_players:
			# selects next available character
			if Input.is_action_just_pressed("ui_right"):
				# updates the list of available characters
				available_characters.append(selected_characters[player - 1])
				selected_characters[player - 1] = available_characters.pop_front()
			else:
				available_characters.push_front(selected_characters[player - 1])
				selected_characters[player - 1] = available_characters.pop_back()
			
			var character = selected_characters[player - 1]
			
			# update global variables, because the CSS_player code is going to use
			# them in the next animation
			player_data.selected_characters = selected_characters
			get_node(str("CSS/P", player,"/Items/character/anim")).play("change")


# player "exits"
func player_exit(id):
	if id in active_devices and not active_devices[id] in ready_players:
		var player = active_devices[id]
			
			
		available_characters.push_front(selected_characters[player - 1])
		selected_characters[player - 1] = null
		active_devices.erase(id)
		get_node(str("CSS/P", player,"/Items/bg/anim")).play("exit")