extends Object


static func pascal_case(text):
	var arr = text.split(" ")
	var new_string = ""
	for word in arr:
		new_string += word.capitalize()
	return new_string
	

static func snake_case(text):
	return text.to_lower().replace(" ", "_")
