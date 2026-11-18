class_name WeaponCatalog
extends Resource
## Alle Waffen des Spiels (data/weapons/weapon_catalog.tres). Level-Up-Pool und später die Startwaffen-Wahl im Hub ziehen nur
## aus freigeschalteten Waffen (zunächst default_unlocked, später zusätzlich die Freischaltungen aus dem Profil-Spielstand).

@export var weapons: Array[WeaponData] = []


## Freigeschaltete Waffen. Erzeugt ein neues Array: nur beim Level-Up aufrufen, nicht pro Frame.
func unlocked() -> Array[WeaponData]:
	var result: Array[WeaponData] = []
	for data in weapons:
		if data.default_unlocked:
			result.append(data)
	return result
