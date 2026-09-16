/// @description exped_quest_personal(trip, quest, region) -> the diary's line ("" when nothing follows): THE FOLLOW-UP (his pick, 2026-09-16)
/// The folk you met come back with work, now that they recur: the
/// trader you escorted wants another run; the family of the one you
/// rescued posts a bounty on the thing that took them; the keeper whose
/// shop you minded trusts you with the post; the elder of a village you
/// defended (or whose well / cellars you cleared) asks for the other job.
/// A PERSONAL card on the region's board (offer.pq - one at a time, the
/// newest replaces; its own clock, saved as a "P" record in ex_offer):
/// the same kinds the deal knows, finished by exped_quest_finish, the
/// reward half again, pers = 1 and a pnote the card and the preparation
/// page show. Built once and saved by its fields (the ambient stream).
function exped_quest_personal(_tr, _q, _rg) {
	var _d = _tr.dest, _ri = _tr[$ "rgi"] ?? 0;
	var _kk = region_kinds(), _civ = [], _dung = [];
	for (var _i = 1; _i < array_length(_rg.nodes); _i++) {
		var _k = _rg.nodes[_i].kind, _kd = _kk[$ _k];
		if (is_struct(_kd) && _kd.civ) array_push(_civ, _i);
		if (_k == "dungeon" || _k == "crypt" || _k == "sewer") array_push(_dung, _i);
	}
	var _p = undefined, _note = "";
	switch (_q.kind) {
		case "escort": {
			if (array_length(_civ) < 2) return "";
			var _to; do { _to = _civ[irandom(array_length(_civ) - 1)]; } until (_to != _q.node);
			_p = { kind : "escort", node : _to, from : _q.node, foe : "bandit", n : 1, mult : 3, who : _q.who };
			_note = _q.who + " liked the last run and pays half again";
			break;
		}
		case "rescue": {
			var _at = (_q.from >= 0) ? _q.from : _q.node;
			var _fk = foe_kinds_at(_rg.nodes[_at].kind), _f = _fk[irandom(array_length(_fk) - 1)];
			_p = { kind : "bounty", node : _at, foe : _f, n : 1, mult : 4, who : "the " + _f + " that took " + _q.who };
			_note = _q.who + "'s people in " + _rg.nodes[_q.node].name + " want it dead and pay half again";
			break;
		}
		case "shop": {
			if (array_length(_civ) < 2) return "";
			var _to2; do { _to2 = _civ[irandom(array_length(_civ) - 1)]; } until (_to2 != _q.node);
			_p = { kind : "parcel", node : _to2, from : _q.node, foe : "", n : 1, mult : 3, who : _q.who + "'s parcel (do not shake it)" };
			_note = _q.who + " trusts them with the post now and pays half again";
			break;
		}
		case "defend": case "well": case "cellars": {
			var _pp = region_node_info(_d, _rg, _q.node);
			var _eld = is_struct(_pp[$ "folk"]) ? _pp.folk.elder : "the elder";
			if (_q.kind == "cellars") {
				var _wf = foe_kinds_at((array_length(_dung) > 0) ? _rg.nodes[_dung[irandom(array_length(_dung) - 1)]].kind : "marsh");
				_p = { kind : "well", node : _q.node, foe : _wf[irandom(array_length(_wf) - 1)], n : 1, mult : 4, who : "the thing in the well" };
			} else _p = { kind : "cellars", node : _q.node, foe : choose("rat", "rat", "flea", "musca"), n : irandom_range(3, 5), mult : 3 };
			_note = _eld + " the elder asks it and " + _rg.nodes[_q.node].name + " pays half again";
			break;
		}
		default: return "";
	}
	_p.pers = 1; _p.pnote = _note;
	exped_quest_finish(_p, _rg, _ri, false);
	_p.reward = ceil(_p.reward * 1.5);
	// onto the board: one personal card a region, the newest replaces
	exped_region_quests(_d, _ri);
	var _of = g.exped.offers[$ string(_d.seed) + ":" + string(_ri)];
	if (!is_struct(_of)) return "";
	_of.pq = [ { q : _p, salt : -1, left : exped_quest_life(), taken : 0, easy : false, pers : true } ];
	save_mark_dirty();
	return "word gets round: " + _note + " - a card on the board in " + _rg.name;
}
