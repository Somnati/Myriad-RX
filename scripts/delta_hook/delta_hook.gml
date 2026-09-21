/// @description delta_hook() -> { grain, life, rate, land, newland, harvests, valley } THE TIE-IN (q314), unwired by his ask: what the base game would read when it ties the delta in. Ideas kept here so they are not lost:
///   - grain -> RATIONS for the crews (exped: a trip's hunger, a shop's bread), or sold at the tap room's rate for profit
///   - the delta's land -> a world's flood plain (a region kind "delta" on the crews' world, its fields the region's own)
///   - the base game -> rain: the dials' p/s or a world's weather could feed the spring (delta.rain read result-side)
///   - the flood -> a news line for the region ("the river rose at ...")
/// Nothing reads this yet (testing, his call). Reading it is free; the delta ticks on its own clock.
function delta_hook() {
	var _d = delta_init(), _st = delta_stats(_d);
	return { grain : _d.grain, life : _d.life, rate : _d.rate, land : _st.land, newland : _st.newland, harvests : _d.harvests, valley : _d.valley };
}
