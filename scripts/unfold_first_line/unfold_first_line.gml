/// @description unfold_first_line(key) -> the one sentence a panel says
/// on its first visit (syst_nudge draws it at the foot of the room
/// until the panel has been closed once), or ""
function unfold_first_line(_key) {
	switch (_key) {
		case "upgrades":    return "credits buy a roll - an upgrade of a random kind and rarity. keep it, or sell it back";
		case "tiles":       return "tiles pay by themselves and merge upward. shards buy the board; flux, from a reset, buys what lasts";
		case "automation":  return "every switch here costs ram - the band up top is the budget";
		case "abilities":   return "the deck: abilities drafted with credits, three at a time";
		case "timebank":    return "time away banks as speed you can spend - the row picks how fast";
		case "battery":     return "it runs the machines while you are away. crank it, or let it charge";
		case "ccore":       return "a slow well of credits. collect it by hand when it fills";
		case "gift":        return "one gift a day. a missed day waits, it never resets";
		case "expeditions": return "pick a world and a crew, send them, read the diary";
		case "statistics":  return "everything, counted. star a line to keep it on top";
		case "rebirth":     return "the run resets; the boost stays. the fill is how much you would get";
		case "offlog":      return "every absence, and what it paid";
	}
	return "";
}
