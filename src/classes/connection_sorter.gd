class_name ConnectionSorter

# This is used to sort the order of output connections from a part
# so that the shortest paths to common parts in the same net are
# processed first to make the simulation behave like a real circuit
# where propagation delays effect the sequence of logic levels
# hitting inputs to chips. This can make a difference in behaviour for
# feedback circuits such as flip flops.
# Also, this class will be used in the schematic and in blocks for consistency
# of behaviour.

# This is set to avoid pointless deep evaluation
const MAX_TREE_DEPTH = 5

static func set_part_outputs(part, all_connections, sort = true):
	part.connections = []
	# Get a list of all parts that the "from part" connects to and their path lengths
	var sets = {}
	for con in all_connections:
		if part.name == con.from_node:
			var parts = { con.to_node: 1 }
			get_connection_tree(con.to_node, parts, 2, all_connections)
			sets[con] = parts
	part.connections = sets.keys()
	if sets.size() > 1 and sort:
		# Sort the connections
		part.connections.sort_custom(func (a, b): return compare_path_lengths(sets[a], sets[b]))


static func compare_path_lengths(a, b):
	for part in a:
		if b.has(part):
			return b[part] > a[part]
	return true


static func get_connection_tree(part_name, parts, depth, all_connections):
	if depth > MAX_TREE_DEPTH:
		return
	for con in all_connections:
		if con.from_node == part_name:
			parts[con.to_node] = depth
			get_connection_tree(con.to_node, parts, depth + 1, all_connections)
