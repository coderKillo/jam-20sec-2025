class_name Math


static func average(array: Array, path: NodePath) -> float:
	var sum := 0.0
	for item in array:
		sum += item.get_indexed(path)
	return sum / array.size()
