/// @description exped_mem_get(dest, ri, node, kind) -> { left, pay } or undefined - THE WORLD REMEMBERS (his pick, 2026-09-16)
/// What a crew did at a place, kept on a clock (g.exped.mem, keyed
/// "seed:ri:node:kind"; exped_mem_tick runs it down on the expedition
/// clock, online and offline; saved "ex_mem"):
///   quiet     a dungeon / crypt / sewer delved to its end: half the rooms, few fights, for three days
///   routed    a camp's last fight won: ashes, nobody home, the road past it half as many bandits, for four days
///   grateful  a quest done for a town (defend / well / cellars / shop / rescue / escort / parcel / goat): a bed on the house, a credit off the shelf, for a week
///   barred    a bar fight, one time in two: the tavern will not have them, for three days
///   shelf     the shop's shelf as it was left, sold gaps and all, until the restock in two days (pay = the items)
/// left = seconds of the clock; pay = a string of the kind's own.
function exped_mem_get(_d, _ri, _ni, _kind) {
	exped_init();
	var _m = g.exped[$ "mem"];
	if (!is_struct(_m)) return undefined;
	return _m[$ string(_d.seed) + ":" + string(_ri) + ":" + string(_ni) + ":" + _kind];
}
