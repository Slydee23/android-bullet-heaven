class_name SaveSlots
extends RefCounted
## Drei Speicherplätze (Spielstände). Jeder Platz ist ein eigener Ordner user://slots/<n>/ mit
## slot.json (Name, angelegt, zuletzt gespielt) und run.save (laufende Expedition, siehe RunSave).
## Später kommt profile.save dazu (Dorf, Rüstung, Freischaltungen, E6). Ein Platz bleibt nach dem Tod bestehen,
## nur die Expedition darin endet.
## Der gewählte Platz (current) gilt, bis ein anderer gewählt wird, auch über Szenenwechsel hinweg (statische Variable).

const COUNT := 3
const ROOT := "user://slots"
const META_FILE := "slot.json"
## Höchstlänge des Namens
const NAME_MAX_LENGTH := 16
## Alter Spielstand aus der Zeit vor den Speicherplätzen (wird einmalig in Platz 1 übernommen)
const LEGACY_RUN_PATH := "user://run.save"

## Gewählter Platz (0 bis COUNT - 1)
static var current := 0


static func slot_dir(index: int) -> String:
	return "%s/%d" % [ROOT, index + 1]


static func current_dir() -> String:
	return slot_dir(current)


static func exists(index: int) -> bool:
	return FileAccess.file_exists(slot_dir(index) + "/" + META_FILE)


static func any_exists() -> bool:
	for i in COUNT:
		if exists(i):
			return true
	return false


## Name, Zeitpunkte (Unix-Sekunden) eines Platzes; leer, wenn der Platz frei ist
static func read_meta(index: int) -> Dictionary:
	var path := slot_dir(index) + "/" + META_FILE
	if not FileAccess.file_exists(path):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed if parsed is Dictionary else {}


## Legt einen neuen Spielstand an (ein alter auf diesem Platz wird vorher gelöscht) und wählt ihn
static func create(index: int, slot_name: String) -> void:
	delete(index)
	DirAccess.make_dir_recursive_absolute(slot_dir(index))
	var now := Time.get_unix_time_from_system()
	_write_meta(index, {"name": clean_name(slot_name, index), "created": now, "last_played": now})
	current = index


## Zuletzt gespielt auf jetzt setzen (bei jedem Speichern). Fehlt die Platz-Datei (z. B. Run direkt aus dem Editor gestartet),
## wird sie mit einem Standardnamen angelegt.
static func touch(index: int) -> void:
	var meta := read_meta(index)
	if meta.is_empty():
		DirAccess.make_dir_recursive_absolute(slot_dir(index))
		meta = {"name": default_name(index), "created": Time.get_unix_time_from_system()}
	meta["last_played"] = Time.get_unix_time_from_system()
	_write_meta(index, meta)


## Löscht einen Spielstand samt allen Dateien
static func delete(index: int) -> void:
	var dir := slot_dir(index)
	if not DirAccess.dir_exists_absolute(dir):
		return
	for file in DirAccess.get_files_at(dir):
		DirAccess.remove_absolute(dir + "/" + file)
	DirAccess.remove_absolute(dir)


static func default_name(index: int) -> String:
	return TranslationServer.translate("SLOT_NAME_DEFAULT") % (index + 1)


## Name gekürzt und ohne Leerzeichen am Rand; leer wird zum Standardnamen
static func clean_name(slot_name: String, index: int) -> String:
	var result := slot_name.strip_edges().left(NAME_MAX_LENGTH)
	return result if not result.is_empty() else default_name(index)


## „21.11.2026, 18:30“ in Ortszeit
static func format_time(unix: float) -> String:
	var bias_minutes := int(Time.get_time_zone_from_system().get("bias", 0))
	var d := Time.get_datetime_dict_from_unix_time(int(unix) + bias_minutes * 60)
	return "%02d.%02d.%04d, %02d:%02d" % [d.day, d.month, d.year, d.hour, d.minute]


## Übernimmt einen Spielstand aus der Zeit vor den Speicherplätzen einmalig in Platz 1 (nur, wenn der frei ist)
static func migrate_legacy() -> void:
	if not FileAccess.file_exists(LEGACY_RUN_PATH) or exists(0):
		return
	create(0, default_name(0))
	DirAccess.rename_absolute(LEGACY_RUN_PATH, slot_dir(0) + "/run.save")


static func _write_meta(index: int, meta: Dictionary) -> void:
	var file := FileAccess.open(slot_dir(index) + "/" + META_FILE, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(meta, "\t"))
