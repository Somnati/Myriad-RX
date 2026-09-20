/// @description exped_tick(secs) - walk every trip under way by secs
/// (x the debug clock), online and offline alike (offline_replay hands
/// the absence to this same call). A trip that gets home leaves the
/// trips list for the hauls list, where exped_collect finds it.
/// IN SLICES (2026-09-14, the inspection): exped_tick_one walks ONE room
/// a call and a fight swallows the call, so one call with an eight-hour
/// absence moved a trip a single room and the delve then ran live, a
/// room a frame, after you came back. The clock is cut into slices of
/// EXPED_TICK_MAX seconds - a room a slice, a fight's actions inside it
/// - so the absence walks the whole trip, fights and all, offline ==
/// online by construction. (an hour is 720 slices a trip: cheap)
function exped_tick(_secs) {
	// THE CHART FIRST (his call, 2026-09-17: no loading screen on boot - the
	// galaxy charts in the background). Until it is there a trip's clock is
	// OWED, not ticked; the first ready call walks the whole owed stretch -
	// the very call the offline replay makes, so nothing is lost or doubled
	if (!galaxy_ready()) { g.exped_owed = (g[$ "exped_owed"] ?? 0) + _secs; return; }
	// ...PAID BACK IN SLICES (q230): EXPED_OWED_SLICE of trip time a call on the heartbeat - an eight-hour night lands over
	// a dozen frames, no hitch when the chart stands under play; the report's expedition section is written once the
	// last slice has walked (exped_owed_report - the offline log's entry, by reference)
	var _owed_done = false;
	if ((g[$ "exped_owed"] ?? 0) > 0) {
		var _pay = min(g.exped_owed, EXPED_OWED_SLICE);
		_secs += _pay; g.exped_owed -= _pay;
		if (g.exped_owed <= 0) { g.exped_owed = 0; _owed_done = true; }
	}
	exped_init();
	var _e = g.exped;
	if (array_length(_e.board) == 0) exped_board_roll();   // (a board the roll skipped while the chart was pending)
	for (var _bq = 0; _bq < array_length(_e.board); _bq++) if (!is_struct(_e.board[_bq][$ "quest"]) && region_ready(_e.board[_bq])) _e.board[_bq].quest = exped_quest_gen(_e.board[_bq]);   // (a world's featured quest, once its territories stand - q293)
	var _spd = max(1, _e.spd);
	var _dt = _secs * _spd;
	exped_offer_tick(_dt);   // the quest boards turn over (2026-09-15)
	exped_mem_tick(_dt);     // the world's memories fade (2026-09-16)
	lane_tick(_dt);          // ...and every disturbed region relaxes toward its average (q259)
	seat_tick(_dt);          // ...and an empty seat is filled in its time (q260)
	faction_tick(_dt);       // ...and the hunted kinds recruit toward their numbers (q283)
	pop_tick(_dt);           // ...and the pushed places drift back to their baselines (q284)
	news_tick(_dt);          // ...and the news gets old (q285)
	exped_event_tick();      // ...and the regions' events roll (2026-09-16)
	// THE KEEPERS' EGGS (his design, 2026-09-16): a sprite's egg hatches on the universal clock into its CHARGE - a sprite of the
	// egg's colour, the keeper's class (a fifth of the time an adjacent one), young: it follows its keeper about the rooms and
	// tags along on its journeys (exped_start), and grows up after two days. A full roster keeps the egg waiting.
	for (var _si = 0; _si < array_length(g.sprites); _si++) {
		var _kp = g.sprites[_si], _keg = _kp[$ "egg"];
		if (!is_struct(_keg)) continue;
		if (universal_now() < _keg.hatch || array_length(g.sprites) >= SPRITE_CAP) continue;
		var _ch = sprite_spawn("tap");
		_ch.col = _keg.col; _ch.col2 = merge_colour(_keg.col, c_white, .3); _ch.asleep = true; _ch.found = "an egg " + _kp.name + " kept";
		_ch.young = { parent : _kp.id, born : universal_now() };
		var _ncl = array_length(sprite_classes()), _pcl = sprite_sheet(_kp).cls;
		sprite_sheet(_ch).cls = (random(1) < .2) ? ((_pcl + choose(1, _ncl - 1)) mod _ncl) : _pcl;   // (the keeper's class, or a neighbour on the ring)
		sprite_note(_ch, "hatched from a " + _keg.word + " egg " + _kp.name + " carried home from " + _keg.from + ". " + choose("i follow them everywhere", "they are the first thing i saw", "i came out already talking", "the shell is kept, for luck"), "egg");
		sprite_note(_kp, "the " + _keg.word + " egg hatched. " + _ch.name + ". " + choose("it follows me everywhere", "it will not stop looking at me", "i did not expect to feel like this about it", "it is small and loud"), "egg_hatch");
		_kp.egg = undefined;
		exped_stat("recruits");
		save_mark_dirty();
	}
	// GROWN (2026-09-16): two days of wall clock young, then an adult like any other
	for (var _si = 0; _si < array_length(g.sprites); _si++) {
		var _ys = g.sprites[_si], _yy = _ys[$ "young"];
		if (!is_struct(_yy) || universal_now() - _yy.born < 172800) continue;
		var _ypar = exped_sprite(_yy.parent);
		sprite_note(_ys, "grown. " + (is_undefined(_ypar) ? "" : (_ypar.name + " says i still have to do what they say. ")) + choose("we will see", "i am taller than them now, nearly", "i want my own adventures"), "grown");
		_ys.young = undefined;
		save_mark_dirty();
	}
	// THE FIRE'S EGGS (the fallback clutch: nobody free to keep one): they hatch the same, nobody's charge
	if (!is_array(_e[$ "eggs"])) _e.eggs = [];
	for (var _gi = array_length(_e.eggs) - 1; _gi >= 0; _gi--) {
		var _eg = _e.eggs[_gi];
		if (universal_now() < _eg.hatch || array_length(g.sprites) >= SPRITE_CAP) continue;
		var _hs = sprite_spawn("tap");
		_hs.col = _eg.col; _hs.col2 = merge_colour(_eg.col, c_white, .3); _hs.asleep = true; _hs.found = "an egg from " + _eg.from;
		sprite_note(_hs, "hatched from a " + _eg.word + " egg the crew carried home from " + _eg.from + ". " + choose("nobody saw it happen", "it was hungry first thing", "it came out already talking", "the shell is kept, for luck"), "egg");
		exped_stat("recruits");
		array_delete(_e.eggs, _gi, 1);
		save_mark_dirty();
	}
	for (var _i = array_length(_e.trips) - 1; _i >= 0; _i--) {
		var _tr = _e.trips[_i];
		// A FIGHT PLAYS AT ITS OWN PACE (his ask, 2026-09-15): the debug clock
		// hurries the walk, not the fight - unless it is at x100
		if (!is_undefined(_tr.fight) && _spd < 100) { exped_tick_one(_tr, _secs); continue; }
		var _left = _dt, _home = false;
		while (_left > 0 && !_home) {
			var _step = min(_left, EXPED_TICK_MAX);
			_left -= _step;
			_home = exped_tick_one(_tr, _step);
		}
		if (!_home) continue;
		array_delete(_e.trips, _i, 1);
		array_push(_e.hauls, { id : _tr.id, dest : _tr.dest, sids : _tr.sids, names : _tr.names, cols : _tr.cols,
		                       sid : _tr.sid, sname : _tr.sname, finds : _tr.finds, routed : _tr.routed, young : _tr[$ "young"] ?? [],
		                       cleared : _tr.cleared, wins : _tr.wins, log : _tr.log, hp : _tr.hp, hpmax : _tr.hpmax, mp : _tr[$ "mp"] ?? [], rgi : _tr[$ "rgi"] ?? 0,
		                       tl : _tr[$ "tl"] ?? { slain : 0, mist : 0, items : 0, xp : 0, earned : 0 }, pocket : _tr[$ "credits"] ?? 0, stance : _tr[$ "stance"] ?? "steady", best : exped_haul_moment(_tr) });   // (the best moment, 2026-09-16)   // (the tally home, 2026-09-16)   // (rgi: the card's world faces the region - 2026-09-15)
		save_mark_dirty();
	}
	if (_owed_done) exped_owed_report();   // (the absence's expedition section, now that it has been walked - q230)
}
