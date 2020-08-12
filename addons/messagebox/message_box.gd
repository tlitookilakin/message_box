tool extends RichTextLabel

export(float) var speed = 1 setget _set_speed
export(float) var acceleration = 2 setget _set_accel
export(String, MULTILINE) var message = "" setget _set_message
export(String) var skip_action = ""
export(String) var accelerate_action = ""
export(Array, AudioStream) var voice = []
export(NodePath) var player = "" setget _set_player

signal message_done

var _isready = false
var _speed_mult = 1
var _last_speed = 1
var _done = false
var _last_char = 0
var _accel = false
var _cool = true
var _ready = false
#github 37720
var _line_size = 1
var _max_lines = 1
#end hacks
onready var _tween = Tween.new()
onready var _old_theme = theme
onready var _cooldown = Timer.new()
var _player = null

func _init():
	scroll_active = false

func _ready():
	if Engine.editor_hint:
		return
	_ready = true
	add_child(_tween)
	add_child(_cooldown)
	self.player = player
	_tween.connect("tween_all_completed",self,"_on_done")
	_cooldown.connect("timeout",self,"_on_cool")
	connect("resized",self,"_resized")
	_cooldown.wait_time = .1
	bbcode_enabled = true
	scroll_active = false
	scroll_following = false
	var sbb = speedbb.new()
	sbb.caller = self
	install_effect(sbb)
	_resized()
	_isready = true
	_start_msg()

func _set_player(path):
	player = path
	if !_ready:
		return
	_player = get_node(path)
	if _player != null:
		_player.autoplay = false

func _on_cool():
	_cool = true

func _set_speed(val):
	speed = float(val)
	if _tween == null:
		return
	if val != 0:
		_tween.playback_speed = _speed_mult * speed
	else:
		_tween.stop_all()
		percent_visible = 1.0
		_on_done()

func _set_accel(val):
	if val <= 0:
		return
	acceleration = float(val)
	if _accel and _tween != null:
		_tween.playback_speed = _speed_mult * speed * acceleration

func _on_done():
	_done = true
	emit_signal("message_done")

func _unhandled_input(event):
	if _tween == null or event.echo:
		return
	if event.is_action_pressed(skip_action):
		if !_done and _cool:
			if speed >= 0:
				_tween.seek(_tween.get_runtime()*_tween.playback_speed)
			else:
				_tween.seek(0)
			get_tree().set_input_as_handled()
	elif event.is_action_pressed(accelerate_action):
		_accel = true
		_tween.playback_speed = speed * _speed_mult * acceleration
		get_tree().set_input_as_handled()
	elif event.is_action_released(accelerate_action):
		_accel = false
		_tween.playback_speed = speed * _speed_mult
		get_tree().set_input_as_handled()

func _start_msg():
	_speed_mult = 1
	_last_speed = 1
	_cool = false
	_cooldown.start()
	if _tween.is_active():
		_tween.remove_all()
	if speed != 0:
		_tween.playback_speed = speed
		_done = false
		if speed < 0:
			_tween.interpolate_property(self,"visible_characters",0,text.length()+1,text.length()+1)
			_tween.seek(text.length()+.9)
			get_v_scroll().value = get_v_scroll().max_value
		else:
			_tween.interpolate_property(self,"percent_visible",0.0,1.0,text.length())
		_tween.start()
	else:
		percent_visible = 1.0
		_on_done()

func _resized():
	_line_size = get_font("normal_font").get_height() + get_constant("line_separation")
	_max_lines = int(get_rect().size.y / _line_size)-1

func _scroll(v):
	get_v_scroll().value += v

func _process(delta):
	if Engine.editor_hint:
		return
	if theme != _old_theme:
		_old_theme = theme
		_resized()
	if get_visible_line_count() > _max_lines and visible_characters > 0 and speed > 0:
		_scroll(3)
	if get_visible_line_count() <= _max_lines and visible_characters > 0 and speed < 0:
		_scroll(-3)
	if _speed_mult != _last_speed:
		_last_speed = _speed_mult
		_tween.playback_speed = _speed_mult * speed
	if !_done and speed < 0 and _tween.tell() == 0:
		_on_done()
	if _last_char != visible_characters and voice.size() > 0 and _player != null:
		_last_char = visible_characters
		_player.stop()
		_player.stream = voice[round(rand_range(0,voice.size()-1))]
		_player.play()

func _set_message(val):
	if typeof(val) != TYPE_STRING:
		return
	bbcode_text = val
	message = val
	if _isready and !Engine.editor_hint:
		_start_msg()

func _block_speed(val):
	if val > 0:
		_speed_mult = val

class speedbb extends RichTextEffect:
	var bbcode = "spd"
	var caller = null
	
	func _process_custom_fx(char_fx):
		if Engine.editor_hint:
			return true
		if char_fx.visible and caller != null and char_fx.env.has(""):
			if char_fx.relative_index == 0 and ((caller.speed >=0 and caller.percent_visible < 1.0) or caller.speed < 0):
				if !char_fx.env.has("_base"):
					char_fx.env["_base"] = caller._speed_mult
				caller._block_speed(char_fx.env[""])
			if char_fx.env.get("_ct",-1) == char_fx.relative_index:
				caller._block_speed(char_fx.env.get("_base",1))
		if caller!= null and caller.speed < 0 and char_fx.relative_index == 0 and caller.visible_characters == char_fx.absolute_index-1:
			caller._block_speed(char_fx.env.get("_base",1))
		char_fx.env["_ct"] = max(char_fx.relative_index, char_fx.env.get("_ct",0))
		return true
