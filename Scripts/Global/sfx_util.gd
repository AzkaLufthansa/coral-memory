class_name SfxUtil

static func first_available(paths: Array) -> AudioStream:
	for path in paths:
		if ResourceLoader.exists(path):
			var stream := load(path) as AudioStream
			if stream:
				return stream
	return null
