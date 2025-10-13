extends Node

var logs: Array[String] = []

signal log_updated(new_entry: String)

func add_entry(entry: String):
    logs.append(entry)
    emit_signal("log_updated", entry)
    print("[LOG] ", entry) # utile aussi dans la console