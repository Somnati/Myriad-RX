/// @description exped_villain_card(dest, ri, region, stage) -> the villain thread's card for a stage (1 the lieutenant / 2 the hideout / 3 the boss), finished; undefined without a villain
/// A personal card (pers 1, a pnote) with vil = its stage; the reward
/// half again, doubled for the boss (a greater one, named - the
/// bossfight act reads vil). exped_quest_after deals and advances.
function exped_villain_card(_d, _ri, _rg, _stage) {
	var _v = region_villain(_d, _rg);
	if (!is_struct(_v)) return undefined;
	var _hn = _rg.nodes[_v.hide], _cn = _rg.nodes[_v.camp];
	var _p, _note;
	switch (_stage) {
		case 1: {
			if (_cn.kind == "camp") _p = { kind : "rout", node : _v.camp, foe : "bandit", n : 2, mult : 4 };
			else _p = { kind : "slay", node : _v.camp, foe : _v.foe, n : 4, mult : 4 };
			var _ch = region_node_leader(_d, _rg, _v.camp);   // (the chief of the month is the lieutenant - 2026-09-16)
			_note = (is_struct(_ch) ? (_ch.name + " the " + _ch.title + ", " + _v.name + "'s lieutenant, holds ") : (_v.name + "'s lieutenant holds ")) + _cn.name + ". the first thread";
			break;
		}
		case 2: {
			if (_hn.kind == "camp") _p = { kind : "rout", node : _v.hide, foe : "bandit", n : 3, mult : 4 };
			else _p = { kind : "clear", node : _v.hide, foe : "", n : (_hn[$ "rooms"] ?? 4), mult : 4 };
			_note = _v.name + "'s hideout is " + _hn.name + ". clear it and " + _v.fac + " scatter";
			break;
		}
		default: {
			_p = { kind : "bounty", node : _v.hide, foe : _v.foe, n : 1, mult : 5, who : _v.name };   // (the short name: it is the boss's label in the fight window; the full title in the note - bug hunt 2026-09-16)
			_note = _v.full + " is cornered at " + _hn.name + ". the last thread";
			break;
		}
	}
	_p.vil = _stage; _p.pers = 1; _p.pnote = _note;
	exped_quest_finish(_p, _rg, _ri, false);
	_p.reward = ceil(_p.reward * ((_stage >= 3) ? 2 : 1.5));
	return _p;
}
