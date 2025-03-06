extends Node3D

@onready var player: CharacterBody3D = $ProtoController
@onready var entrance: Area3D = $Top
@onready var exit: Area3D = $Bottom
@onready var torch_mounted_2: StaticBody3D = $Building/TorchMounted2
@onready var label_bottom: Label3D = $LabelBottom
@onready var label_top: Label3D = $LabelTop

var label: int = 0;

var anomalies = {
	"light_change":{
		"probability" : 50,
	}
}


var is_anomaly: bool;
var coming_from_area: Area3D;
var torch_light;
var original_light_color;


func change_torch_color() -> void:
	torch_light.light_color = Color(1, 0, 0)
	is_anomaly = true;


func choose_random_anomaly() -> void:
	var anomaly_keys = anomalies.keys()
	var chosen_anomaly = anomaly_keys.pick_random()
	var anomaly = anomalies[chosen_anomaly]
	
	if randi_range(1, 100) <= anomaly["probability"]:
		trigger_anomaly(chosen_anomaly)


func trigger_anomaly(anomaly_name: String) -> void:
	match anomaly_name:
		"light_change":
			change_torch_color()


func reset_all_anomalies() -> void:
	torch_light.light_color = original_light_color
	is_anomaly = false


func _ready() -> void:
	torch_light = torch_mounted_2.find_child("OmniLight3D")
	original_light_color= torch_light.light_color
	is_anomaly = false
	coming_from_area = entrance
	print("coming from entrance")


func _physics_process(_delta: float) -> void:
	label_bottom.text = str(label)
	label_top.text = str(label)


func teleport_player(area: Area3D, target_area: Area3D) -> void:
	var relative_position = player.global_transform.origin - area.global_transform.origin
	player.global_transform.origin = target_area.global_transform.origin + relative_position


func attribute_points(crossing_area: Area3D) -> void:
	if is_anomaly:
		if coming_from_area != crossing_area:
			label += 1
		else:
			label = 0
	else:
		if coming_from_area == crossing_area:
			label += 1
		else:
			label = 0


func _on_bottom_body_entered(_body: Node3D) -> void:
	attribute_points(entrance)
	reset_all_anomalies()
	coming_from_area = entrance;
	teleport_player(exit, entrance)
	is_anomaly = false
	choose_random_anomaly()


func _on_top_body_entered(_body: Node3D) -> void:
	attribute_points(exit)
	coming_from_area = exit;
	reset_all_anomalies()
	teleport_player(entrance, exit)
	is_anomaly = false
	choose_random_anomaly()
