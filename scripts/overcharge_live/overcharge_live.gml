/// @description overcharge_live() -> is the overcharger switched on?
/// DE gated it behind the Overcharge ability (g.ad_overtapper) and so
/// does RX now (his call, 2026-09-14: "not enabled by default on a new
/// game" - the deck carries ad_overtapper, build_deck.py's table). Off:
/// the charger hides, overcharge_multi reads x1, taps charge nothing.
function overcharge_live() {
	return abi_on("ad_overtapper");
}
