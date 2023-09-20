class_name wire

extends Node

var from # Object and output pin the wire is coming from
var to # Objects and pins that the wire is connected to
var type # Bus or single wire
var group # Named group
var value # Value of bus data
var state # For single wire (high/low/floating)
var custom_color # Color of the wire when it is in a static view state
