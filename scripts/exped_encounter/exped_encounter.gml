/// @description exped_encounter(trip, [mult], [weather]) - something on the road (called once per road-hour crossed; mult scales the odds - night; rain lets a fight be walked round)
/// EXPED_ENC% a road-hour: a wild fight (45), a passer-by who talks (25),
/// a bandit sprite (15), a friendly sprite who asks to come along (15 -
/// a "sprite" find: the haul's recruit moment decides at home).
function exped_encounter(_tr, _mult = 1, _wx = "clear") {
	// THE REGION'S EVENT (2026-09-16): a villain ended = peace, half the encounters for a week; the lord abroad = passers-by turn out bandits
	var _rgi_e = _tr[$ "rgi"] ?? 0;
	if (is_struct(exped_mem_get(_tr.dest, _rgi_e, -1, "peace"))) _mult *= .5;
	var _eve = region_event(_tr.dest, _rgi_e), _lord = (is_struct(_eve) && _eve.kind == "lord");
	if (!roll_perc(EXPED_ENC * _mult)) return;   // (x1.5 at night: the road is busier in the dark)
	var _r = random(100);
	// AN ESCORT (2026-09-15): with the merchant's cart along, half the passers-by are bandits after it
	var _eq = _tr[$ "quest"];
	var _esc = (is_struct(_eq) && _eq.kind == "escort" && (_eq[$ "at"] ?? 0) == 1 && _eq.done < _eq.n);
	if (_esc && _r >= 45 && _r < 70 && roll_perc(50)) _r = 75;
	if (_lord && _r >= 45 && _r < 70 && roll_perc(50)) _r = 75;
	// (the noise of rain - a fight heard in time walked round - lives in the fork's check now: rain lowers the DC of going round; q258)
	// THE WORLD REMEMBERS (2026-09-16): a camp routed lately - the road past it has half its bandits
	if (_r >= 70 && _r < 85 && is_struct(_tr[$ "road"]) && roll_perc(50)) {
		var _rgi0 = _tr[$ "rgi"] ?? 0;
		if (is_struct(exped_mem_get(_tr.dest, _rgi0, _tr.road.a, "routed")) || is_struct(exped_mem_get(_tr.dest, _rgi0, _tr.road.b, "routed"))) { array_push(_tr.log, choose("the road is quiet since the camp burned", "nobody on the road. the camp's ashes are still warm", "a bandit's boot in the ditch, and no bandit")); return; }
	}
	if (_r < 45 && exped_fork_allowed(_tr)) {
		// THE ENCOUNTER FORK (q258): fight, or go round - the crew decides (the stance: whole enough to fight, or the
		// way round on a check the weather and the dark help); the kind and the count named ahead so the prompt is honest
		var _frg = exped_region(_tr), _fss = region_season(_tr.dest, _frg), _fkinds = foe_kinds_at("road", _fss.on ? _fss.idx : -1);
		var _fkk = _fkinds[irandom(array_length(_fkinds) - 1)], _fn = irandom_range(1, 2);
		var _efk = { kind : "encounter", foe : _fkk, n : _fn, lv : exped_trip_lv(_tr), wx : _wx, night : (_tr[$ "night"] ?? false), born : current_time, held : 0, by : "", chosen : -1 };
		_efk.dc = exped_fork_dc(_efk);
		_efk.mods = exped_fork_mods(_tr, _efk);
		_efk.prompt = ((_fn > 1) ? "two " + _fkk + "s" : "a " + _fkk) + " on the road ahead" + (_efk.night ? ", in the dark" : ((_wx != "clear") ? ", in the " + _wx : "")) + ".";
		_efk.choices = [ { key : "fight", txt : "fight" }, { key : "round", txt : "go round" } ];
		exped_fork_raise(_tr, _efk);
		return;
	}
	if (_r < 45) {
		_tr.fight = exped_fight_new(_tr, "", irandom_range(1, 2), 0);
		array_push(_tr.log, "on the road: " + _tr.fight.b.name + ((array_length(_tr.fight.foes) > 1) ? " and company" : "") + " " + choose("block the way", "come out of the trees", "were waiting", "had the same idea"));
		exped_say(_tr, "fight_open", { foe : _tr.fight.b.name }, .7);
	} else if (_r < 70 && roll_perc(30)) {
		// A RIVAL CREW (2026-09-16): one of the world's three, on the road; a note swapped, sometimes
		exped_stat("met");
		var _rvs = exped_rivals(_tr.dest), _rc = _rvs[irandom(array_length(_rvs) - 1)], _n1 = _tr.names[0];
		array_push(_tr.log, "met " + _rc.name + " on the road, " + choose("going the other way", "coming back from something", "arguing over a map", "carrying a door between them", "counting something and losing count") + ". " + choose(_rc.lead + " nodded. " + _n1 + " nodded back. that was the whole of it", "they compared pockets. nobody won", _rc.lead + " said they had cleared it already. they had not", "a word about the road ahead, most of it wrong", _rc.lead + " asked after the pay. " + _n1 + " lied", "they walked a mile together and said nothing"));
		if (roll_perc(35) && is_struct(_tr[$ "road"])) {
			var _up = [];
			for (var _k = 0; _k < array_length(_tr.sids); _k++) if (_tr.hp[_k] > 0) array_push(_up, _k);
			var _rgn = exped_region(_tr), _lk = _rgn.nodes[clamp(_tr.road.b, 0, array_length(_rgn.nodes) - 1)].kind, _lkd = region_kinds()[$ _lk];
			var _nsp = (array_length(_up) > 0) ? exped_sprite(_tr.sids[_up[irandom(array_length(_up) - 1)]]) : undefined;
			if (!is_undefined(_nsp) && is_struct(_lkd) && _lkd.wild) {
				var _nt = "from " + _rc.lead + ": " + choose("keep to the left on the " + _lk + ". the left is drier", "the " + _lk + " is quicker by the old line", "on the " + _lk + " walk in the morning. not after", "the " + _lk + ": follow the crows. they know");
				if (sprite_note(_nsp, _nt, "road:" + _lk)) array_push(_tr.log, _nsp.name + " writes it down: \"" + _nt + "\"");
			}
		}
	} else if (_r < 70) {
		exped_stat("met");
		var _nm = exped_npc_name();
		array_push(_tr.log, "met a sprite called " + _nm + " going the other way. " + choose("they talked about the weather.", "it had a hat. nobody mentioned it.", "it asked for directions. nobody knew.", "it was carrying a fish.", "they compared sticks."));
	} else if (_r < 85) {
		var _nm = exped_npc_name();
		_tr.fight = exped_fight_new(_tr, "bandit", irandom_range(1, 2), 1);
		for (var _j = 0; _j < array_length(_tr.fight.foes); _j++) _tr.fight.foes[_j].name = (_j == 0) ? (_nm + " the bandit") : ("one of " + _nm + "'s");
		array_push(_tr.log, "on the road: a sprite called " + _nm + " wanted " + (_esc ? "the cart" : "the pocket money"));
		exped_say(_tr, "fight_open", { foe : _nm }, .7);
	} else {
		exped_stat("met");
		var _nm = exped_npc_name();
		array_push(_tr.finds, { kind : "sprite", rar : 0, txt : "a sprite called " + _nm + ", who asked to come along", col : c_white, name : _nm });
		array_push(_tr.log, "met a sprite called " + _nm + " who asked to come along. " + choose("nobody said no.", "it is carrying its own bag.", "it seems fine."));
	}
}
