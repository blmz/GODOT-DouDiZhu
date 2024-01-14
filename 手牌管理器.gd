extends Control

@export var 曲线:Curve
@export var 扑克牌:PackedScene

@onready var 手牌点 = $"手牌点"
@onready var 中心点 = $"中心点"
@onready var 发牌按钮=$"发牌按钮"
@onready var 手牌线点 = $"手牌线/手牌线点"

@export var 手牌列表:Array[Node]

var 点数列表:Array[String] = ["3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A", "2", "小王", "大王"]
var 花色列表:Array[String] = ["红桃","方片","黑桃","梅花"]
var 初始牌堆:Array[String] 

func 重置位置():
	var 位置列表=计算位置(手牌列表.size())
	for i in range(0,手牌列表.size()):
		手牌列表[i].移动到(位置列表[i])
		手牌列表[i].旋转到(位置列表[i].angle_to_point(手牌点.position)/(2*PI)*360-90)

func 计算位置(手牌数量:int)->Array[Vector2]:
	var 位置列表:Array[Vector2]
	var 分段长:float=1.0/(手牌数量+1)
	for i in range(1,手牌数量+1):
		手牌线点.progress_ratio=分段长*i
		位置列表.append(手牌线点.position)
	return 位置列表

func 发牌(牌名="",位置:Vector2=手牌点.position,正面=true):
	var 牌=扑克牌.instantiate()
	add_child(牌)
	牌.position=中心点.position
	牌.rotation_degrees=0
	牌.更新牌(牌名)
	if!正面:
		牌.翻面()
	手牌列表.append(牌)
	重置位置()

func 初始化牌堆():
	var 牌=""
	for 花色 in 花色列表:
		for i in range(13):
			牌=花色+点数列表[i]
			初始牌堆.append(牌)
	初始牌堆.append("小王")
	初始牌堆.append("大王")
	#print(初始牌堆,"牌堆大小为",初始牌堆.size())
	初始牌堆.shuffle()#打乱牌堆
	#print(初始牌堆,"牌堆大小为",初始牌堆.size())

func _on_发牌按钮_button_down():
	发牌(初始牌堆.pop_back())

func _ready():
	初始化牌堆()
