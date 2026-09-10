/// @description overcharge_live() -> is the overcharger switched on?
/// DE gated it behind the overtapper ability (g.ad_overtapper). RX's
/// deck does not carry that ability yet, so it is ON until a deck
/// defines the flag - the day one does, this reads it and the charger
/// becomes a thing you unlock, DE's way, with no other edit.
function overcharge_live() {
	if (variable_global_exists("ad_overtapper")) return (g.ad_overtapper == 1);
	return true;
}
