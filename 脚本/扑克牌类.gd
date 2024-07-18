class_name 扑克牌类

var 花色:String
var 点数:String

static  var 牌型列表=["","单张","对子","三张","三带一","三带二","顺子","连对","飞机","炸弹","王炸"]
static  var 点数列表:Array[String] = ["3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A", "2", "小王", "大王"]
static  var 花色列表:Array[String] = ["红桃", "方片", "黑桃", "梅花"]

func _init(花色参数="",点数参数=""):
	花色=花色参数
	点数=点数参数

##根据选择牌列表判断牌型
static func 判断牌型(选择牌列表:Array[扑克牌类]=[])->int:
	var 选择点数:Array[int]=[]
	for 牌 in 选择牌列表:#获取选择牌的点数并转化为数字方便对比
		选择点数.append(点数列表.find(牌.点数))
	var 牌数:int=选择牌列表.size()
	var 点数字典=统计(选择点数)
	print(点数字典)
	#判断单张
	if 牌数==1:
		return 1
	#判断对子
	if (牌数==2 and 选择牌列表[0].点数==选择牌列表[1].点数):
		return 2
	#判断三张
	if (牌数==3 and 选择牌列表[0].点数==选择牌列表[1].点数 and 选择牌列表[1].点数==选择牌列表[2].点数):
		return 3
	#判断三带一
	if (牌数==4 and 选择牌列表[0].点数==选择牌列表[2].点数 and 选择牌列表[0].点数==选择牌列表[3].点数):
		return 4
	#判断三带二
	if (牌数==5 and 选择牌列表[0].点数==选择牌列表[2].点数 and 选择牌列表[0].点数==选择牌列表[3].点数 and 选择牌列表[0].点数==选择牌列表[4].点数):
		return 5
	#判断顺子
	if (牌数>4 and 选择牌列表[0].点数==选择牌列表[3].点数 and 选择牌列表[1].点数==选择牌列表[4].点数):
		return 6
	return 0

static func 排序扑克列表(选择牌列表:Array[扑克牌类]=[])->Array[扑克牌类]:
	选择牌列表.sort_custom(比较扑克大小)
	选择牌列表.reverse()
	return 选择牌列表

static func 比较扑克大小(牌一,牌二)->bool:
	var 牌1:扑克牌类
	var 牌2:扑克牌类
	if(牌一 is Node and 牌二 is Node):
		牌1=牌一.牌
		牌2=牌二.牌
	elif(牌一 is 扑克牌类 and 牌二 is 扑克牌类):
		牌1=牌一
		牌2=牌二
	else:
		return false
	if(牌1.点数=="大王"):
		return false
	if(牌2.点数=="大王"):
		return true
	if(牌1.点数=="小王" and 牌2.点数!="大王"):
		return false
	if(牌2.点数=="小王" and 牌1.点数!="大王"):
		return true
	if(点数列表.find(牌1.点数)>点数列表.find(牌2.点数)):
		return false
	if(点数列表.find(牌1.点数)<点数列表.find(牌2.点数)):
		return true
	if(花色列表.find(牌1.花色)>花色列表.find(牌2.花色)):
		return false
	return true

##生成一个扑克牌牌堆,是否打乱:是否将扑克牌打乱，默认是true。结果将会返回一个扑克牌牌堆
static func 扑克牌堆生成(是否打乱:bool=true)->Array[扑克牌类]:
	var 牌堆:Array[扑克牌类]=[]
	for 花色_ in 花色列表:#添加扑克牌
		for i in range(13):
			牌堆.append(扑克牌类.new(花色_, 点数列表[i]))
	牌堆.append(扑克牌类.new("", "大王"))#添加大小王
	牌堆.append(扑克牌类.new("", "小王"))
	if 是否打乱:
		牌堆.shuffle() # 打乱牌堆
	return 牌堆

static func 类型转换(输入列表:Array[Node])->Array[扑克牌类]:
	var 输出列表:Array[扑克牌类]=[]
	for 牌 in 输入列表:
		输出列表.append(牌.牌)
	return 输出列表

static func 统计(输入数组:Array)-> Dictionary:
	var 统计字典:Dictionary={}
	for 元素 in 输入数组:
		if 统计字典.has(元素):
			统计字典[元素]+=1
		else:
			统计字典[元素]=1
	return 统计字典