extends Node
class_name ApiHelper

static func _headers_to_dict(headers: Array) -> Dictionary:
	var result := {}
	for header in headers:
			var parts = header.split(":", false, 2) # false = keep empty parts, 2 = maxsplit
			if parts.size() == 2:
					var key = parts[0].strip_edges().to_lower()
					var value = parts[1].strip_edges()
					result[key] = value
	return result


static func parse_body(body: PackedByteArray):
	return parse_json_with_int_fix(body)

# Godot JSON parser can't handle integers, it convert them to floats
# This function fixes this by converting floats that are actually integers to integers
static func parse_json_with_int_fix(body: PackedByteArray):
	var json := JSON.new()
	var result := json.parse(body.get_string_from_utf8())
	if result != OK:
		push_error("JSON parsing failed: %s" % result)
		return {}

	return _fix_numbers(json.get_data())
	
static func _fix_numbers(value):
	if typeof(value) == TYPE_DICTIONARY:
		var fixed = {}
		for k in value.keys():
			fixed[k] = _fix_numbers(value[k])
		return fixed
	elif typeof(value) == TYPE_ARRAY:
		var fixed_arr = []
		for v in value:
			fixed_arr.append(_fix_numbers(v))
		return fixed_arr
	elif typeof(value) == TYPE_FLOAT:
		# si la valeur est un entier déguisé → convertis en int
		if int(value) == value:
			return int(value)
		return value
	else:
		return value