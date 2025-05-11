extends Control

#音频播放
@onready var 音效播放器:AudioStreamPlayer = $"音效播放器"
@onready var 背景播放器:AudioStreamPlayer = $"背景播放器"
@onready var 人声播报播放器:AudioStreamPlayer = $"人声播报播放器"
@onready var 提示播报播放器:AudioStreamPlayer = $"提示播报播放器"

#UI
@onready var 中心点:Control = $"中心点"
@onready var 手牌线点 = $"手牌排列线/手牌线/手牌线点"
@onready var 当前选择 = $"当前选择"
@onready var 玩家选择列表UI = $"玩家选择列表"
@onready var 打出牌堆 = $"打出牌堆"
@onready var 底牌展示 = $"底牌展示"
@onready var 打出按钮 = $"玩家按钮/打出按钮"
@onready var 不要按钮 = $"玩家按钮/不要按钮"
@onready var 结算界面 = $"结算界面"

#曲线
@export var 选择上升曲线: Curve
@export var 选择分散曲线: Curve
@export_range(0, 100) var 选择上升距离: float
@export_range(0, 100) var 选择分散距离: float

#发牌相关
@export var 发牌速度: float = 0.1
@onready var 发牌计时器 = $"发牌计时器"
@onready var 上家点 = $"上家点"
@onready var 下家点 = $"下家点"
@onready var 牌堆牌数显示 = $"牌堆牌数显示"
@onready var 上家牌数显示 = $"上家牌数显示"
@onready var 下家牌数显示 = $"下家牌数显示"
@onready var 玩家牌数显示 = $"玩家牌数显示"

#扑克牌场景
@export var 扑克牌: PackedScene

enum 牌手{
    上家,
    下家,
    玩家
}

#回合相关
var 地主牌手:牌手
var 农民牌手:Array[牌手]

#牌堆
var 初始牌堆: Array[扑克牌类]

#手牌列表
var 玩家手牌列表: Array[Node] # 玩家牌UI列表
var 上家手牌列表: Array[Node] # 上家牌UI列表
var 下家手牌列表: Array[Node] # 下家牌UI列表
var 玩家选择列表: Array[Node] # 玩家选择的牌列表

#发牌相关
var 是否发牌 := false
var 发牌数 := 0
var 操作禁止 := true

#出牌相关
var 当前选择牌: Node:
    set(值): # 当值被改变时执行函数
        当前选择牌 = 值
        if (值 == null):
            当前选择.text = "未选择"
        else:
            当前选择.text = 值.牌.花色 + 值.牌.点数

func _process(_delta: float):
    pass

func _input(event: InputEvent):
    点击牌(event)

func _ready():
    结算界面.再来一次.connect(开始游戏)
    开始游戏()

func 开始游戏():
    重置场景()
    开始发牌()

func 重置场景():
    for 牌 in 玩家手牌列表:
        牌.queue_free()
    for 牌 in 上家手牌列表:
        牌.queue_free()
    for 牌 in 下家手牌列表:
        牌.queue_free()
    玩家手牌列表.clear()
    上家手牌列表.clear()
    下家手牌列表.clear()
    初始牌堆.clear()
    玩家选择列表.clear()
    for i in 底牌展示.get_children():
        i.queue_free()
    for i in 打出牌堆.get_children():
        i.queue_free()
    初始化牌堆()
    背景播放器.stream = load("res://音频/bgm1.mp3")
    背景播放器.play()
    结算界面.visible = false
    发牌数 = 0
    是否发牌 = false
    操作禁止 = true
    发牌计时器.stop()
    当前选择牌 = null
    当前选择.text = "未选择"
    玩家选择列表UI.text = "玩家选择的牌:"

#重新把牌移动到位置列表中对应的位置
func 重置位置(位置列表:Array[Vector2]):
    if (位置列表.size() != 玩家手牌列表.size()):
        printerr("位置列表和手牌列表数量不对等!")
        return 0
    for i in range(0, 玩家手牌列表.size()):
        玩家手牌列表[i].移动到(位置列表[i])
        #玩家手牌列表[i].旋转到(位置列表[i].angle_to_point(手牌点.position) / (2 * PI) * 360 - 90)
        玩家手牌列表[i].旋转到(0)

#选择手牌后重新计算所有牌的位置
func 选牌位置计算(选牌:Node) -> Array[Vector2]:
    var 手牌数量 = 玩家手牌列表.size()
    var 选牌编号 = 玩家手牌列表.find(选牌)
    var 计算后位置: Array[Vector2] = 计算位置(手牌数量)
    var 左右最大牌数 = float(max(选牌编号, 手牌数量 - 选牌编号 - 1))
    var 曲线段长: float = 1.0 / (左右最大牌数 * 2.0)
    for 距中段数 in range(1, 左右最大牌数 + 1):
        if (选牌编号 - 距中段数 >= 0):
            手牌线点.progress_ratio = 1.0 / (手牌数量 + 1) * (选牌编号 - 距中段数 + 1)
            手牌线点.progress -= 选择分散距离 * 选择分散曲线.sample(曲线段长 * 距中段数)
            计算后位置[选牌编号 - 距中段数] = 手牌线点位置()
        if (选牌编号 + 距中段数 <= 手牌数量 - 1):
            手牌线点.progress_ratio = 1.0 / (手牌数量 + 1) * (选牌编号 + 距中段数 + 1)
            手牌线点.progress += 选择分散距离 * 选择分散曲线.sample(曲线段长 * 距中段数)
            计算后位置[选牌编号 + 距中段数] = 手牌线点位置()
    return 计算后位置

#从左到右重新排序手牌的显示z_index排序
func 手牌显示排序():
    var 层数 = 0;
    for 手牌 in 玩家手牌列表:
        手牌.z_index = 层数
        层数 += 1

#按手牌数量在手牌线上计算每一个牌的位置点，使其平均分布在手牌排列线上
func 计算位置(手牌数量:int) -> Array[Vector2]:
    var 位置列表: Array[Vector2] = []
    var 分段长: float = 1.0 / (手牌数量 + 1)
    for i in range(1, 手牌数量 + 1):
        手牌线点.progress_ratio = 分段长 * i
        位置列表.append(手牌线点位置())
    return 位置列表

#返回手牌线点的绝对位置
func 手牌线点位置() -> Vector2:
    var 位置: Vector2 = 手牌线点.position + 手牌线点.get_parent().position + 手牌线点.get_parent().get_parent().position
    return 位置

#给玩家发一张扑克牌
func 玩家发牌(牌型:扑克牌类):
    var 牌 = 扑克牌.instantiate()
    add_child(牌)
    牌.connect("鼠标进入", 鼠标进入手牌)
    牌.connect("鼠标离开", 鼠标离开手牌)
    牌.name = "玩家手牌" + str(牌型.花色 + 牌型.点数)
    牌.更新牌(牌型)
    玩家手牌列表.append(牌)
    $玩家牌数显示.更新牌数(玩家手牌列表.size())
    牌.position = 中心点.position
    牌.rotation_degrees = 0
    重置位置(计算位置(玩家手牌列表.size()))

#给对家发一张扑克牌
func 对家发牌(对家:Node, 牌型:扑克牌类):
    var 牌 = 扑克牌.instantiate()
    对家.add_child(牌)
    牌.更新牌(牌型)
    牌.翻面()
    牌.position = 中心点.position - 对家.position
    牌.rotation_degrees = 0
    牌.移动到(对家.position - 对家.position)
    if 对家.name == "下家点":
        下家手牌列表.append(牌)
    elif 对家.name == "上家点":
        上家手牌列表.append(牌)

#把玩家的手牌按照斗地主的牌点数花色大小从右到左排列
func 排序手牌():
    var 手牌复制: Array[Node] = 玩家手牌列表.duplicate()
    手牌复制.sort_custom(扑克牌类.比较扑克大小)
    手牌复制.reverse()
    for i in 玩家手牌列表:
        i.queue_free()
    玩家手牌列表.clear()
    for i in 手牌复制:
        var 牌 = 扑克牌.instantiate()
        add_child(牌)
        牌.connect("鼠标进入", 鼠标进入手牌)
        牌.connect("鼠标离开", 鼠标离开手牌)
        牌.name = "玩家手牌" + str(i.牌.花色 + i.牌.点数)
        牌.更新牌(i.牌)
        玩家手牌列表.append(牌)
        牌.position = i.position
        牌.rotation_degrees = 0
    重置位置(计算位置(玩家手牌列表.size()))
    操作禁止 = false

#创建一副扑克牌，并打乱它
func 初始化牌堆():
    初始牌堆.clear()
    初始牌堆 = 扑克牌类.扑克牌堆生成()

#开始发牌
func 开始发牌():
    初始化牌堆()
    牌堆牌数显示.visible = true
    是否发牌 = true
    发牌计时器.start(发牌速度)

#给所有玩家发牌并且留三张
func 发牌():
    if (初始牌堆.size() == 3):
        是否发牌 = false
        return 0
    var 位置数 = 发牌数 % 3
    match 位置数:
        0: 玩家发牌(初始牌堆.pop_front())
        1: 对家发牌(下家点, 初始牌堆.pop_front())
        2: 对家发牌(上家点, 初始牌堆.pop_front())
    发牌数 += 1
    音效播放器.stream = load("res://音频/发牌音效.mp3")
    if !音效播放器.playing:
        音效播放器.play()
    牌堆牌数显示.更新牌数(初始牌堆.size())
    下家牌数显示.更新牌数(下家手牌列表.size())
    上家牌数显示.更新牌数(上家手牌列表.size())

func 发底牌(对象:牌手):
    var 底牌堆: Array[扑克牌类] = 初始牌堆.duplicate()
    for 牌 in 初始牌堆:
        match 对象:
            牌手.玩家: 玩家发牌(牌)
            牌手.上家: 对家发牌(上家点, 牌)
            牌手.下家: 对家发牌(下家点, 牌)
    初始牌堆.clear()
    for i in 底牌展示.get_children():#删除牌堆UI中的牌
        i.queue_free()
    var 底牌列表 = 底牌堆
    底牌列表.sort_custom(扑克牌类.比较扑克大小)#把选择的牌排序
    for i in 底牌列表:#在低牌UI中添加选择的牌
        var 牌 = 扑克牌.instantiate()
        底牌展示.add_child(牌)
        牌.name =str(i.花色 + i.点数)
        牌.更新牌(i)    
    牌堆牌数显示.visible = false
    排序手牌()

func 牌手打出牌(打出牌手:牌手,牌手选择列表:Array[Node]):
    if 牌手选择列表.size() == 0:
        return
    var 打出牌信息:扑克牌类.牌型信息 = 扑克牌类.判断牌型(扑克牌类.类型转换(牌手选择列表))
    if 打出牌信息.牌型 == "无牌型":
        return 0
    牌型播报(打出牌信息)
    if 打出牌信息.牌型 == "炸弹" or 打出牌信息.牌型 == "王炸":
        背景播放器.stream = load("res://音频/bgm2.mp3")
        背景播放器.play()
    print("%s打出了%s,头点数是%s,尾点数是%s" %[打出牌手,打出牌信息.牌型,打出牌信息.头点数,打出牌信息.尾点数])
    var 牌手手牌列表
    match 打出牌手:
        牌手.玩家:
            牌手手牌列表 = 玩家手牌列表
        牌手.上家:
            牌手手牌列表 = 上家手牌列表
        牌手.下家:
            牌手手牌列表 = 下家手牌列表
    for 打出牌 in 牌手选择列表:
        牌手手牌列表.erase(打出牌)
        打出牌.queue_free()
    #在牌堆ui中显示打出的牌
    for i in 打出牌堆.get_children():#删除牌堆UI中的牌
        i.queue_free()
    var 选择牌列表 = 扑克牌类.类型转换(牌手选择列表)
    选择牌列表.sort_custom(扑克牌类.比较扑克大小)#把选择的牌排序
    for i in 选择牌列表:#在牌堆UI中添加选择的牌
        var 牌 = 扑克牌.instantiate()
        打出牌堆.add_child(牌)
        牌.name =str(i.花色 + i.点数)
        牌.更新牌(i)
    if 打出牌手==牌手.玩家:#如果是玩家则额外执行的事件
        重置位置(计算位置(玩家手牌列表.size()))
        玩家选择列表.clear()
        排序手牌()
    match 打出牌手:
        牌手.玩家:
            玩家牌数显示.更新牌数(玩家手牌列表.size())
            if 玩家手牌列表.size()==0:
                游戏结束(牌手.玩家)
            elif 玩家手牌列表.size()==1:
                提示播报播放器.stream=load("res://音频/我就一张牌啦.mp3")
                提示播报播放器.play()
            elif 玩家手牌列表.size()==2:
                提示播报播放器.stream=load("res://音频/我就两张牌啦.mp3")
                提示播报播放器.play()
        牌手.上家:
            上家牌数显示.更新牌数(上家手牌列表.size())
            if 上家手牌列表.size()==0:
                游戏结束(牌手.上家)
            elif 上家手牌列表.size()==1:
                提示播报播放器.stream=load("res://音频/我就一张牌啦.mp3")
                提示播报播放器.play()
            elif 上家手牌列表.size()==2:
                提示播报播放器.stream=load("res://音频/我就两张牌啦.mp3")
                提示播报播放器.play()
        牌手.下家:
            下家牌数显示.更新牌数(下家手牌列表.size())
            if 下家手牌列表.size()==0:
                游戏结束(牌手.下家)
            elif 下家手牌列表.size()==1:
                提示播报播放器.stream=load("res://音频/我就一张牌啦.mp3")
                提示播报播放器.play()
            elif 下家手牌列表.size()==2:
                提示播报播放器.stream=load("res://音频/我就两张牌啦.mp3")
                提示播报播放器.play()
    音效播放器.stream=load("res://音频/啪音效.mp3")
    音效播放器.play()

func 游戏结束(赢家:牌手):
    if 赢家:
        结算界面.胜利()
        背景播放器.stream=load("res://音频/胜利.mp3")
    else:
        结算界面.失败()
        背景播放器.stream=load("res://音频/失败.mp3")
    背景播放器.play()

func 鼠标进入手牌(对象:Panel):
    当前选择牌 = 对象
    重置位置(选牌位置计算(对象))

func 鼠标离开手牌(_对象: Panel):
    当前选择牌 = null
    重置位置(计算位置(玩家手牌列表.size()))

func 点击牌(event):
    #如果鼠标按下时有选中的牌，则调用选中函数
    if (event is InputEventMouseButton) and !操作禁止:
        if (event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
            if (当前选择牌 != null):
                当前选择牌.选中()
                if (当前选择牌.是否被选中):
                    玩家选择列表.append(当前选择牌)
                else:
                    玩家选择列表.erase(当前选择牌)
                var 牌列表: Array[String] = []
                for 牌 in 玩家选择列表:
                    牌列表.append(牌.牌.花色 + 牌.牌.点数)
                玩家选择列表UI.text = "玩家选择的牌:" + str(牌列表)

func 牌型播报(牌型信息:扑克牌类.牌型信息):
    var 头点数 = str(扑克牌类.点数列表.find(牌型信息.头点数)+3)
    var 尾点数 ="_"+ str(扑克牌类.点数列表.find(牌型信息.尾点数)+3)
    if 扑克牌类.点数列表.find(牌型信息.尾点数) == -1:
        尾点数=""
    var 有点数牌型:Array[String] = [
        扑克牌类.牌型列表.单张,
        扑克牌类.牌型列表.对子,
        扑克牌类.牌型列表.三张,
        扑克牌类.牌型列表.三带一,
        扑克牌类.牌型列表.三带二,
        扑克牌类.牌型列表.炸弹,
        扑克牌类.牌型列表.顺子,
        ]
    if 牌型信息.牌型 in 有点数牌型:
        var 音频地址 = "res://音频/牌型语音/%s/%s_%s%s.mp3"%[牌型信息.牌型,牌型信息.牌型,头点数,尾点数]
        人声播报播放器.stream = load(音频地址)
        人声播报播放器.play()
    else:
        var 音频地址 = "res://音频/牌型语音/%s.mp3"%[牌型信息.牌型]
        人声播报播放器.stream = load(音频地址)
        人声播报播放器.play()

func _on_打出按钮_button_down():
    牌手打出牌(牌手.玩家,玩家选择列表)

func _on_发牌按钮_button_down():
    开始发牌()

func _on_排序按钮_button_down():
    排序手牌()

func _on_发牌计时器_timeout():
    if (!是否发牌):
        发牌计时器.stop()
        是否发牌 = false
        发底牌(牌手.玩家)
    else:
        发牌()

#位置改变时重置手牌位置
func _on_item_rect_changed():
    重置位置(计算位置(玩家手牌列表.size()))

func _on_重发_button_down():
    重置场景()
    开始发牌()
