extends Control

@onready var 手牌点 = $"手牌点"
@onready var 中心点 = $"中心点"
@onready var 发牌按钮=$"发牌按钮"
@onready var 手牌线点 = $"手牌线/手牌线点"
@onready var 当前选择 = $"当前选择"

@export var 选择分散曲线:Curve
@export var 扑克牌:PackedScene
@export var 手牌列表:Array[Node]
@export_range(0,100) var 选择分散距离:float

var 点数列表:Array[String] = ["3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A", "2", "小王", "大王"]
var 花色列表:Array[String] = ["红桃","方片","黑桃","梅花"]
var 初始牌堆:Array[String] 
var 当前选择牌:Node:
	set(值):#当值被改变时执行函数
		当前选择牌=值
		if(值==null):
			当前选择.text="未选择"
		else:
			当前选择.text=值.牌

#重新把牌移动到位置列表中对应的位置
func 重置位置(位置列表:Array[Vector2]):
	if (位置列表.size()!=手牌列表.size()):
		printerr("位置列表和手牌列表数量不对等!")
		return 0
	for i in range(0,手牌列表.size()):
		手牌列表[i].移动到(位置列表[i])
		手牌列表[i].旋转到(位置列表[i].angle_to_point(手牌点.position)/(2*PI)*360-90)

func 选牌位置计算(选牌:Node)->Array[Vector2]:
	var 手牌数量 = 手牌列表.size()
	var 选牌编号 = 手牌列表.find(选牌)
	var 计算后位置 :Array[Vector2]=计算位置(手牌数量)
	for i in range(-3,4):
		if(选牌编号+i<0 or 选牌编号+i>手牌数量-1):
			continue
		计算后位置[选牌编号+i].y-=选择分散距离*选择分散曲线.sample((1.0/6.0)*(i+3))
		#print("i:",i,"  选牌编号:",选牌编号," ， 曲线点数：",选择分散曲线.sample(1.0/6.0)*(i+3))
	return 计算后位置

#按手牌数量在手牌线上计算每一个牌的位置点，使其平均分布在线上
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
	牌.connect("鼠标进入",鼠标进入手牌)
	牌.connect("鼠标离开",鼠标离开手牌)
	牌.position=中心点.position
	牌.rotation_degrees=0
	牌.更新牌(牌名)
	if!正面:
		牌.翻面()
	手牌列表.append(牌)
	重置位置(计算位置(手牌列表.size()))

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

func 鼠标进入手牌(对象:Panel):
	当前选择牌=对象
	对象.z_index=99
	重置位置(选牌位置计算(对象))

func 鼠标离开手牌(对象:Panel):
	当前选择牌=null
	对象.z_index=0
	重置位置(计算位置(手牌列表.size()))

func _on_发牌按钮_button_down():
	发牌(初始牌堆.pop_back())

func _ready():
	初始化牌堆()
