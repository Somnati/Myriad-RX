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

/// the fight begins: the crew as it is (copies of its potions), the opponent as set
__start = function() {
	var _party = [];
	for (var _i = 0; _i < array_length(picked); _i++) {
		var _sp = exped_sprite(picked[_i]);
		if (is_undefined(_sp)) continue;
		var _pw = sprite_pawn(_sp);
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
