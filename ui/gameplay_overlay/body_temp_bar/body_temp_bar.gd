extends Control

@onready var bt_progressbar = %BTProgressbar

func update_val(val: float):
	bt_progressbar.value = val
