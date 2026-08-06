class_name GameOverPanel
extends CanvasLayer

signal restart_requested

@onready var final_score_label: Label = %FinalScoreLabel
@onready var restart_button: Button = %RestartButton
@onready var panel_container: Control = $PanelContainer

func _ready() -> void:
	hide_panel()
	restart_button.pressed.connect(_on_restart_button_pressed)

func show_panel(final_score: int) -> void:
	final_score_label.text = "FINAL SCORE: %d" % final_score
	panel_container.visible = true

func hide_panel() -> void:
	panel_container.visible = false

func _on_restart_button_pressed() -> void:
	restart_requested.emit()
