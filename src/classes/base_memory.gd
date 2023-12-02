extends Part

class_name BaseMemory

var values = []
var probes = []

func update_probes():
	for probe in probes:
		probe.update_data()
