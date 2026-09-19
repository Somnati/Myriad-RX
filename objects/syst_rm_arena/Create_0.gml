/// rm_arena - THE ARENA (q246; his ask: "a simulator where I can have sprites fight dummies... a fullscreen turn-based
/// fight with pauses at every action for a sprite and letting me choose to use attack / skill / items etc"). A SIMULATOR:
/// the party fights as it is (sprite_pawn off the sheets, copies of its potions), nothing writes back - no hp, no xp, no
/// items spent. Pages: setup (the crew, the opponent) -> fight (the ATB strip, the pawns, THE MENU on your pawn's turn,
/// the log, x1 / x4 / max, [auto], [quit]) -> result. The engine is the trips' own: cbt_fight_next -> (the menu | cbt_ai)
/// -> cbt_fight_act - the same rolls the diary's fights make.

bby = obj_ui_header.sprite_height;
page = "setup";           // setup / fight / result
// ---- the setup ----
picked = [];              // sprite ids, up to exped_party_max()
opp = "dummy";            // dummy / creature
d_hp = 2; d_arm = 1; d_hits = false;   // the dummy: hit points x1..x5, armour 0..3, hits back
c_kind = 0; c_lv = 1; c_n = 1;          // the creature: the roster's index, its level, the pack's size
crew_scroll = 0;
// ---- THE PLACE and THE CUSTOM SPRITES (q257; his ask: "custom biome/weather... and customizable sprites") ----
tab = "opponent";        // the setup's right column: opponent / place / custom
kind_scroll = 0;         // the creature grid's scroll, in rows (forty kinds never fit)
// THE PLACE: a LAND (the region's node kinds - the hazard and the natives follow it by the trip's own laws) and a
// SEASON (-1 none, 0 spring, 1 summer, 2 autumn, 3 winter - at its deepest: winter is the dead of winter, summer
// high summer). WEATHER AND NIGHT have no hand in a fight today (they are the diary's), so this is the whole of it
p_land = "field"; p_season = -1;
p_lands = ["field", "forest", "hills", "marsh", "desert", "mountains", "tundra", "coast", "isle", "dungeon", "crypt", "mine", "sewer", "ruin", "shrine", "camp"];
p_seasons = ["none", "spring", "summer", "autumn", "winter"];
// THE CUSTOM SPRITES: built here (__custom_make), never saved, listed above the real crew and picked like it (ids
// -1000 downward); the knobs and the seed the [custom] tab's preview is built from
customs = [];
cu_cls = 0; cu_lv = 5; cu_rar = 1; cu_skills = 1; cu_pots = 1; cu_seed = irandom($7fffffff);
cu_preview = undefined;
cu_rars = ["none", "common", "uncommon", "rare", "epic", "elite", "master", "exotic", "legendary"];   // (-1 .. 7: gear_gen's ladder)
// ---- the fight ----
f = undefined;
auto = false;
spd = 1;                  // 1 / 4 / 0 (instant)
beat = 0;                 // frames until the next automatic step
pending = false;          // the actor's plan is the ai's, after the beat
mn = { open : false, stage : "root", list : [], sel : -1, skill : undefined, item : undefined, kind : "" };
log_n = 0;
last_line = ""; last_t = 0;
// ---- the result ----
res = undefined;

/// the rows and rectangles (region pattern: Step's hits and Draw's boxes share these)
__back_r  = function() { return { x : room_width - 62, y : bby + 1, w : 56, h : 13 }; };
__fight_r = function() { return { x : room_width - 90, y : room_height - 26, w : 84, h : 18 }; };
__crew_r  = function(_i) { return { x : 6, y : bby + 36 + _i * 13 - crew_scroll, w : 150, h : 12 }; };
__opp_pill_r = function(_k) { return { x : 170 + _k * 70, y : bby + 36, w : 66, h : 13 }; };
__dum_r   = function(_row, _k) { return { x : 170 + ((_k == 0) ? 0 : 118) + ((_k == 2) ? 16 : 0), y : bby + 58 + _row * 16, w : (_k == 0) ? 112 : 16, h : 13 }; };
__kind_r  = function(_i) { return { x : 170 + (_i mod 3) * 84, y : bby + 74 + (_i div 3) * 13, w : 80, h : 12 }; };
__clv_r   = function(_k) { return { x : 170 + ((_k == 0) ? 0 : 84) + ((_k == 2) ? 16 : 0), y : bby + 58, w : (_k == 0) ? 78 : 16, h : 13 }; };
__cn_r    = function(_k) { return { x : 300 + ((_k == 0) ? 0 : 84) + ((_k == 2) ? 16 : 0), y : bby + 58, w : (_k == 0) ? 78 : 16, h : 13 }; };
__party_r = function(_k) { return { x : 8, y : bby + 40 + _k * 40, w : 190, h : 36 }; };
__foe_r   = function(_k) { return { x : room_width - 8 - 150, y : bby + 40 + _k * 40, w : 150, h : 36 }; };
__menu_r  = function(_i) { return { x : 8, y : room_height - 8 - 14 * (5 - _i), w : 110, h : 13 }; };
__list_r  = function(_i) { return { x : 124, y : room_height - 8 - 14 * (6 - _i), w : 150, h : 13 }; };
__log_r   = function() { return { x : 284, y : room_height - 8 - 78, w : room_width - 284 - 8, h : 60 }; };
__spd_r   = function(_k) { return { x : 284 + _k * 30, y : room_height - 8 - 13, w : 28, h : 12 }; };
__auto_r  = function() { return { x : 284 + 96, y : room_height - 8 - 13, w : 40, h : 12 }; };
__quit_r  = function() { return { x : room_width - 8 - 40, y : room_height - 8 - 13, w : 40, h : 12 }; };
__again_r = function() { return { x : room_width * .5 - 100, y : room_height - 40, w : 60, h : 16 }; };
__setup_r = function() { return { x : room_width * .5 - 30, y : room_height - 40, w : 60, h : 16 }; };
__hit = function(_r) { return point_in_rectangle(mouse_x, mouse_y, _r.x, _r.y, _r.x + _r.w, _r.y + _r.h); };
// the tabs and their rows (q257)
__tab_r   = function(_k) { return { x : 170 + _k * 102, y : bby + 20, w : 98, h : 13 }; };
__land_r  = function(_i) { return { x : 170 + (_i mod 4) * 76, y : bby + 36 + (_i div 4) * 13, w : 72, h : 12 }; };
__seas_r  = function(_k) { return { x : 170 + _k * 60, y : bby + 92, w : 56, h : 13 }; };
__nat_r   = function(_i) { return { x : 170 + (_i mod 3) * 100, y : bby + 150 + (_i div 3) * 13, w : 96, h : 12 }; };
__ccls_r  = function(_k) { return { x : 170 + _k * 60, y : bby + 36, w : 56, h : 13 }; };
__cu_r    = function(_row, _k) { return { x : 170 + ((_k == 0) ? 0 : 118) + ((_k == 2) ? 16 : 0), y : bby + 54 + _row * 15, w : (_k == 0) ? 112 : 16, h : 13 }; };
__cubtn_r = function(_k) { return { x : 170 + _k * 90, y : room_height - 48, w : 84, h : 14 }; };
/// the crew list: the customs first, then the real sprites (one list for the draw and the taps)
__crew_list = function() { var _o = []; for (var _i = 0; _i < array_length(customs); _i++) array_push(_o, customs[_i]); for (var _i = 0; _i < array_length(g.sprites); _i++) array_push(_o, g.sprites[_i]); return _o; };
/// a sprite by id, real or custom
__sprite_of = function(_id) { var _s = exped_sprite(_id); if (!is_undefined(_s)) return _s; for (var _i = 0; _i < array_length(customs); _i++) if (customs[_i].id == _id) return customs[_i]; return undefined; };
/// THE PLACE'S HAZARD: cbt_hazard_at on the land, then the season's word as region_hazard_at says it (winter = the
/// dead of winter: the cold on the marsh and the open lands; summer = high summer: the heat on the fields and hills)
__place_hz = function() {
	var _hz = cbt_hazard_at(p_land, false);
	var _all = cbt_hazards(), _cold = undefined, _heat = undefined;
	for (var _i = 0; _i < array_length(_all); _i++) { if (_all[_i].key == "cold") _cold = _all[_i]; if (_all[_i].key == "heat") _heat = _all[_i]; }
	if (p_season == 3 && (p_land == "marsh" || p_land == "field" || p_land == "forest" || p_land == "hills") && is_struct(_cold)) return _cold;
	if (p_season == 1 && (p_land == "field" || p_land == "hills") && is_struct(_heat)) return _heat;
	return _hz;
};
/// a piece of gear for a custom sprite: the class's own families first (a mage's staff, a warrior's sword) - twelve
/// seeds, then whatever came (sprite_would_wear does not mind either)
__custom_gear = function(_slot, _fams, _seed) {
	var _it = undefined;
	for (var _t = 0; _t < 12; _t++) { _it = gear_gen(_slot, cu_lv, cu_rar, (_seed + _t * 7919) & $7fffffff); if (array_contains(_fams, _it.fam)) return _it; }
	return _it;
};
/// THE CUSTOM SPRITE off the knobs and the seed: a sprite struct with a sheet like any other (sprite_pawn, sprite_stats,
/// cbt_hazard_hold all read it plainly) - the class's colour, a hashed personality, gear of the chosen rarity in every
/// slot the class has, learned skills off the class's templates, red potions in the pocket. Nothing of it touches the save
__custom_make = function() {
	var _cl = sprite_classes()[cu_cls], _pl = sprite_personalities();
	var _sd = cu_seed & $7fffffff;
	var _sp = { id : -1000 - array_length(customs), name : "custom " + string(array_length(customs) + 1), col : _cl.col, col2 : merge_colour(_cl.col, c_white, .4),
	            eyes : 0, mat : 0, rar : 0, pers : hash_mix(_sd, 3) mod array_length(_pl), job : "arena", taps : 0, fx : .5, fy : .5, away : 0, asleep : false,
	            hpf : 1, mpf : 1, resting : false, mem : { trips : 0, wins : 0, routs : 0, last : "", streak : 0 }, acc : 0, custom : true };
	var _sh = { cls : cu_cls, lv : cu_lv, xp : 0, sks : hash_mix(_sd, 5), w1 : undefined, w2 : undefined, armor : [], talis : [], inv : [], notes : [], learned : [], abil : [-1, -1, -1, -1], abnew : false };
	if (cu_rar >= 0) {
		_sh.w1 = __custom_gear("w1", _cl.w1, hash_mix(_sd, 11));
		if (array_length(_cl.w2) > 0) _sh.w2 = __custom_gear("w2", _cl.w2, hash_mix(_sd, 12));
		for (var _a = 0; _a < _cl.armor; _a++) array_push(_sh.armor, gear_gen("armor", cu_lv, cu_rar, hash_mix(_sd, 20 + _a)));
		for (var _t = 0; _t < _cl.talis; _t++) array_push(_sh.talis, gear_gen("talis", cu_lv, cu_rar, hash_mix(_sd, 30 + _t)));
	}
	for (var _k = 0; _k < cu_skills; _k++) array_push(_sh.learned, { tmpl : _cl.tmpls[hash_mix(_sd, 40 + _k) mod array_length(_cl.tmpls)], seed : hash_mix(_sd, 50 + _k) });
	for (var _p = 0; _p < cu_pots; _p++) array_push(_sh.inv, use_gen("hp", 1, cu_lv));
	_sp.sheet = _sh;
	return _sp;
};

/// the fight begins: the crew as it is (copies of its potions), the opponent as set
__start = function() {
	var _party = [];
	// THE PLACE'S HAZARD on the party (q257) - exped_fight_new's own rule, minus the tonic (the simulator drinks
	// nothing): held by gear or class, halved by a note or danger sense, else the lane cut
	var _hz = __place_hz(), _bal = cbt_balance(), _bare = [], _held = [];
	for (var _i = 0; _i < array_length(picked); _i++) {
		var _sp = __sprite_of(picked[_i]);
		if (is_undefined(_sp)) continue;
		var _pw = sprite_pawn(_sp);
		if (is_struct(_hz)) {
			var _ho = cbt_hazard_hold(_sp, _hz);
			if (_ho.ok) array_push(_held, _sp.name + " (" + _ho.by + ")");
			else {
				var _abz = _pw[$ "ab"];
				var _half = sprite_note_has(_sp, "haz:" + _hz.key) || (is_struct(_abz) && (_abz[$ "hazard"] ?? 0) > 0);   // (danger sense - 2026-09-17)
				_pw[$ _hz.lane] *= _half ? sqrt(_hz.f) : _hz.f;
				if (_hz.lane == "spd") { _pw.eva = _pw.spd * _bal.spd_to_eva; _pw.tic_spd = _bal.tic_spd_base + sqrt(max(0, _pw.spd)) / _bal.tic_spd_div; }   // (the derived pair follows)
				if (_half) array_push(_held, _sp.name + " (half)"); else { _pw.haz = _hz.key; array_push(_bare, _sp.name); }
			}
		}
		_pw.items = [];
		var _inv = sprite_sheet(_sp).inv;
		for (var _j = 0; _j < array_length(_inv); _j++) { var _it = _inv[_j]; if ((_it[$ "slot"] ?? "") == "use" && (_it.kind == "hp" || _it.kind == "mp" || _it.kind == "antidote")) array_push(_pw.items, { kind : _it.kind, size : _it[$ "size"] ?? 1, name : _it[$ "name"] ?? _it.kind }); }
		array_push(_party, _pw);
	}
	if (array_length(_party) == 0) return;
	var _foes = [];
	if (opp == "dummy") array_push(_foes, cbt_dummy(max(1, (array_length(_party) > 0) ? _party[0].lv : 1), d_hp, d_arm, d_hits ? "hits" : "still"));
	else { var _ros = foe_roster(); for (var _j = 0; _j < c_n; _j++) array_push(_foes, foe_gen(c_lv, irandom($7fffffff), _ros[clamp(c_kind, 0, array_length(_ros) - 1)].name)); }
	f = cbt_fight_new(_party, _foes);
	f.manual = true;
	if (is_struct(_hz)) {
		f.hazard = { key : _hz.key, name : _hz.name, hold : _hz.hold, bare : _bare, held : _held, place : p_land };
		cbt_log(f, _hz.name + " of the " + p_land + ((array_length(_bare) > 0) ? ": " + exped_crew_txt(_bare) + " " + _hz.bite : ": everyone holds it"));
	}
	auto = false; pending = false; beat = 0; mn.open = false; log_n = 0; last_line = ""; res = undefined;
	page = "fight";
	play_sound_ext(snd_softclick, 1.05, 1.15, .4, 1);
};
/// the beat between automatic actions, by the speed
__beat = function() { return (spd == 0) ? 0 : ((spd == 4) ? 9 : 36); };
/// THE MENU opens on a party pawn's turn
__menu_open = function() { mn.open = true; mn.stage = "root"; mn.list = []; mn.sel = -1; mn.skill = undefined; mn.item = undefined; mn.kind = ""; };
/// a plan chosen: the action resolves, the beat runs
__commit = function(_plan) {
	mn.open = false;
	cbt_fight_act(f, f.actor, _plan);
	beat = __beat();
	play_sound_ext(snd_softclick, 1.0, 1.1, .35, 1);
};
/// the living pawns of a team
__alive = function(_team) { var _o = []; for (var _i = 0; _i < array_length(f.all); _i++) if (f.all[_i].team == _team && f.all[_i].hp > 0) array_push(_o, f.all[_i]); return _o; };
/// the result card's numbers
__result = function() {
	var _r = { won : f.won, withdrew : (f[$ "withdrew"] ?? false), turns : f.turn, rows : [] };
	for (var _i = 0; _i < array_length(f.all); _i++) { var _p = f.all[_i]; array_push(_r.rows, { name : _p.name, team : _p.team, dd : round(_p[$ "dd"] ?? 0), dt : round(_p[$ "dt"] ?? 0), hp : round(_p.hp), maxhp : round(_p.maxhp) }); }
	return _r;
};
