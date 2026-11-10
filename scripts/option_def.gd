class_name OptionDef
extends RefCounted
## Beschreibung einer Option im Optionsmenü. Alle Optionen stehen in scripts/options_catalog.gd,
## das Menü baut daraus Reiter und Zeilen selbst.

enum Kind {
	TOGGLE,  ## An/Aus-Knöpfe für eine bool-Einstellung
	CHOICE,  ## Ein Knopf je Wert (z. B. Joystick-Seite)
	SLIDER,  ## Schieberegler mit Zahlenanzeige
}

## Kategorie-ID aus OptionsCatalog.CATEGORIES
var category: StringName
## Übersetzungs-Schlüssel der Beschriftung
var label_key: String
## Name der Eigenschaft im Autoload Settings
var setting: StringName
var kind := Kind.TOGGLE
## Nur CHOICE: Liste aus [Wert, Übersetzungs-Schlüssel]
var choices: Array = []
## Nur CHOICE, optional: func(value) -> bool, true = dieser Knopf ist gerade ausgegraut
var is_choice_disabled: Callable
## Nur SLIDER
var min_value := 0.0
var max_value := 100.0
var step := 1.0
var value_format := "%d"


static func toggle(category_id: StringName, label: String, setting_name: StringName) -> OptionDef:
	return _make(category_id, label, setting_name, Kind.TOGGLE)


static func choice(category_id: StringName, label: String, setting_name: StringName, values: Array,
		disabled_check := Callable()) -> OptionDef:
	var option := _make(category_id, label, setting_name, Kind.CHOICE)
	option.choices = values
	option.is_choice_disabled = disabled_check
	return option


static func slider(category_id: StringName, label: String, setting_name: StringName, minimum: float,
		maximum: float, step_size: float, format: String) -> OptionDef:
	var option := _make(category_id, label, setting_name, Kind.SLIDER)
	option.min_value = minimum
	option.max_value = maximum
	option.step = step_size
	option.value_format = format
	return option


static func _make(category_id: StringName, label: String, setting_name: StringName, option_kind: Kind) -> OptionDef:
	var option := OptionDef.new()
	option.category = category_id
	option.label_key = label
	option.setting = setting_name
	option.kind = option_kind
	return option
