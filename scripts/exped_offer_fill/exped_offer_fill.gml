/// @description exped_offer_fill(offer) - every slot's quest regenerated from its salt where missing (after a load)
function exped_offer_fill(_of) {
	if (!is_struct(_of[$ "d"])) return;
	for (var _i = 0; _i < array_length(_of.slots); _i++) {
		var _sl = _of.slots[_i];
		if (!is_struct(_sl.q)) _sl.q = exped_quest_gen(_of.d, _sl.salt, _of.ri, _sl.easy);
	}
	// a personal card loaded (its raw fields): finished here, the reward half again (exped_quest_personal's law)
	if (is_array(_of[$ "pq"])) for (var _i = 0; _i < array_length(_of.pq); _i++) {
		var _p = _of.pq[_i];
		if (is_struct(_p.q) || !is_struct(_p[$ "raw"])) continue;
		var _rg = region_get(_of.d, _of.ri), _r = _p.raw, _nn = array_length(_rg.nodes);
		var _q = { kind : _r.kind, node : clamp(_r.node, 0, _nn - 1), from : (_r.from < 0) ? -1 : clamp(_r.from, 0, _nn - 1), foe : _r.foe, n : _r.n, mult : _r.mult, who : _r.who, pers : 1, pnote : _r.pnote };
		if (is_array(_r[$ "nodes"]) && array_length(_r.nodes) > 0) _q.nodes = _r.nodes;
		exped_quest_finish(_q, _rg, _of.ri, false);
		_q.reward = ceil(_q.reward * 1.5);
		_p.q = _q;
	}
}
