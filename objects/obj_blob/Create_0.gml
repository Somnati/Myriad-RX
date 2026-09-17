/// obj_blob - A SPRITE'S BODY (his idea, 2026-09-11: "cute lil debug
/// sprite... blobs with eyes"). One per g.sprites struct while the
/// money room is up (syst_sprites makes it); the struct is the truth,
/// this is its face and its hands.
///
/// THE BODY IS A RAYCAST SPHERE (sh_blob, 2026-09-11 - his ask for
/// materials): one ray per room-pixel cell, so it sits in the house's
/// pixel grammar beside the dice and the puck, lit by the same light,
/// in one of four materials (matte / glass / metal / jelly - the glass
/// is his inspiration, a bubble with a lit rim). The eyes are pixel
/// stamps over it in one of seven styles (sprite_looks); the pupils
/// LOOK AT THE POINTER where the style has them.
///
/// THE LOOP: work (it taps through tap_fire on its own cadence, hopping
/// on each) / idle (it bobs) / wander (it walks somewhere else in the
/// lower third of the room) / nap (after a long absence, until poked).
/// The state durations are weighted so its time working averages the
/// personality's `work` - the same rate sprites_tick pays headless,
/// so watching it changes nothing about what it earns.
///
/// POKE IT: it hops, its eyes go ^ ^, sparks in its colour, a squeak, a
/// line from its personality in a bubble, and its little card (name,
/// temperament, job, taps, what it did while you were away). A press on
/// it is never a tap on the surface (obj_clicker asks).

depth = -60;    // over the visualiser (50) and its passes, under the readouts

s   = undefined;   // the struct, bound by syst_sprites
sid = -1;

r     = 5;         // body radius, room px
st    = 0;         // 0 idle, 1 wander, 2 work, 3 nap
st_t  = 60;        // frames left in the state
tx    = x; ty = y; // the wander target
bob   = random(360);
blink = 0;         // frames of blink left
blink_t = random_range(90, 240);
sq    = 0;         // the squash impulse, 0..1, decays
hop   = 0;         // px of lift from a hop, decays
happy = 0;         // frames of ^ ^ eyes
bub   = "";        // the speech bubble
bub_t = 0;
// ⚖️ WHAT IT SAYS IS ON ITS OWN CLOCK, NOT THE POKE'S (his report,
// 2026-09-11: "weird that it changes each time i touch it"). The
// current line changes every few random seconds (bub_next), and a
// poke only SHOWS the current line - and only one poke in twenty
// (SPRITE_TALK_PCT); the rest are the hop and the sparks. Waking is
// its own line, always
bub_cur  = "";
bub_next = random_range(240, 720);
#macro SPRITE_TALK_PCT 5
card_open = false; // the card: up until a press lands anywhere but on it
// THE EGG IT KEEPS (his design, 2026-09-16): put down somewhere near where it arrived - a new spot every room (the blob is
// made afresh on arrival), and it stays there while the keeper works; drawn on the floor in the egg's colour
egg_x = x + random_range(-18, 18); egg_y = y + random_range(-3, 6);
// A YOUNG ONE (2026-09-16): smaller, and it trails its keeper about the room (Step)
follow_dx = random_range(-14, 14); follow_dy = random_range(2, 7);
card_a    = 0;     // ...eased, so it fades rather than pops
tap_t = 0;         // frames to the next tap while working
look_x = 0; look_y = 0;   // the pupils, eased toward the pointer

/// WHERE IT LIVES (his ask, 2026-09-13: "if they wander around then
/// shouldn't they be all over the place... not near the edge... or
/// behind the header"): the money room's whole floor, twenty px in
/// from the sides, under the header's band, above the bottom edge. The
/// tile crew (sprite_room "tiles") lives in the tile panel instead:
/// the band under its bars, and never ON the board (__wander_to)
tile_room = false;   // set each step from the job
__bounds = function() {
	if (tile_room && instance_exists(syst_tiles)) {
		// THE UPGRADES DRAWER PUSHES THEM (his ask, 2026-09-13: "crawling all
		// over my upgrades"): the patch's right edge is the drawer's face
		// while it is out - the face eases, so the clamp below walks a body
		// ahead of it rather than teleporting it
		var _x2 = room_width - 16;
		if (syst_tiles.dr_open > .001) _x2 = min(_x2, syst_tiles.__dr_face() - 12);
		return { x1 : 16, x2 : max(20, _x2), y1 : syst_tiles.board_top + 6, y2 : room_height - 26 };
	}
	return { x1 : 20, x2 : room_width - 20, y1 : 40, y2 : room_height - 24 };
};
/// a wander target inside the bounds - and, in the tile panel, not on
/// the board (a sprite standing on a tile is a sprite in the way)
__wander_to = function() {
	var _b = __bounds();
	for (var _try = 0; _try < 12; _try++) {
		var _x = random_range(_b.x1, _b.x2), _y = random_range(_b.y1, _b.y2);
		if (tile_room && instance_exists(syst_tiles)) {
			var _rows = ceil(g.tiles.slots / g.tiles.cols);
			var _bx = syst_tiles.bx - 8, _by = syst_tiles.by - 8;
			var _bw = g.tiles.cols * syst_tiles.pw + 12, _bh = _rows * syst_tiles.ph + 12;
			if (point_in_rectangle(_x, _y, _bx, _by, _bx + _bw, _by + _bh)) continue;
		}
		tx = _x; ty = _y;
		return;
	}
	tx = random_range(_b.x1, _b.x2); ty = random_range(_b.y1, _b.y2);
};

/// pick the next state, weighted so working averages the personality.
/// ⚖️ EVERY SLOT IS THE SAME LENGTH (sprites_twin, 2026-09-11): the
/// first cut gave work slots twice the length of idle ones, so the
/// live sprite spent 7-15% MORE of its time working than the
/// personality said - and than the headless runner paid when you were
/// in another room. With P(work) = work and equal slot lengths the
/// time fraction IS work, and watching it changes nothing it earns. A
/// wander walks to its spot and then stands there for the rest of its
/// slot rather than ending on arrival, for the same reason.
__next_state = function() {
	var _pl = sprite_personalities();
	var _p  = _pl[clamp(s.pers, 0, array_length(_pl) - 1)];
	st_t = random_range(200, 320);
	// SHORT OF HP OR MP (his ask, 2026-09-15): woken early, it is prone to
	// nap again when nobody is looking at it (the card closed) - the more
	// it is missing, the more likely - until it is whole
	var _short = 1 - min(s[$ "hpf"] ?? 1, s[$ "mpf"] ?? 1);
	if (_short > 0 && !card_open && random(1) < .25 + .55 * _short) {
		s.asleep = true; s.resting = true; st = 3;
		bub = choose("zzz", "...just five minutes", "ow. zzz"); bub_t = 90;
		return;
	}
	if (random(1) < _p.work) { st = 2; tap_t = min(tap_t, 30); }
	else if (random(1) < .5) st = 0;
	else {
		st = 1;
		__wander_to();
	}
};

/// the poke
/// the newcomer's lost lines (a pool, 2026-09-16)
__lost_line = function() { return choose("where am i", "must've taken a wrong turn", "how did i get here", "this isn't the marsh", "was that a door?", "...hello?", "did anyone see a road?", "i was following a light"); };
// THE ARRIVAL (his ask, 2026-09-16): a newcomer walks in from off screen, lost - a line every so often, the eyes darting -
// and settles where it was seated; then it is home (the flag rides the struct for the session only)
arrive_n = 0; look_tx = 0; look_ty = 0;
// (checked on the FIRST STEP, not here: syst_sprites binds `s` AFTER create_obj returns - reading it in the Create crashed every blob, his report 2026-09-17)
arrive_chk = false;
__poke = function() {
	var _pl = sprite_personalities();
	var _p  = _pl[clamp(s.pers, 0, array_length(_pl) - 1)];
	happy = 70;
	sq = 1; hop = 4;
	spark_burst(x, y - r * 2, 8, s.col);
	if (s.asleep) {
		s.asleep = false;
		st = 0; st_t = 60;
		bub = "wha? ...oh, hi";
		bub_t = 110;
		sprite_voice(s, "wake");
		save_mark_dirty();
	} else {
		sprite_voice(s, "poke");
		if (random(100) < SPRITE_TALK_PCT) {
			if (bub_cur == "") bub_cur = _p.lines[irandom(array_length(_p.lines) - 1)];
			bub = bub_cur;
			bub_t = 110;
		}
	}
	// the first poke ever (the newcomer) unlocks the header's [sprites] line (his ask, 2026-09-16)
	if (!variable_global_exists("sprites_met") || !g.sprites_met) { g.sprites_met = true; unfold_grant("sprites", "sprites: the header menu has them now"); }
	// (no double tap - his call, 2026-09-17: "it just squeaks... i'd rather it
	// be that way". The tooltip card is reachable from nowhere now; the sprite
	// menu is the header's [sprites] line.)
};
card_rect = undefined;   // the tooltip's rect on screen (the draw sets it; the step hit-tests it)

// the shader's handles, once
u_quad_b  = shader_get_uniform(sh_blob, "u_quad");
u_cells_b = shader_get_uniform(sh_blob, "u_cells");
u_col_b   = shader_get_uniform(sh_blob, "u_col");
u_col2_b  = shader_get_uniform(sh_blob, "u_col2");
u_mat_b   = shader_get_uniform(sh_blob, "u_mat");
u_light_b = shader_get_uniform(sh_blob, "u_light");
u_sq_b    = shader_get_uniform(sh_blob, "u_sq");
u_time_b  = shader_get_uniform(sh_blob, "u_time");
// the room's light (syst_scene_light / scene_light_bind)
s_scene_b   = shader_get_sampler_index(sh_blob, "u_scene");
s_scene_bw  = shader_get_sampler_index(sh_blob, "u_scene2");
u_sceneuv_b = shader_get_uniform(sh_blob, "u_scene_uv");
u_sceneam_b = shader_get_uniform(sh_blob, "u_scene_amt");
spk = [];   // the glass ones' orbiting specks: { a, r, ph }
repeat (3) array_push(spk, { a : random(360), r : random_range(4, 8), ph : random(360) });

/// THE CARD AND THE BUBBLE, drawn OVER every sprite (his report: the
/// popup sat behind other sprites) - syst_sprites' proxy at depth -70
/// calls this on every blob after all the bodies have drawn
__draw_over = function() {
	if (s == undefined || !visible) return;
	var _pl = sprite_personalities();
	var _p  = _pl[clamp(s.pers, 0, array_length(_pl) - 1)];
	var _lk = sprite_looks();
	var _ey = _lk.eyes[clamp(s[$ "eyes"] ?? 0, 0, array_length(_lk.eyes) - 1)];
	var _mat = s[$ "mat"] ?? 0;
	var _col = s.col;
	var _ry = r * (1 - sq * .30) + ((st == 3) ? -1 : 0);
	var _cy = y - _ry - hop + ((st == 0 || st == 3) ? dsin(bob) * .6 : 0);
	draw_set_font(fnt);

	// ---- the bubble ----
	if (bub_t > 0 && bub != "") {
		draw_set_halign(fa_center);
		var _bw = string_width(bub) + 6;
		var _bx = clamp(floor(x), _bw * .5 + 2, room_width - _bw * .5 - 2);
		var _by = floor(_cy - _ry - 14);
		var _ba = min(1, bub_t / 20);
		draw_sprite_ext(spr_pixel_1x1, 0, _bx - _bw * .5, _by - 1, _bw, 10, 0, c_black, .75 * _ba);
		draw_px_rect(_bx - _bw * .5, _by - 1, _bw, 10, _col, .6 * _ba);
		draw_set_color(c_white);
		draw_set_alpha(.95 * _ba);
		draw_text(_bx, _by + 1, bub);
		draw_set_alpha(1);
		draw_set_halign(fa_left);
	}

	// ---- the card ----
	if (card_a > .01) {
		draw_set_halign(fa_left);
		var _ri = upgrade_rarity_info(s[$ "rar"] ?? 0);
		var _mn = _lk.mats[clamp(_mat, 0, array_length(_lk.mats) - 1)].name;
		// THE SMALL TOOLTIP (his correction, 2026-09-16): the name and level, hp, mp - a tap on it opens the sprite menu
		var _pw = sprite_pawn(s), _sh = sprite_sheet(s);
		var _hpc = floor(_pw.maxhp * (s[$ "hpf"] ?? 1)), _mpc = round(_pw.maxmp * (s[$ "mpf"] ?? 1));
		var _lines = [
			s.name + "  -  lv " + string(_sh.lv),
			"hp " + string(_hpc) + " / " + string(_pw.maxhp),
			"mp " + string(_mpc) + " / " + string(_pw.maxmp),
			"tap for more",
		];
		var _cw = 0;
		for (var _k = 0; _k < 4; _k++) _cw = max(_cw, string_width(_lines[_k]));
		_cw += 10;
		var _ch = 44;
		var _cx = clamp(floor(x + r + 6), 2, room_width - _cw - 2);
		var _cy2 = clamp(floor(_cy - _ch), 20, room_height - _ch - 2);
		var _ca = card_a;
		card_rect = { x : _cx, y : _cy2, w : _cw, h : _ch };
		draw_sprite_ext(spr_pixel_1x1, 0, _cx, _cy2, _cw, _ch, 0, c_black, .82 * _ca);
		draw_px_rect(_cx, _cy2, _cw, _ch, _ri.col, .8 * _ca);
		draw_sprite_ext(spr_pixel_1x1, 0, _cx, _cy2, 2, _ch, 0, _ri.col, .95 * _ca);
		draw_set_color(_col);
		draw_set_alpha(.95 * _ca);
		draw_text(_cx + 5, _cy2 + 3, _lines[0]);
		draw_set_color(c_sgreen);
		draw_set_alpha(.9 * _ca);
		draw_text(_cx + 5, _cy2 + 13, _lines[1]);
		draw_set_color(sett_ink);
		draw_set_alpha(.8 * _ca);
		draw_text(_cx + 5, _cy2 + 23, _lines[2]);
		draw_set_color(merge_colour(sett_ink, _col, .5));
		draw_set_alpha(.45 * _ca);
		draw_text(_cx + 5, _cy2 + 33, _lines[3]);
		draw_set_alpha(1);
	}
	draw_set_color(c_white);
};

/// is this press mine? (obj_clicker asks before it taps the surface)
__hit = function(_mx, _my) {
	return point_distance(_mx, _my, x, y - r) <= r + 4;
};
