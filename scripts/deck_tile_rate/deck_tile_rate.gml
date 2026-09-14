/// @description deck_tile_rate(kind) -> the deck's multiplier on one of
/// the table's machines: "fab" (fabrication / + / ++: x1.15, x1.15,
/// x1.25) or "merge" (automerger+ / ++: x1.25, x1.4). DE gave these as
/// seconds off the timers; RX's timers are also shortened by the tile
/// upgrades, so they are rates here and can never cross zero. Read by
/// autom_rate (online and the replay alike - offline == online).
function deck_tile_rate(_kind) {
	var _m = 1;
	if (_kind == "fab") {
		if (abi_on("ad_fabricator"))  _m *= 1.15;
		if (abi_on("ad_fabricator2")) _m *= 1.15;
		if (abi_on("ad_fabricator3")) _m *= 1.25;
	} else if (_kind == "merge") {
		if (abi_on("ad_automerger2")) _m *= 1.25;
		if (abi_on("ad_automerger3")) _m *= 1.4;
	}
	return _m;
}
