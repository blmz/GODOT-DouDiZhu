extends Control

#UI
@onready var 手牌点 = $"手牌点"
@onready var 中心点 = $"中心点"
@onready var 发牌按钮=$"发牌按钮"
@onready var 手牌线点 = $"手牌排列线/手牌线/手牌线点"
@onready var 当前选择 = $"当前选择"
@onready var 玩家选择列表UI = $"玩家选择列表"

#曲线
@export var 选择上升曲线:Curve
@export var 选择分散曲线:Curve
@export_range(0,100) var 选择上升距离:float
@export_range(0,100) var 选择分散距离:float

#发牌相关
@onready var 发牌计时器 = $"发牌计时器"
@onready var 上家点 = $"上家点"
@onready var 下家点 = $"下家点"
@onready var 牌堆牌数显示 = $"牌堆牌数显示"
@onready var 上家牌数显示 = $"上家牌数显示"
@onready var 下家牌数显示 = $"下家牌数显示"

#扑克牌场景
@export var 扑克牌:PackedScene

#牌堆
var 点数列表:Array[String] = ["3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A", "2", "小王", "大王"]
var 花色列表:Array[String] = ["红桃","方片","黑桃","梅花"]
var 初始牌堆:Array[扑克牌类]

#手牌列表
var 玩家手牌列表:Array[Node]#玩家牌UI列表
var 玩家牌列表:Array[扑克牌类]#玩家牌列表
var 上家手牌列表:Array[Node]#上家牌UI列表
var 上家牌列表:Array[扑克牌类]#上家牌列表
var 下家手牌列表:Array[Node]#下家牌UI列表
var 下家牌列表:Array[扑克牌类]#下家牌列表
var 玩家选择列表:Array[Node]#玩家选择的牌列表

#发牌相关
var 是否发牌:=false
var 发牌数:=0

var 当前选择牌:Node:
	set(值):#当值被改变时执行函数
		当前选择牌=值
		if(值==null):
			当前选择.text="未选择"
		else:
			当前选择.text=值.牌.花色+值.牌.点数

#重新把牌移动到位置列表中对应的位置
func 重置位置(位置列表:Array[Vector2]):
	if (位置列表.size()!=玩家手牌列表.size()):
		printerr("位置列表和手牌列表数量不对等!")
		return 0
	for i in range(0,玩家手牌列表.size()):
		玩家手牌列表[i].移动到(位置列表[i])
		玩家手牌列表[i].旋转到(位置列表[i].angle_to_point(手牌点.position)/(2*PI)*360-90)

#选择手牌后重新计算所有牌的位置
func 选牌位置计算(选牌:Node)->Array[Vector2]:
	var 手牌数量 = 玩家手牌列表.size()
	var 选牌编号 = 玩家手牌列表.find(选牌)
	var 计算后位置 :Array[Vector2]=计算位置(手牌数量)
	var 左右最大牌数 =float(max(选牌编号,手牌数量-选牌编号-1))
	var 曲线段长:float = 1.0/(左右最大牌数*2.0)
	for 距中段数 in range(1,左右最大牌数+1):
		if (选牌编号-距中段数>=0):
			手牌线点.progress_ratio=1.0/(手牌数量+1)*(选牌编号-距中段数+1)
			手牌线点.progress -= 选择分散距离*选择分散曲线.sample(曲线段长*距中段数)
			计算后位置[选牌编号-距中段数]=手牌线点位置()
		if (选牌编号+距中段数<=手牌数量-1):
			手牌线点.progress_ratio=1.0/(手牌数量+1)*(选牌编号+距中段数+1)
			手牌线点.progress += 选择分散距离*选择分散曲线.sample(曲线段长*距中段数)
			计算后位置[选牌编号+距中段数]=手牌线点位置()
	return 计算后位置

#从左到右重新排序手牌的显示z_index排序
func 手牌显示排序():
	var 层数=0;
	for 手牌 in 玩家手牌列表:
		手牌.z_index=层数
		层数+=1

#按手牌数量在手牌线上计算每一个牌的位置点，使其平均分布在手牌排列线上
func 计算位置(手牌数量:int)->Array[Vector2]:
	var 位置列表:Array[Vector2]
	var 分段长:float=1.0/(手牌数量+1)
	for i in range(1,手牌数量+1):
		手牌线点.progress_ratio=分段长*i
		位置列表.append(手牌线点位置())
	手牌显示排序()
	return 位置列表

#返回手牌线点的绝对位置
func 手牌线点位置()->Vector2:
	var 位置:Vector2=手牌线点.position+手牌线点.get_parent().position+手牌线点.get_parent().get_parent().position
	return 位置

#给玩家发一张扑克牌
func 玩家发牌(牌型:扑克牌类):
	var 牌=扑克牌.instantiate()
	add_child(牌)
	牌.connect("鼠标进入",鼠标进入手牌)
	牌.connect("鼠标离开",鼠标离开手牌)
	牌.更新牌(牌型)
	玩家手牌列表.append(牌)
	
	牌.position=中心点.position
	牌.rotation_degrees=0
	重置位置(计算位置(玩家手牌列表.size()))

#给对家发一张扑克牌
func 对家发牌(对家:Node,牌型:扑克牌类):
	var 牌=扑克牌.instantiate()
	对家.add_child(牌)
	牌.更新牌(牌型)
	match 对家.name:
		"上家点":上家牌列表.append(牌型)
		"下家点":下家牌列表.append(牌型)
	牌.翻面()
	牌.position=中心点.position-对家.position
	牌.rotation_degrees=0
	牌.移动到(对家.position-对家.position)

#把玩家的手牌按照斗地主的牌大小从右到左排列
func 排序手牌():
	var 手牌复制:Array[Node]=玩家手牌列表
	var 空列表:Array[Node]
	for 点数 in 点数列表:
		for 复制牌 in 手牌复制:
			if(复制牌.牌.点数==点数):
				空列表.append(复制牌)
	空列表.reverse()
	玩家手牌列表=空列表
	重置位置(计算位置(玩家手牌列表.size()))

#创建一副扑克牌，并打乱它
func 初始化牌堆():
	for 花色 in 花色列表:
		for i in range(13):
			初始牌堆.append(扑克牌类.new(花色,点数列表[i]))
	初始牌堆.append(扑克牌类.new("","大王"))
	初始牌堆.append(扑克牌类.new("","小王"))
	#print(初始牌堆,"牌堆大小为",初始牌堆.size())
	初始牌堆.shuffle()#打乱牌堆
	#print(初始牌堆,"牌堆大小为",初始牌堆.size())

func 开始发牌():
	牌堆牌数显示.visible=true
	是否发牌=true
	发牌计时器.start()

#给所有玩家发牌并且留三张
func 发牌():
	if(初始牌堆.size()==3):
		是否发牌=false
		return 0
	var 位置数=发牌数%3
	match 位置数:
		0:玩家发牌(初始牌堆.pop_front())
		1:对家发牌(下家点,初始牌堆.pop_front())
		2:对家发牌(上家点,初始牌堆.pop_front())
	发牌数+=1
	牌堆牌数显示.更新牌数(初始牌堆.size())
	下家牌数显示.更新牌数(下家牌列表.size())
	上家牌数显示.更新牌数(上家牌列表.size())

func 发底牌(对象=""):
	for 牌 in 初始牌堆:
		match 对象:
			"玩家":玩家发牌(牌)
			"上家":对家发牌(上家点,牌)
			"下家":对家发牌(下家点,牌)
	牌堆牌数显示.visible=false
	排序手牌()

func 打出牌():
	if(玩家选择列表.size()==0):
		return 0
	for 牌 in 玩家选择列表:
		玩家手牌列表.erase(牌)
		牌.queue_free()

func 鼠标进入手牌(对象:Panel):
	当前选择牌=对象
	重置位置(选牌位置计算(对象))
	#对象.z_index=99
	#print("进入了",对象.牌.花色,对象.牌.点数)

func 鼠标离开手牌(对象:Panel):
	当前选择牌=null
	重置位置(计算位置(玩家手牌列表.size()))
	#print("离开了",对象.牌.花色,对象.牌.点数)

func 点击牌(event):
	#如果鼠标按下时有选中的牌，则调用选中函数
	if(event is InputEventMouseButton):
		if(event.button_index==MOUSE_BUTTON_LEFT and event.pressed):
			if(当前选择牌!=null):
				当前选择牌.选中()
				if(当前选择牌.是否被选中):
					玩家选择列表.append(当前选择牌)
				else:
					玩家选择列表.erase(当前选择牌)
				var 牌列表:Array[String]
				for 牌 in 玩家选择列表:
					牌列表.append(牌.牌.花色+牌.牌.点数)
				玩家选择列表UI.text="玩家选择的牌:"+str(牌列表)

func _process(delta:float):
	pass

func _input(event:InputEvent):
	点击牌(event)
	

func _ready():
	初始化牌堆()

func _on_发牌按钮_button_down():
	开始发牌()

func _on_排序按钮_button_down():
	排序手牌()
	#手牌显示排序()

func _on_发牌计时器_timeout():
	if(!是否发牌):
		发牌计时器.stop()
		是否发牌=false
		排序手牌()
		发底牌("玩家")
	else:
		发牌()

#位置改变时重置手牌位置
func _on_item_rect_changed():
	重置位置(计算位置(玩家手牌列表.size()))


func _on_重发_button_up():
	pass
