extends Node

var file_name = "user://gameplay_report.csv"
var current_line = 1

func _init():
	var file = File.new()
	file.open(file_name, File.WRITE)
	file.close()
	append_to_file(PoolStringArray([
		"id", 
		"time", 
		"entity_type", 
		"entity_id", 
		"pos_x",
		"pos_y",
		"event_type", 
	]))

func report_event(entity, entity_type, event_details):
	var line = PoolStringArray([
		current_line, 
		OS.get_ticks_msec(), 
		entity_type, 
		entity.get_instance_id(), 
		entity.global_position.x,
		entity.global_position.y,
		event_details, 
	])
	append_to_file(line)
	current_line += 1

func append_to_file(line):
	var file = File.new()
	file.open(file_name, File.READ_WRITE)
	file.seek_end()
	file.store_csv_line(line)
	file.close()