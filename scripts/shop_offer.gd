class_name ShopOffer
extends RefCounted
## Ein Angebot im Rastplatz-Shop: ein Stat-Bonus (UpgradeData) in einer Seltenheit mit Preis in Seelen.

var upgrade: UpgradeData
var rarity := Rarity.COMMON
var price := 0
## Schon gekauft: die Karte bleibt als leerer Platz stehen
var bought := false
