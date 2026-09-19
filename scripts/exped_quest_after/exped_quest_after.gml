/// @description exped_quest_after(trip) - the moment a quest is done, once: THE TOWN'S GRATITUDE and THE FOLLOW-UP CARD (2026-09-16)
/// Called a step (exped_act_step) and after a fight (exped_tick_one);
/// trip.after_done (saved "qaf") keeps it to once. A quest done FOR a
/// town (defend / well / cellars / shop / rescue / escort / parcel /
/// goat) makes the town grateful for a week (exped_mem_set: a bed on
/// the house, a credit off the shelf); then exped_quest_personal deals
/// the follow-up where one follows.
function exped_quest_after(_tr) {
	var _q = _tr[$ "quest"];
	if (!is_struct(_q) || _q.done < _q.n || (_tr[$ "after_done"] ?? false)) return;
	_tr.after_done = true;
	var _rg = exped_region(_tr), _ri = _tr[$ "rgi"] ?? 0, _kk = region_kinds();
	var _tn = -1;
	switch (_q.kind) { case "defend": case "well": case "cellars": case "shop": case "rescue": case "escort": case "parcel": case "goat": _tn = _q.node; break; }
	if (_tn >= 0 && _tn < array_length(_rg.nodes)) {
		var _kd = _kk[$ _rg.nodes[_tn].kind];
		if (is_struct(_kd) && _kd.civ) {
			var _ldg = region_node_leader(_tr.dest, _rg, _tn);   // (a beloved leader's town remembers twice as long - 2026-09-16)
			exped_mem_set(_tr.dest, _ri, _tn, "grateful", (is_struct(_ldg) && _ldg.trait == "beloved") ? 336 : 168);
			lane_push(_tr.dest, _ri, "welcome", .35);   // (a town helped: the region's welcome - q259)
			lane_push(_tr.dest, _ri, "trade", (_q.kind == "escort" || _q.kind == "parcel" || _q.kind == "shop") ? .35 : .12);   // (the carts got through)
			array_push(_tr.log, _rg.nodes[_tn].name + " will remember this. " + choose("a bed there is on the house, for a while", "the shop's prices are kinder, for a while", "there will be a bed and a kind word next time", "the elder said so, in front of everyone"));
		}
	}
	var _line = exped_quest_personal(_tr, _q, _rg);
	if (_line != "") array_push(_tr.log, _line);
	// THE VILLAIN'S THREAD (2026-09-16): a stage done advances it; ended, the crew is titled and the region breathes;
	// the next card deals when no follow-up just did (the board's one personal seat)
	var _vk = string(_tr.dest.seed) + ":" + string(_ri);
	if (!is_struct(g.exped[$ "vil"])) g.exped.vil = {};
	var _vst = g.exped.vil[$ _vk] ?? 0;
	var _v = region_villain(_tr.dest, _rg);
	if ((_q[$ "vil"] ?? 0) > 0 && is_struct(_v)) {
		_vst = max(_vst, _q.vil); g.exped.vil[$ _vk] = _vst;
		if (_q.vil >= 3) {
			var _crew = [];
			for (var _k = 0; _k < array_length(_tr.sids); _k++) { if (_tr.hp[_k] <= 0) continue; var _sp = exped_sprite(_tr.sids[_k]); if (is_undefined(_sp)) continue; sprite_title(_sp, "who ended " + _v.name, 2); array_push(_crew, _sp.name); }
			exped_mem_set(_tr.dest, _ri, -1, "peace", 168);
			lane_push(_tr.dest, _ri, "order", .5); lane_push(_tr.dest, _ri, "dread", -.8);   // (the villain ended - q259)
			seat_open(_tr.dest, _ri, _rg, _v.foe);   // THE SEAT falls vacant (q260): a successor in SEAT_DAYS / the region's weight; the thread resets then; its kind leaderless meanwhile (q262)
			array_push(_tr.log, _v.name + " is finished. " + _v.fac + " scatter. " + _rg.name + " will be quieter for a while, and " + exped_crew_txt(_crew) + " will be talked about");
		} else { lane_push(_tr.dest, _ri, "dread", -.25); array_push(_tr.log, choose("a thread pulled. " + _v.name + " will have heard", _v.name + "'s people know this crew's names now", "one thread of " + _v.name + "'s cut. there are more")); }
	}
	if (is_struct(_v) && _vst < 3 && _line == "" && (_vst > 0 || roll_perc(40))) {
		var _vc = exped_villain_card(_tr.dest, _ri, _rg, _vst + 1);
		if (is_struct(_vc)) {
			exped_region_quests(_tr.dest, _ri);
			var _of = g.exped.offers[$ _vk];
			if (is_struct(_of)) { _of.pq = [ { q : _vc, salt : -1, left : exped_quest_life(), taken : 0, easy : false, pers : true } ]; array_push(_tr.log, "word gets round: " + _vc.pnote + " - a card on the board in " + _rg.name); }
		}
	}
	save_mark_dirty();
}
