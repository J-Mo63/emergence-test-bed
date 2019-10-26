extends Node

var file_name = "user://gameplay_report.csv"

func _init():
	var file = File.new()
	file.open(file_name, File.WRITE)
	file.close()

func report_event(event_details):
	var line = PoolStringArray([1, "event", event_details])
	append_to_file(line)

func append_to_file(line):
	var file = File.new()
	file.open(file_name, File.READ_WRITE)
	file.seek_end()
	file.store_csv_line(line)
	file.close()