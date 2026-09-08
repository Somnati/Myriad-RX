/// @description ability(var, name, rarity, ap, desc, sub?, standard?)
/// one card in the deck, ported from Myriad DE. the deck is DECLARED
/// as a linear sequence of these calls (the grab_deck batches); each
/// call advances the cursor _a, and only the call whose position
/// matches the caller's `a` MATERIALIZES - copies its name/desc/
/// rarity/cost into the calling instance. locked abilities (-1) are
/// skipped entirely, which is why discovery grows the visible deck.
/// every declared ability also accumulates g.maxap_spend.
function ability(_in, _name, _rarity, _ap, _desc, _sub = false, _std = false) {
	_input = _in;   // instance-scoped: ability_flavor reads these
	_apreq = _ap;
	g.maxap_spend += _apreq;

	if (_input == -1) exit; // locked: invisible, cursor holds still

	if (a == _a) {
		aid    = _a;
		input  = _input;
		name   = _name;
		apreq  = floor(_apreq * ap_multi);
		rarity = _rarity;
		txt    = _desc;
		sub    = _sub;
		open   = _open;
		if (_open == -1) sub = false; // parent hidden: don't indent an orphan
		tog    = true;
		flavor = 0;
	}

	mx = _a;
	_a++;
}
