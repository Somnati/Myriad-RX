/// THE UPGRADES PANEL, the overhaul (his ask, 2026-09-11: "clean, easy
/// on the eyes and polished with a well laid out minimal look"; an
/// OVERLAY since 2026-09-12). Two columns on one grid: the SLOT TABLE
/// left, the INSPECTOR right (under it in portrait), the purse pinned
/// in the corner by the Step, the totals behind the [modifiers] button
/// as a list over everything. Everything is spr_pixel_1x1 stamps and
/// the house font, and all of it rides the open ease (one part - the
/// panel is dense enough that dealing rows in one by one read as a
/// stutter on the automation panel).
///
/// A ROW SAYS FOUR THINGS: what (the name), how much (the effect, right
/// of it), how deep (the tier dots under the name, lit for the tiers
/// bought), and the price (the one button the mode decides). THE ROW
/// IS A DECK CAPSULE (his ask): a ROUND end off capsule_bevel, the
/// rarity colour at the left edge fading to near-black at the right,
/// the name in that colour - obj_ability_slot's recipe at this height.

draw_set_font(fnt);
draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

var _ea = ui_anim_in(oa, 1);
if (_ea < .001) exit;
var _eo = (1 - _ea) * UI_IN_DEAL;
if (_eo != 0) matrix_set(matrix_world, matrix_build(0, _eo, 0, 0, 0, 0, 1, 1, 1));
ui_fade_set(_ea);

var _dim = rgb(120, 130, 150);
var _ink = sett_ink;
var _n   = upgrade_slots();
var _ub  = upgrade_bonus();   // the TRUTH, not the gated reader - this
                              // screen shows what the slots would do
                              // even while UPG_LIVE keeps them idle

// ==================== THE TITLE STRIP ====================
draw_sprite_ext(spr_pixel_1x1, 0, 0, bby, room_width, list_y - bby, 0,
	c_hsv(169, 186, 5), 1);
draw_sprite_ext(spr_pixel_1x1, 0, 0, list_y - 1, room_width, 1, 0, _ink, .25);
draw_set_color(rgb(195, 205, 235));
draw_set_alpha(.85);
draw_text(6, bby + 5, "upgrades");

// the mode switch: one pill, two halves, the live one filled in its
// colour and the other sunk to black
var _mname = ["buy", "sell"];
var _mcol  = [c_sgreen, c_lavender];
var _m0 = __mode_rect(0), _m1 = __mode_rect(1);
draw_set_alpha(1);
draw_sprite_ext(spr_pixel_1x1, 0, _m0.x, _m0.y, _m0.w + _m1.w, _m0.h, 0, c_black, .8);
for (var _m = 0; _m < 2; _m++) {
	var _r = __mode_rect(_m);
	var _on = (mode == _m);
	var _hov = point_in_rectangle(mouse_x, mouse_y, _r.x, _r.y, _r.x + _r.w, _r.y + _r.h);
	if (_on)
		draw_sprite_ext(spr_pixel_1x1, 0, _r.x, _r.y, _r.w, _r.h, 0,
			merge_colour(_mcol[_m], c_black, .55), .95);
	draw_set_halign(fa_center);
	draw_set_color(_on ? c_white : merge_colour(_mcol[_m], c_white, _hov ? .6 : .25));
	draw_set_alpha(_on ? .95 : .7);
	draw_text(_r.x + _r.w / 2 + 1, _r.y + 3, _mname[_m]);
}
draw_px_rect(_m0.x, _m0.y, _m0.w + _m1.w, _m0.h, _mcol[mode], .7);
draw_set_halign(fa_left);

// THE PURSE IS NOT DRAWN HERE (his call, DE's behaviour): the credit
// panel is a real object that knows how to draw a balance, glide it
// and flash on a drop; the Step pins it into the bottom-left corner.

// [modifiers]: the totals as a list (DE's "view modifiers")
var _md = __mod_rect();
__btn_draw(_md.x, _md.y, _md.w, _md.h, "modifiers", c_lavender, true, mod_open);

// the strip's message seat, after the title (the mode pill took the
// right): what just happened (fading), else the not-live warning while
// it applies. One seat, so the strip never grows a second line
draw_set_halign(fa_left);
if (msg_hp > 0 && msg != "") {
	draw_set_color(msg_col);
	draw_set_alpha(.9 * min(1, msg_hp / 40));
	draw_text(64, bby + 5, msg);
} else if (!UPG_LIVE && land) {
	// ⚖️ AND SAY SO WHILE IT IS OFF. A screen that quotes bonuses the
	// game is not applying, without saying so, is a screen that lies.
	draw_set_color(c_horange);
	draw_set_alpha(.5);
	draw_text(64, bby + 5, "preview - not live yet");
} else if (land) {
	// THE UPGRADE LEVEL (DE's "exp x / y" under the trade toggle): the
	// level, and how far the xp has climbed toward the next one
	draw_set_color(c_gold);
	draw_set_alpha(.7);
	draw_text(64, bby + 5, "level " + string(g.upg.level));
	draw_set_color(_dim);
	draw_set_alpha(.6);
	draw_text(64 + string_width("level " + string(g.upg.level)) + 6, bby + 5,
		"xp " + string(floor(g.upg.xp)) + " / " + string(upgrade_level_need()));
}

// ==================== THE SLOT TABLE ====================
// Every row of the table, bought or not: the slots you own, then THE
// NEW-SLOT ROW (his ask, 2026-09-17: "the new slot shown with a 'new
// slot' upgrade in it and buying that upgrade frees the slot"), then
// the slots still locked behind it as quiet plates. No roll row any
// more - offers turn up by DE's meter (upgrade_meter_tick).
var _eff_r  = row_x + row_w - 54 - 8;   // the effect column's right edge
var _filled = 0;
var _nr     = __new_row();
var _wait_said = false;

for (var _i = 0; _i < UPG_SLOT_MAX; _i++) {
	var _ry  = __row_y(_i);
	var _hov = (sel == _i);

	// ---- a slot not yet bought: only the NEXT one shows, as the
	// new-slot row (his call, 2026-09-17: no "locked" rows) ----
	if (_i >= _n) {
		if (_i != _nr) continue;
		{
			// the "new slot" upgrade, sitting in the slot it unlocks: a
			// common plate, the name, the price - never a sell button
			var _ncol = __rar_col(0);
			__plate(row_x, _ry, row_w, row_h, 0, merge_colour(_ncol, c_black, .55));
			if (pick == -2 || _hov) {
				__rr(row_x, _ry, row_w, row_h, c_aqua, (pick == -2) ? .95 : .4);
				__plate(row_x + 1, _ry + 1, row_w - 2, row_h - 2, 0, merge_colour(_ncol, c_black, .55));
			}
			if (hold_i == _i && hold_hp > 0)
				__rr(row_x, _ry, row_w * (hold_hp / 100), row_h, merge_colour(c_sgreen, c_black, .3), .55);
			draw_set_color(c_white);
			draw_set_alpha(.9);
			draw_text(row_x + 10, _ry + 3, "new slot");
			draw_set_color(_dim);
			draw_set_alpha(.55);
			draw_text(row_x + 10, _ry + 11, "one more, permanently");
			draw_set_halign(fa_right);
			draw_set_color(_dim);
			draw_set_alpha(.75);
			draw_text(_eff_r, _ry + 5, "+1 slot");
			draw_set_halign(fa_left);
			var _nb = __btn(_i);
			if (mode == 0) {
				var _ncost = upgrade_slot_cost();
				var _naff  = (_ncost > 0) && (g.credits >= arb(_ncost));
				__btn_draw(_nb.x, _nb.y, _nb.w, _nb.h, string(_ncost), _naff ? c_sgreen : c_hred, true, _naff);
			} else {
				__btn_draw(_nb.x, _nb.y, _nb.w, _nb.h, "-", c_lavender, false, false);
			}
		}
		continue;
	}

	var _s   = g.upg.slot[_i];
	var _has = is_struct(_s);

	// ---- an empty row: the first one says an offer is on its way,
	// the rest say nothing ----
	if (!_has) {
		__rr_grad(row_x, _ry, row_w, row_h,
			merge_colour(_dim, c_black, .7), merge_colour(_dim, c_black, .95), 1);
		__inner(row_x, _ry, row_w, row_h);
		draw_set_color(_dim);
		draw_set_alpha(.35);
		draw_text(row_x + 10, _ry + 5, _wait_said ? "empty" : "waiting for an upgrade");
		_wait_said = true;
		continue;
	}
	_filled++;

	var _e    = upgrade_entry(_s.id);
	var _cap  = upgrade_cap(_i);
	var _name = (_e == -1) ? _s.id : _e.name;
	var _rcl  = __rar_col(_s.rar);
	var _own  = (_s.tier > 0);
	var _done = (_s.tier >= _cap);

	// ---- THE CAPSULE (obj_ability_slot's): the rarity colour at the
	// left fading to near-black at the right, brighter once owned - an
	// offer sits dimmer, the deck's "not yet on" ----
	// ...AS AN OUTLINE (his ask, 2026-09-12: the inspector's method on
	// the rows): the gradient capsule, then a black capsule a pixel
	// inside it on the left, top and bottom - the rim carries the
	// rarity, the words sit on black
	// ...and the coloured stretch of that rim is as long as the rarity
	// is high (DE's trick, his ask) - __plate
	__plate(row_x, _ry, row_w, row_h, _s.rar, merge_colour(_rcl, c_black, _own ? .15 : .5));
	// PICKED / HOVERED: DE's selected slot (obj_upgrade_slot frame 3) - an
	// AQUA RIM round the capsule, full when picked, quiet under the pointer
	// (his call, 2026-09-13: the white wash over the whole row went). A
	// full outline, all four sides, the words still on black inside it
	if (pick == _i || _hov) {
		__rr(row_x, _ry, row_w, row_h, c_aqua, (pick == _i) ? .95 : .4);
		// ...and the plate again INSIDE the rim, gradient and all (his
		// report, 2026-09-14: the black fill here wiped the rarity's reach
		// off a highlighted slot - DE keeps it)
		__plate(row_x + 1, _ry + 1, row_w - 2, row_h - 2, _s.rar, merge_colour(_rcl, c_black, _own ? .15 : .5));
	}
	// ---- THE HOLD BAR (DE's): a wash sweeping the WHOLE ROW - what is
	// being spent, or consumed, is the slot. GREEN AND LINEAR to buy,
	// RED AND SQUARED to sell (the squared one crawls at the start, so a
	// tap that was not meant to be a hold barely moves it) ----
	if (hold_i == _i && hold_hp > 0) {
		var _hf = hold_hp / 100;
		if (mode == 1) _hf *= _hf;
		var _hc = merge_colour((mode == 0) ? c_sgreen : c_hred, c_black, .3);
		__rr(row_x, _ry, row_w * _hf, row_h, _hc, .55);
	}

	// what - in the rarity colour, lit toward white once owned (the
	// deck's "on" name)
	draw_set_color(_own ? merge_colour(_rcl, c_white, .5) : _rcl);
	draw_set_alpha(_own ? .95 : .8);
	draw_text(row_x + 10, _ry + 3, _name);
	// how deep
	__dots(_i, _ry);
	if (_done) {
		draw_set_color(c_gold);
		draw_set_alpha(.7);
		draw_text(row_x + 10, _ry + 11, "complete");
	}
	// how much - the effect right-aligned before the button; an offer
	// quotes what a tier is worth, dimmer (no "a tier" - noise, his call)
	draw_set_halign(fa_right);
	if (_e == -1) {
		draw_set_color(_dim);
		draw_set_alpha(.6);
		draw_text(_eff_r, _ry + 5, "retired");
	} else if (_e.stat == "") {
		// a grant has no running effect to quote - it does one thing once;
		// a BURST quotes its multiplier and its clock (2026-09-16)
		var _bst = (_e[$ "burst"] ?? false);
		draw_set_color(_bst ? merge_colour(_e.col, c_white, .25) : _dim);
		draw_set_alpha(.75);
		draw_text(_eff_r, _ry + 5, _bst ? __burst_str(_s) : "one-off");
	} else if (_own) {
		draw_set_color((_e.col == c_white) ? c_white : merge_colour(_e.col, c_white, .25));
		draw_set_alpha(.95);
		draw_text(_eff_r, _ry + 5, __eff_str(_i));
	} else {
		draw_set_color(_dim);
		draw_set_alpha(.75);
		draw_text(_eff_r, _ry + 5, __eff_str(_i));
	}
	draw_set_halign(fa_left);

	// the price - the one button, whatever the mode says it is
	var _b = __btn(_i);
	if (mode == 0) {
		var _cost   = upgrade_cost(_i);
		var _afford = (_cost > 0) && (g.credits >= arb(_cost));
		__btn_draw(_b.x, _b.y, _b.w, _b.h,
			(_cost < 0) ? "max" : string(_cost),
			_afford ? c_sgreen : c_hred, _cost > 0, _afford);
	} else {
		// every slot quotes a price, an untouched offer included (it
		// cost a stake to be here) - see upgrade_sell_value
		__btn_draw(_b.x, _b.y, _b.w, _b.h,
			string(upgrade_sell_value(_i)), c_lavender, true, true);
	}
}

// ==================== THE INSPECTOR ====================
// The TOP says what the thing is, in words; the BOTTOM is a ledger of
// banded lines about the bonus - darkest last, where the total lives.
// THE PLATE IS AN OUTLINE (his ask, 2026-09-12): the rarity gradient
// capsule, then a black capsule one pixel inside it on the left, top
// and bottom - so the gradient shows as a rim that is brightest at the
// left and fades out along the edges, and the middle where the words
// sit stays black. The right edge needs no rim: the gradient is black
// there anyway.
draw_set_alpha(1);
var _dc = merge_colour(c_hsv(168, 160, 5), c_black, .3);
// && short-circuits, so an out-of-range pick never indexes the array -
// which it can be for a frame after the slot count changes
var _has_pick = (pick >= 0 && pick < _n && is_struct(g.upg.slot[pick]));
var _new_pick = (pick == -2 && _nr != -1);   // the "new slot" row, read
// THE RECEIPT (pick -3): the upgrade whose last tier was just bought. Its
// slot is free, so it reads from the snapshot upgrade_complete left, not
// from the table (his report, 2026-09-17: the box went blank with the slot)
var _done_pick = (pick == -3 && variable_struct_exists(g.upg, "last_done")
                  && is_struct(g.upg.last_done));
if (_new_pick) {
	__rr(desc_x, desc_y, desc_w, desc_h, _dc, 1);
	__rr_grad_l(desc_x, desc_y, __rar_grad(0, desc_w, c_black).w, desc_h,
		merge_colour(__rar_col(0), c_black, .2), _dc, 1);
} else if (_has_pick || _done_pick) {
	// the picked row's plate, at the inspector's size: the rim's
	// coloured reach says the rarity here too
	// (the plate under the rim is the inner's own colour: no line past
	// the reach - the rows' rule)
	var _prar = _done_pick ? g.upg.last_done.rar : g.upg.slot[pick].rar;
	__rr(desc_x, desc_y, desc_w, desc_h, _dc, 1);
	__rr_grad_l(desc_x, desc_y, __rar_grad(_prar, desc_w, c_black).w, desc_h,
		merge_colour(__rar_col(_prar), c_black, .2), _dc, 1);
} else {
	__rr_grad(desc_x, desc_y, desc_w, desc_h,
		merge_colour(_ink, c_black, .6), _dc, 1);
}
__inner(desc_x, desc_y, desc_w, desc_h, _dc);

var _px = desc_x + 10;
var _pr = desc_x + desc_w - 8;

if (_new_pick) {
	// THE NEW SLOT, read: what it is, what it costs, that it is never sold
	draw_set_color(c_white);
	draw_set_alpha(.95);
	draw_text(_px, desc_y + 7, "new slot");
	draw_set_color(_dim);
	draw_set_alpha(.8);
	draw_text(_px, desc_y + 18, "slot " + string(_n + 1) + " of " + string(UPG_SLOT_MAX));
	if (desc_h >= 110) {
		draw_sprite_ext(spr_pixel_1x1, 0, _px, desc_y + 30, desc_w - 18, 1, 0, __rar_col(0), .35);
		draw_set_color(_ink);
		draw_set_alpha(.75);
		draw_text_ext(_px, desc_y + 37, "one more upgrade slot, permanently. bought, never sold.", 9, desc_w - 18);
		draw_set_color(_dim);
		draw_set_alpha(.5);
		draw_text(_px, desc_y + desc_h - 6 - 12 - 11, (mode == 0) ? "hold the price to buy" : "buy mode buys it");
	}
	var _nly = desc_y + desc_h - 6 - 12;
	draw_sprite_ext(spr_pixel_1x1, 0, desc_x + 6, _nly, desc_w - 12, 11, 0, c_black, .3);
	draw_set_halign(fa_left);
	draw_set_color(_dim);
	draw_set_alpha(.65);
	draw_text(_px, _nly + 3, "price");
	draw_set_halign(fa_right);
	draw_set_color(c_white);
	draw_set_alpha(.95);
	draw_text(_pr - 2, _nly + 3, string(upgrade_slot_cost()) + " credits");
	draw_set_halign(fa_left);
} else if (!_has_pick && !_done_pick) {
	draw_set_halign(fa_center);
	draw_set_color(_dim);
	draw_set_alpha(.4);
	var _mid = desc_x + desc_w / 2;
	draw_text(_mid, desc_y + desc_h / 2 - 12, "tap a slot to read it");
	draw_set_alpha(.28);
	draw_text(_mid, desc_y + desc_h / 2 - 1,
		string(_filled) + " of " + string(_n) + " slots in use");
	draw_set_halign(fa_left);
} else {
	// a live slot, or the receipt of the one just finished - the same
	// page, read from the snapshot when the slot is gone
	var _ps   = _done_pick ? g.upg.last_done : g.upg.slot[pick];
	var _pe   = upgrade_entry(_ps.id);
	var _pc   = __rar_col(_ps.rar);
	var _pcap = _done_pick ? _ps.cap : upgrade_cap(pick);

	// ---- the top: what it IS ----
	draw_set_color(c_white);
	draw_set_alpha(.95);
	draw_text(_px, desc_y + 7, (_pe == -1) ? _ps.id : _pe.name);
	draw_set_color(_pc);
	draw_set_alpha(.9);
	draw_text(_px, desc_y + 18, __rar_name(_ps.rar));
	// ...and the upgrade level it was rolled at (it keeps it - DE's u_lv)
	if (_pe != -1 && _pe.stat != "") {
		draw_set_color(_dim);
		draw_set_alpha(.7);
		draw_text(_px + string_width(__rar_name(_ps.rar)) + 6, desc_y + 18, "lv " + string(_ps[$ "lv"] ?? 1));
	}
	// (an offer says nothing here - "offer N tiers" was noise, his call;
	// the bubbles on its row already count the tiers)
	if (_ps.tier > 0) {
		draw_set_halign(fa_right);
		draw_set_color(_dim);
		draw_set_alpha(.8);
		draw_text(_pr, desc_y + 18, "tier " + string(_ps.tier) + " / " + string(_pcap));
		draw_set_halign(fa_left);
	}
	// a rule in the rarity's colour under the head, then the words -
	// unless the panel is the portrait stub, which has room for the
	// head and the ledger's first line only
	var _compact = (desc_h < 110);
	if (!_compact) {
		draw_sprite_ext(spr_pixel_1x1, 0, _px, desc_y + 30, desc_w - 18, 1, 0, _pc, .35);
		draw_set_color(_ink);
		draw_set_alpha(.75);
		draw_text_ext(_px, desc_y + 37,
			(_pe == -1) ? "no longer in the roster" : _pe.help, 9, desc_w - 18);
	}

	// ---- the bottom: the ledger ----
	// what the NEXT tier buys, what THIS slot gives (once it gives
	// anything - "+0% until bought" said nothing, his call), what you
	// HOLD across everything. Reading down is reading outward.
	var _rows_txt = [];
	if (_pe != -1 && _pe.stat != "") {
		// ONE LINE (his spec, 2026-09-17: "dial boost  +5% (145%)"): this
		// tier's worth - the one the button buys - and in brackets the
		// total held from every upgrade of this kind (a per-dial boost
		// totals on its own dial's lane)
		var _tot = (_pe.stat == "dial_one") ? _ub.dial_one[_pe.dial] : _ub[$ _pe.stat];
		// the receipt reads what the FILING was worth (its last tier,
		// completion bonus and all - already in the total)
		var _tv  = _done_pick ? _ps.worth : __tier_v(pick);
		array_push(_rows_txt,
			{ k : _done_pick ? _pe.name + " filed" : _pe.name,
			  v : "+" + string_format(_tv, 1, 2) + "% (" + string_format(_tot, 1, 0) + "%)",
			  c : merge_colour(_pe.col, c_white, .3) });
	} else if (_pe != -1 && (_pe[$ "burst"] ?? false)) {
		// A BURST (2026-09-16): what it pays, for how long, and the rule
		array_push(_rows_txt,
			{ k : "burst", v : __burst_str(_ps), c : c_sgreen });
		array_push(_rows_txt,
			{ k : "gives", v : _pe.help, c : c_white });
		array_push(_rows_txt,
			{ k : "stacking", v : "same kind adds up, own clocks", c : _dim });
	} else {
		array_push(_rows_txt,
			{ k : "a one-off", v : "spent when bought", c : _dim });
		array_push(_rows_txt,
			{ k : "gives", v : (_pe == -1) ? "-" : _pe.help, c : c_white });
		array_push(_rows_txt,
			{ k : "slots", v : string(upgrade_slots()) + " / "
			  + string(UPG_SLOT_MAX), c : c_white });
	}
	if (_compact) _rows_txt = [_rows_txt[0]];
	// the mode's verb over the ledger, so what the button does is
	// written where you read about the thing
	var _lh = 12;
	var _ly = desc_y + desc_h - 6 - array_length(_rows_txt) * _lh;
	if (!_compact) {
		draw_set_color(_dim);
		draw_set_alpha(.5);
		var _verb = "hold the price to sell";
		if (_done_pick) _verb = "complete - filed to the ledger, slot freed";
		else if (mode == 0) _verb = (upgrade_cost(pick) < 0) ? "at its last tier" : "hold the price to buy";
		draw_text(_px, _ly - 11, _verb);
	}
	for (var _q = 0; _q < array_length(_rows_txt); _q++) {
		var _ln = _rows_txt[_q];
		// light to dark down the stack, so the eye lands on the total
		draw_sprite_ext(spr_pixel_1x1, 0, desc_x + 6, _ly, desc_w - 12, _lh - 1,
			0, c_black, .14 + .16 * _q);
		draw_set_halign(fa_left);
		draw_set_color(_dim);
		draw_set_alpha(.65);
		draw_text(_px, _ly + 3, _ln.k);
		draw_set_halign(fa_right);
		draw_set_color(_ln.c);
		draw_set_alpha(.95);
		draw_text(_pr - 2, _ly + 3, _ln.v);
		_ly += _lh;
	}
	draw_set_halign(fa_left);
}

// ==================== THE MODIFIERS LIST ====================
// DE's "view modifiers" (obj_upgrades_stats), rebuilt: a dark sheet
// over the panel from the strip down, then one line per total in
// sections - a section is a band in its colour, a line is label left /
// value right, the zero ones dim. It eases in on mod_a; a tap anywhere
// folds it (the Step).
if (mod_a > .001) {
	ui_fade_set(_ea * mod_a);
	var _ty = list_y;
	// MUCH DARKER (his report, 2026-09-12: the rows clashed with what
	// was behind them) - the sheet is near-solid, and the list sits on
	// a solid plate of its own
	draw_sprite_ext(spr_pixel_1x1, 0, 0, _ty, room_width, room_height - _ty, 0, c_black, .96);
	var _lx = land ? (room_width div 2 - 150) : 8;
	var _lw = land ? 300 : (room_width - 16);
	var _lr = _lx + _lw;
	var _yy = _ty + 8;
	var _lh2 = 11;
	draw_sprite_ext(spr_pixel_1x1, 0, _lx - 6, _ty + 3, _lw + 12, room_height - _ty - 8, 0, c_black, 1);
	draw_px_rect(_lx - 6, _ty + 3, _lw + 12, room_height - _ty - 8, c_lavender, .25);
	var _pri = merge_colour(c_white, merge_colour(c_black, c_sblue, .15), .5);   // DE's c_primary
	// the head: what the sheet is, and the tally
	draw_set_halign(fa_left);
	draw_set_color(c_lavender);
	draw_set_alpha(.95);
	draw_text(_lx + 3, _yy, "modifiers");
	draw_set_halign(fa_right);
	draw_set_color(_dim);
	draw_set_alpha(.7);
	draw_text(_lr - 3, _yy, "tap anywhere to close");
	_yy += _lh2 + 3;
	draw_sprite_ext(spr_pixel_1x1, 0, _lx, _yy - 4, _lw, _lh2, 0, c_black, .25);
	draw_set_halign(fa_left);
	draw_set_color(_pri);
	draw_set_alpha(.9);
	draw_text(_lx + 3, _yy - 2, "upgrades bought");
	draw_set_halign(fa_right);
	draw_set_color(c_white);
	draw_text(_lr - 3, _yy - 2, string(g.upg.total));
	_yy += _lh2;
	draw_sprite_ext(spr_pixel_1x1, 0, _lx, _yy - 4, _lw, _lh2, 0, c_black, .25);
	draw_set_halign(fa_left);
	draw_set_color(_pri);
	draw_text(_lx + 3, _yy - 2, "slots rolled");
	draw_set_halign(fa_right);
	draw_set_color(c_white);
	draw_text(_lr - 3, _yy - 2, string(g.upg.rolls));
	_yy += _lh2;

	// the sections: one per stat family, every stat in it (zeros dim,
	// so the sheet also says what CAN be raised)
	// THE REWORK'S SHEET (2026-09-16): the tap, every dial you own with
	// its own lane beside the all-dial number (they multiply), and the
	// bursts running right now with their clocks
	var _dl = [ { k : "all dials", v : _ub.dial_profit, s : "%" } ];
	for (var _di = 0; _di < g.dial_total; _di++) {
		if (g.dial[_di].level <= 0 && _ub.dial_one[_di] <= 0) continue;
		array_push(_dl, { k : "dial " + dial_config(_di).name, v : _ub.dial_one[_di], s : "%" });
	}
	var _bl = [];
	var _bb = g.upg[$ "bursts"];
	var _bnow = universal_now();
	if (is_array(_bb)) for (var _bi = 0; _bi < array_length(_bb); _bi++) {
		var _bx = _bb[_bi];
		var _lft = _bx.ends - _bnow;
		if (_lft <= 0) continue;
		array_push(_bl, { k : _bx.kind + " burst   " + __mmss(_lft) + " left", v : _bx.mult, s : "", x : true });
	}
	if (array_length(_bl) == 0) array_push(_bl, { k : "none running", v : 0, s : "", t : "-" });
	var _secs = [
		{ n : "tapper", c : c_gold, rows : [
			{ k : "tap profit",      v : _ub.tap_profit,  s : "%" } ] },
		{ n : "dials", c : c_sgreen, rows : _dl },
		{ n : "bursts", c : c_horange, rows : _bl },
	];
	for (var _si = 0; _si < array_length(_secs); _si++) {
		var _sc = _secs[_si];
		var _c1 = merge_colour(_sc.c, c_black, .65);
		draw_sprite_general(spr_pixel_1x1, 0, 0, 0, 1, 1, _lx, _yy - 4, _lw, _lh2, 0,
			_c1, c_black, c_black, _c1, .7);
		draw_set_halign(fa_left);
		draw_set_color(_sc.c);
		draw_set_alpha(.95);
		draw_text(_lx + 3, _yy - 2, "// " + _sc.n);
		_yy += _lh2;
		for (var _ri = 0; _ri < array_length(_sc.rows); _ri++) {
			var _rw = _sc.rows[_ri];
			var _zero = (_rw.v <= 0);
			if (_ri & 1) draw_sprite_ext(spr_pixel_1x1, 0, _lx, _yy - 4, _lw, _lh2, 0, c_black, .25);
			draw_set_halign(fa_left);
			draw_set_color(_zero ? _dim : _pri);
			draw_set_alpha(_zero ? .5 : .9);
			draw_text(_lx + 3, _yy - 2, "   " + _rw.k);
			draw_set_halign(fa_right);
			draw_set_color(_zero ? _dim : c_white);
			draw_set_alpha(_zero ? .5 : .95);
			if (variable_struct_exists(_rw, "t"))
				draw_text(_lr - 3, _yy - 2, _rw.t);
			else if (_rw[$ "x"] ?? false)
				draw_text(_lr - 3, _yy - 2, "x" + string_format(_rw.v, 1, 2));
			else if (_rw[$ "raw"] ?? false)
				draw_text(_lr - 3, _yy - 2, string_format(_rw.v, 1, 0) + _rw.s);
			else
				draw_text(_lr - 3, _yy - 2,
					((_rw[$ "neg"] ?? false) ? "-" : "+") + string_format(_rw.v, 1, 2) + _rw.s);
			_yy += _lh2;
		}
	}
	// ⚖️ AND SAY SO WHILE IT IS OFF (the strip's warning, repeated where
	// the numbers are read)
	if (!UPG_LIVE) {
		draw_set_halign(fa_center);
		draw_set_color(c_horange);
		draw_set_alpha(.7);
		draw_text(room_width div 2, _yy + 2, "preview - none of this is applied to the game yet");
	}
	draw_set_halign(fa_left);
}

ui_fade_set(1);   // never leave the shader on for the next drawer
if (_eo != 0) matrix_set(matrix_world, matrix_build_identity());
draw_set_alpha(1);
draw_set_color(c_white);
