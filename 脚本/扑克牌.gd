extends Panel

signal 鼠标进入(对象:Panel)
signal 鼠标离开(对象:Panel)

@export var 运动曲线:Curve

@onready var 图片 = $"图片"
@onready var 牌背 = $"牌背"
@onready var 选择发光框 = $"选择发光框"

var 是否运动:=false
@export_range(0,1000) var 运动速度:=500.0
var 运动方向:Vector2
var 目标位置:Vector2
var 目标距离:float

var 是否旋转:=false
@export_range(0,500) var 旋转速度:float=100
var 角度差值:float
var 目标角度:float

var 文件地址="res://扑克牌图片/"
var 牌:扑克牌类

func 更新牌(牌参数:扑克牌类):
	if(牌参数!=null):
		牌=牌参数
		图片.texture=load(文件地址+牌.花色+牌.点数+".jpg")

#调整手牌正反面
func 翻面():
	图片.visible=false
	牌背.visible=true

#移动命令发布
func 移动到(位置:Vector2):
	目标位置=位置
	目标距离 = position.distance_to(位置)
	运动方向 = (位置-position).normalized()
	是否运动=true

#移动动作,每一帧进行
func 移动(delta):
	if 是否运动:
		var 移动进度=(目标距离-position.distance_to(目标位置))/目标距离
		var 速度差值=运动曲线.sample(移动进度)
		position=position.move_toward(目标位置,运动速度*速度差值*delta)
		if(移动进度>=0.99):
			是否运动=false

#旋转命令发布
func 旋转到(角度:float=0):
	if (rotation_degrees>180):
		rotation_degrees-=360
	if(角度>=360):
		目标角度=角度-360*int(角度/360)
	elif(角度<=-360):
		目标角度=角度-360*int(角度/360)
	else:
		目标角度=角度
	角度差值=目标角度-rotation_degrees
	if(角度差值!=0):
		是否旋转=true

#旋转动作,每一帧进行
func 旋转(delta):
	if 是否旋转:
		if(角度差值>0):
			var 旋转进度=1-(目标角度-rotation_degrees)/角度差值
			#print(旋转进度)
			var 旋转差值=运动曲线.sample(旋转进度)
			rotation_degrees+=旋转速度*旋转差值*delta
			if(旋转进度>=0.999):
				是否旋转=false
		elif(角度差值<0):
			var 旋转进度=1-(目标角度-rotation_degrees)/角度差值
			#print(旋转进度)
			var 旋转差值=运动曲线.sample(旋转进度)
			rotation_degrees-=旋转速度*旋转差值*delta
			if(旋转进度>=0.999):
				是否旋转=false

func 鼠标进了():
	鼠标进入.emit(self)
	选择发光框.visible=true

func 鼠标出了():
	鼠标离开.emit(self)
	选择发光框.visible=false

func _process(delta):
	移动(delta)
	旋转(delta)

func _ready():
	pass
