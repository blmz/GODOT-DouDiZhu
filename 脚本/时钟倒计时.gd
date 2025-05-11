extends TextureRect

@onready var 计时器:Timer = $计时器
@onready var 时钟标签:Label = $时钟标签

signal 计时结束
@export var 计时时间:int = 60
var 当前时间:int = 0

func 开始计时():
    visible = true
    当前时间 = 计时时间
    计时器.wait_time = 1
    计时器.start()
    时钟标签.text = str(计时时间)

func _on_计时器_timeout():
    if 当前时间 <= 0:
        计时器.stop()
        计时结束.emit()
        visible = false
        return
    当前时间 -= 1
    if 当前时间 <10:
        时钟标签.modulate=Color.ORANGE_RED
        时钟标签.text = "0" + str(当前时间)
    else:
        时钟标签.modulate=Color.WHITE
        时钟标签.text = str(当前时间)
