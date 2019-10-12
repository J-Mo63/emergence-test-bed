class_name Reporter

func report_event(event_details):
	var line = PoolStringArray([1, "event", event_details])
	append_to_file(line)

func append_to_file(line):
	var file = File.new()
	file.open("user://gameplay_report.csv", File.READ_WRITE)
	file.seek_end()
	file.store_csv_line(line)
	file.close()