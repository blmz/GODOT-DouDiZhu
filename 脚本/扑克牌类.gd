class_name 扑克牌类

var 花色:String
var 点数:String

static var 点数列表:Array[String] = ["3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A", "2", "小王", "大王"]
static var 花色列表:Array[String] = ["红桃", "方片", "黑桃", "梅花"]

static var 牌型列表={
    无牌型="无牌型",
    单张="单张",
    对子="对子",
    三张="三张",
    三带一="三带一",
    三带二="三带二",
    顺子="顺子",
    连对="连对",
    飞机="飞机",
    炸弹="炸弹",
    四带一="四带一",
    四带二="四带二",
    王炸="王炸"
}

class 牌型信息:
    var 牌型:String
    var 头点数:String
    var 尾点数:String

    func _init(牌型参数:String=扑克牌类.牌型列表.无牌型,头点数参数:String="",尾点数参数:String=""):
        牌型=牌型参数
        头点数=头点数参数
        尾点数=尾点数参数
func _init(花色参数="",点数参数=""):
    花色=花色参数
    点数=点数参数

##根据选择牌列表判断牌型
static func 判断牌型(选择牌列表:Array[扑克牌类]=[])->牌型信息:
    var 牌型信息返回值:牌型信息 = 牌型信息.new()
    if 选择牌列表.size() == 0:
        return 牌型信息返回值

    var 选择点数:Array[int] = []
    for 牌 in 选择牌列表:
        选择点数.append(点数列表.find(牌.点数))
    选择点数.sort()

    var 点数字典 = 统计(选择点数)

    # 单张
    if 选择牌列表.size() == 1:
        牌型信息返回值.牌型 = 牌型列表.单张
        牌型信息返回值.头点数 = 点数列表[点数字典.keys()[0]]
        return 牌型信息返回值

    # 对子
    if 选择牌列表.size() == 2 and 点数字典.size() == 1:
        牌型信息返回值.牌型 = 牌型列表.对子
        牌型信息返回值.头点数 = 点数列表[点数字典.keys()[0]]
        return 牌型信息返回值

    # 三张
    if 选择牌列表.size() == 3 and 点数字典.size() == 1:
        牌型信息返回值.牌型 = 牌型列表.三张
        牌型信息返回值.头点数 = 点数列表[点数字典.keys()[0]]
        return 牌型信息返回值

    # 三带一
    if 选择牌列表.size() == 4 and 点数字典.size() == 2 and (3 in 点数字典.values()) and (1 in 点数字典.values()):
        牌型信息返回值.牌型 = 牌型列表.三带一
        牌型信息返回值.头点数 = 点数列表[点数字典.find_key(3)]
        return 牌型信息返回值
    # 三带二
    if 选择牌列表.size() == 5 and 点数字典.size() == 2 and (3 in 点数字典.values()) and (2 in 点数字典.values()):
        牌型信息返回值.牌型 = 牌型列表.三带二
        牌型信息返回值.头点数 = 点数列表[点数字典.find_key(3)]
        return 牌型信息返回值

    # 顺子
    if 选择牌列表.size() >= 5 and 点数字典.size() == 选择牌列表.size():
        if 是顺子(选择点数):
            牌型信息返回值.牌型 = 牌型列表.顺子
            牌型信息返回值.头点数 = 点数列表[选择点数[0]]
            牌型信息返回值.尾点数 = 点数列表[选择点数[-1]]
            return 牌型信息返回值

    # 连对
    if 选择牌列表.size() >= 6 and 选择牌列表.size() % 2 == 0 :
        if 是连对(选择点数):
            牌型信息返回值.牌型 = 牌型列表.连对
            牌型信息返回值.头点数 = 点数列表[选择点数[0]]
            牌型信息返回值.尾点数 = 点数列表[选择点数[-1]]
            return 牌型信息返回值

    # 飞机
    if 选择牌列表.size() >= 6 and 选择牌列表.size() % 3 == 0 :
        if 是飞机(选择点数):
            牌型信息返回值.牌型 = 牌型列表.飞机
            牌型信息返回值.头点数 = 点数列表[选择点数[0]]
            牌型信息返回值.尾点数 = 点数列表[选择点数[-1]]
            return 牌型信息返回值

    # 炸弹
    if 选择牌列表.size() == 4 and 点数字典.size() == 1:
        牌型信息返回值.牌型 = 牌型列表.炸弹
        牌型信息返回值.头点数 = 点数列表[选择点数[0]]
        return 牌型信息返回值

    # 四带一
    if 选择牌列表.size() == 5 and 点数字典.size() == 2 and (4 in 点数字典.values()) and (1 in 点数字典.values()):
        牌型信息返回值.牌型 = 牌型列表.四带一
        牌型信息返回值.头点数 = 点数列表[选择点数[0]]
        return 牌型信息返回值

    #四带二
    if 选择牌列表.size() == 6 and 点数字典.size() == 2 and (4 in 点数字典.values()) and (2 in 点数字典.values()):
        牌型信息返回值.牌型 = 牌型列表.四带二
        牌型信息返回值.头点数 = 点数列表[选择点数[0]]
        return 牌型信息返回值

    # 王炸
    if 选择牌列表.size() == 2:
        var 大王索引 = 点数列表.find("大王")
        var 小王索引 = 点数列表.find("小王")
        if 大王索引 in 点数字典.keys() and 小王索引 in 点数字典.keys():
            牌型信息返回值.牌型 = 牌型列表.王炸
            return 牌型信息返回值
    return 牌型信息返回值
# 检查是否为顺子
static func 是顺子(点数组:Array) -> bool:
    # 检查长度有效性
    if 点数组.size() < 5 or 点数组.size() > 12:  # 斗地主规则：顺子最少5张，最多13张（但A之后是2，无法形成13张顺子）
        return false
    
    # 检查是否包含禁止的牌型
    var 最大允许点数 = 点数列表.find("A")
    for 点 in 点数组:
        if 点 > 最大允许点数:
            return false
    
    # 去重检查
    var 去重点数:Array = []
    for 点 in 点数组:
        if 点 in 去重点数:
            return false  # 存在重复点数
        去重点数.append(点)
    
    # 排序后检查连续性
    去重点数.sort()
    for i in range(去重点数.size() - 1):
        if 去重点数[i+1] - 去重点数[i] != 1:
            return false
    return true

# 检查是否为连对
static func 是连对(点数组:Array) -> bool:
    # 检查长度有效性（至少3对，即6张牌）
    if 点数组.size() < 6 or 点数组.size() % 2 != 0:
        return false
    
    var 最大允许点数 = 点数列表.find("A")
    for 点 in 点数组:
        if 点 > 最大允许点数:
            return false
    
    # 统计每种点数的数量
    var 点数字典 = 统计(点数组)
    
    # 检查每个点数是否恰好出现两次
    for 点 in 点数字典.keys():
        if 点数字典[点] != 2:
            return false
    
    # 获取所有不同的点数并排序
    var 不同点数:Array = 点数字典.keys().duplicate()
    不同点数.sort()
    
    # 检查点数是否连续
    for i in range(不同点数.size() - 1):
        if 不同点数[i+1] - 不同点数[i] != 1:
            return false
    
    return true

# 检查是否为飞机
static func 是飞机(点数组:Array) -> bool:
    for i in range(0, 点数组.size(), 3):
        if i + 2 >= 点数组.size() or 点数组[i+1] - 点数组[i] != 0 or 点数组[i+2] - 点数组[i+1] != 0 or (i + 3 < 点数组.size() and 点数组[i+3] - 点数组[i+2] != 1):
            return false
    return true

## 比较扑克牌大小
static func 比较扑克大小(牌一, 牌二) -> bool:
    if 牌一 is String and 牌二 is String:
        return 点数列表.find(牌一) < 点数列表.find(牌二)
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
    
    # 2. 点数转换（缓存查找结果避免重复计算）
    var 点数1 = 点数列表.find(牌1.点数)
    var 点数2 = 点数列表.find(牌2.点数)
    # 4. 普通牌比较 - 先比点数，再比花色
    if 点数1 != 点数2:
        return 点数1 < 点数2  # 点数高的牌更大
    return 花色列表.find(牌1.花色) < 花色列表.find(牌2.花色)

static func 比较牌型大小(牌型一:牌型信息, 牌型二:牌型信息) -> bool:
    var 牌型一头点数 = 点数列表.find(牌型一.头点数)
    var 牌型二头点数 = 点数列表.find(牌型二.头点数)
    if 牌型一.牌型 == "无牌型":
        return true
    if 牌型二.牌型 == "无牌型":
        return true
    return 牌型一头点数 < 牌型二头点数

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
