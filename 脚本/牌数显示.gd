extends TextureRect

@onready var 牌数:Label = $"牌数"

func 更新牌数(数量:int):
	牌数.text=str(数量)
