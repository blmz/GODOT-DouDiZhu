extends TextureRect

@onready var 计时器:Timer = $计时器
@onready var 时钟标签:Label = $时钟标签
signal 计时结束(name:String)
signal 标记时间到
@export var 计时时间:int = 60

var 标记时间:int = 0
var 当前时间:int = 0
var 是否提醒过:bool = false

func 开始计时(时间:int=计时时间):
    visible = true
    是否提醒过 = false
    当前时间 = 时间
    计时器.wait_time = 1
    计时器.start()
    时钟标签.text = str(计时时间)

func 停止计时():
    计时器.stop()
    visible = false

func _on_计时器_timeout():
    if 当前时间 <= 0:
        计时器.stop()
        计时结束.emit(name)
        visible = false
        return
    当前时间 -= 1
    if 当前时间 <10:
        if not 是否提醒过:
            是否提醒过 = true
        时钟标签.modulate=Color.ORANGE_RED
        时钟标签.text = "0" + str(当前时间)
    else:
        时钟标签.modulate=Color.WHITE
        时钟标签.text = str(当前时间)
    if 标记时间 == 当前时间:
        标记时间到.emit()
