
extends Control

@export var 游戏主场景:PackedScene

@onready var 动画播放器:AnimationPlayer = $"动画播放器"
@onready var 设置界面:TextureRect = $"设置界面"
@onready var 音乐开关:Button = $"设置界面/音乐开关"
@onready var 音量滑块:Slider = $"设置界面/音量滑块"

func _ready():
    设置界面.visible = false
    动画播放器.queue("进场动画")
    动画播放器.queue("图标扭动")


#三个按钮的点击事件
func 开始游戏():
    get_tree().change_scene_to_packed(游戏主场景)

func 设置():
    if 设置界面.visible:
        设置界面.visible = false
    else:
        设置界面.visible = true

func 退出游戏():
    get_tree().quit()

func on_音乐开关_pressed(is_on:bool):
    if !is_on:
        AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(0.0))
    else:
        AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(1.0))

func 音量滑动(_是否改变:bool):
    var  音量 = 音量滑块.value/100.0
    #设置游戏音量为音量
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(音量))
    print(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))
