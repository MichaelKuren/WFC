class_name Menu

extends Control

@export var wfc: WFCGenerator

func _ready() -> void:
	$MenuBox/LabelX.text = String.num(wfc.size.x)
	$MenuBox/LabelY.text = String.num(wfc.size.y)

func _on_x_value_changed(value: float) -> void:
	wfc.size.x = value
	$MenuBox/LabelX.text = String.num(value)

func _on_y_value_changed(value: float) -> void:
	wfc.size.y = value
	$MenuBox/LabelY.text = String.num(value)
