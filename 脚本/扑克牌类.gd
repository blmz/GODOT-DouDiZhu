class_name 扑克牌类

var 花色:String
var 点数:String

static  var 牌型列表=["无牌型","单张","对子","三张","三带一","三带二","顺子","连对","飞机","炸弹","王炸"]
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
    选择点数.sort()#排序
    var 牌数:int=选择牌列表.size()
    var 点数字典=统计(选择点数)
    for i in range(点数字典.size()):
        print(点数列表[点数字典.keys()[i]],"的数量是:",点数字典.values()[i])
    #判断单张
    if 牌数==1:
        return 牌型列表.find("单张")
    #判断对子
    if (牌数==2 and 点数字典.size()==1):
        return 牌型列表.find("对子")
    #判断三张
    if (牌数==3 and 点数字典.size()==1):
        return 牌型列表.find("三张")
    #判断三带一
    if (牌数==4 and 3 in 点数字典.values() and 1 in 点数字典.values()):
        return 牌型列表.find("三带一")
    #判断三带二
    if (牌数==5 and 3 in 点数字典.values() and 2 in 点数字典.values()):
        return 牌型列表.find("三带二")
    #判断顺子
    if (牌数>4 and 点数字典.size()==牌数 ):
        var 是否是顺子:bool=false
        var 选择点数列表 = 点数字典.keys()
        点数列表.sort()
        for i in range(选择点数列表.size()): 
            if i==选择点数列表.size()-1:
                break
            if (选择点数列表[i+1]-选择点数列表[i]==1 and 点数字典[选择点数列表[i+1]]==1):
                是否是顺子=true
            else:
                return 牌型列表.find("无牌型")
        if 是否是顺子:
            return 牌型列表.find("顺子")
    #判断连对
    if (牌数>=6 and 点数字典.size()==牌数 and 牌数%2==0):
        var 是否是连对:bool=false
        var 选择点数列表 = 点数字典.keys()
        点数列表.sort()
        for i in range(选择点数列表.size()): 
            if i==选择点数列表.size()-1:
                break
            if (选择点数列表[i+1]-选择点数列表[i]==1 and 点数字典[选择点数列表[i+1]]==2):
                是否是连对=true
            else:
                是否是连对=false
                break
        if 是否是连对:
            return 牌型列表.find("连对")
    
    return 牌型列表.find("无牌型")

static func 排序扑克列表(选择牌列表: Array[扑克牌类] = []) -> Array[扑克牌类]:
    # 直接通过比较函数控制降序，避免二次反转
    选择牌列表.sort_custom(比较扑克大小)
    return 选择牌列表

static func 比较扑克大小(牌一, 牌二) -> bool:
    # 1. 统一类型处理（支持Node和扑克牌类直接比较）
    var 牌1: 扑克牌类
    if (牌一 is Node):
        牌1 = 牌一.牌 as 扑克牌类
    else:
        牌1 = 牌一 as 扑克牌类
    
    var 牌2: 扑克牌类
    if (牌二 is Node):
        牌2 = 牌二.牌 as 扑克牌类
    else:
        牌2 = 牌二 as 扑克牌类
    if not (牌1 and 牌2):
        return false
    # 2. 特殊牌优先级判断（大王/小王）
    match [牌1.点数, 牌2.点数]:
        ["大王", _]: return false  # 牌1是大王时永远最大
        [_, "大王"]: return true   # 牌2是大王时牌1较小
        ["小王", _]: return false if 牌2.点数 != "大王" else true
        [_, "小王"]: return true if 牌1.点数 != "大王" else false

    # 3. 点数比较（缓存查找结果避免重复计算）
    var 点数1 = 点数列表.find(牌1.点数)
    var 点数2 = 点数列表.find(牌2.点数)
    if 点数1 != 点数2:
        return 点数1 < 点数2  # 降序排列

    # 4. 花色比较
    return 花色列表.find(牌1.花色) < 花色列表.find(牌2.花色)

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
