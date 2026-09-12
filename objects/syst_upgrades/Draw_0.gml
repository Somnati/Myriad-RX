/// THE UPGRADES SCREEN, the overhaul (his ask, 2026-09-11: "clean,
/// easy on the eyes and polished with a well laid out minimal look").
/// Two columns on one grid: the SLOT TABLE left, the INSPECTOR right,
/// the bonus totals in a band under the table, the purse pinned in the
/// bottom-left corner by the Step. Everything is spr_pixel_1x1 stamps
/// and the house font; no gradients but the rows' edge seams.
///
/// A ROW SAYS FOUR THINGS: what (the name), how much (the effect, right
/// of it), how deep (the tier dots under the name, lit for the tiers
/// bought), and the price (the one button the mode decides). THE ROW
/// IS A DECK CAPSULE (his ask, 2026-09-12): bevelled ends off the
/// endcap silhouette, the rarity colour at the left edge fading to
/// near-black at the right, the name in that colour - obj_ability_slot's
/// recipe at this row height. The inspector names the rarity in words.

draw_set_font(fnt);
draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

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

var _bk = __back_rect();
draw_ui_back(_bk.x1, _bk.y1, _bk.x2 - _bk.x1, _bk.y2 - _bk.y1);

// the strip's message seat, right of centre before the back button:
// what just happened (fading), else the not-live warning while it
// applies. One seat, so the strip never grows a second line
draw_set_halign(fa_right);
if (msg_hp > 0 && msg != "") {
	draw_set_color(msg_col);
	draw_set_alpha(.9 * min(1, msg_hp / 40));
	draw_text(_bk.x1 - 8, bby + 5, msg);
} else if (!UPG_LIVE) {
	// ⚖️ AND SAY SO WHILE IT IS OFF. A screen that quotes bonuses the
	// game is not applying, without saying so, is a screen that lies.
	draw_set_color(c_horange);
	draw_set_alpha(.6);
	draw_text(_bk.x1 - 8, bby + 5, "preview - not live yet");
}
draw_set_halign(fa_left);

// ==================== THE SLOT TABLE ====================
var _fs  = __free_slot();
var _rc  = upgrade_roll_cost();
var _ra  = (_fs != -1) && (_rc <= 0 || g.credits >= arb(_rc));
var _eff_r  = row_x + row_w - 54 - 8;   // the effect column's right edge
var _filled = 0;

for (var _i = 0; _i < _n; _i++) {
	var _ry  = __row_y(_i);
	var _s   = g.upg.slot[_i];
	var _has = is_struct(_s);
	var _hov = (sel == _i);

	// ---- an empty row: the roll row if it is the first, else a
	// quiet plate that says so and nothing more ----
	if (!_has) {
		if (_i == _fs) {
			// the roll row: a blue capsule (red when short), brighter
			// under the pointer
			var _rcol = _ra ? c_sblue : c_hred;
			__rr_grad(row_x, _ry, row_w, row_h,
				merge_colour(_rcol, c_black, _ra ? (_hov ? .5 : .62) : .8),
				merge_colour(_rcol, c_black, .94), 1);
			draw_set_color(_ra ? merge_colour(_rcol, c_white, .55) : c_gray);
			draw_set_alpha(.95);
			draw_text(row_x + 8, _ry + 5, "+ roll a slot");
			draw_set_halign(fa_right);
			draw_set_color(_ra ? c_white : c_gray);
			draw_set_alpha(.8);
			draw_text(row_x + row_w - 8, _ry + 5, (_rc > 0) ? (string(_rc) + " cr") : "free");
			draw_set_halign(fa_left);
		} else {
			// an empty capsule: the deck's near-black, a whisper of grey
			__rr_grad(row_x, _ry, row_w, row_h,
				merge_colour(_dim, c_black, .82), merge_colour(_dim, c_black, .95), 1);
			draw_set_color(_dim);
			draw_set_alpha(.35);
			draw_text(row_x + 8, _ry + 5, "empty");
		}
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
	var _cl = merge_colour(_rcl, c_black, _own ? .45 : .72);
	var _cr = merge_colour(_rcl, c_black, .94);
	__rr_grad(row_x, _ry, row_w, row_h, _cl, _cr, 1);
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
	// picked: the deck's soft white echo over the whole capsule;
	// hovered: a whisper of it
	if (pick == _i) __rr(row_x, _ry, row_w, row_h, c_white, .14);
	else if (_hov) __rr(row_x, _ry, row_w, row_h, c_white, .05);

	// what - in the rarity colour, lit toward white once owned (the
	// deck's "on" name)
	draw_set_color(_own ? merge_colour(_rcl, c_white, .5) : _rcl);
	draw_set_alpha(_own ? .95 : .8);
	draw_text(row_x + 8, _ry + 3, _name);
	// how deep
	__dots(_i, _ry);
	if (_done) {
		draw_set_color(c_gold);
		draw_set_alpha(.7);
		draw_text(row_x + 8, _ry + 11, "complete");
	} else if (!_own) {
		draw_set_color(_dim);
		draw_set_alpha(.6);
		draw_text(row_x + 8 + ((_cap > 1) ? (_cap * 4 + 3) : 0), _ry + 11, "offer");
	}
	// how much - the effect right-aligned before the button; an offer
	// quotes what a tier is worth, dimmer
	draw_set_halign(fa_right);
	if (_e == -1) {
		draw_set_color(_dim);
		draw_set_alpha(.6);
		draw_text(_eff_r, _ry + 5, "retired");
	} else if (_e.stat == "") {
		// a grant has no running effect to quote - it does one thing once
		draw_set_color(_dim);
		draw_set_alpha(.75);
		draw_text(_eff_r, _ry + 5, "one-off");
	} else if (_own) {
		draw_set_color((_e.col == c_white) ? c_white : merge_colour(_e.col, c_white, .25));
		draw_set_alpha(.95);
		draw_text(_eff_r, _ry + 5, __eff_str(_i));
	} else {
		draw_set_color(_dim);
		draw_set_alpha(.75);
		draw_text(_eff_r, _ry + 5, __eff_str(_i) + " a tier");
	}
	draw_set_halign(fa_left);

	// the price - the one button, whatever the mode says it is
	var _b = __btn(_i);
	if (mode == 0) {
		var _cost   = upgrade_cost(_i);
		var _afford = (_cost > 0) && (g.credits >= arb(_cost));
		draw_ui_button(_b.x, _b.y, _b.w, _b.h,
			(_cost < 0) ? "max" : string(_cost),
			_afford ? c_sgreen : c_hred, _cost > 0, _afford);
	} else {
		// every slot quotes a price, an untouched offer included (it
		// cost a stake to be here) - see upgrade_sell_value
		draw_ui_button(_b.x, _b.y, _b.w, _b.h,
			string(upgrade_sell_value(_i)), c_lavender, true, true);
	}
}

// ==================== THE TOTALS BAND ====================
// What all of it adds up to - the thing a player actually wants from
// a list of purchases. A hairline, then six totals in two lines of
// three, label dim and value in the stat's colour
draw_sprite_ext(spr_pixel_1x1, 0, row_x, tot_y, row_w, 1, 0, _ink, .18);
var _tot = [
	{ l : "tap",     v : "+" + string_format(_ub.tap_profit,  1, 0) + "%", c : c_gold },
	{ l : "dials",   v : "+" + string_format(_ub.dial_profit, 1, 0) + "%", c : c_sgreen },
	{ l : "speed",   v : "+" + string_format(_ub.dial_speed,  1, 0) + "%", c : c_sblue },
	{ l : "crit",    v : "+" + string_format(_ub.crit_rate,   1, 0) + "%", c : c_horange },
	{ l : "cost",    v : "-" + string_format(_ub.dial_cost,   1, 0) + "%", c : c_steelblue },
	{ l : "credits", v : "+" + string_format(_ub.credit_rate, 1, 0) + "%", c : c_lavender },
];
var _tw = row_w div 3;
for (var _k = 0; _k < 6; _k++) {
	var _tx = row_x + (_k mod 3) * _tw;
	var _ty = tot_y + 6 + (_k div 3) * 11;
	var _zero = (string_copy(_tot[_k].v, 2, 99) == "0%");
	draw_set_halign(fa_left);
	draw_set_color(_dim);
	draw_set_alpha(.6);
	draw_text(_tx + 4, _ty, _tot[_k].l);
	draw_set_halign(fa_right);
	draw_set_color(_zero ? _dim : merge_colour(_tot[_k].c, c_white, .3));
	draw_set_alpha(_zero ? .4 : .9);
	draw_text(_tx + _tw - 8, _ty, _tot[_k].v);
}
draw_set_halign(fa_left);

// ==================== THE INSPECTOR ====================
// The right column, top to bottom. The TOP says what the thing is, in
// words; the BOTTOM is a ledger of three banded lines about the bonus
// - darkest last, where the total lives. One is read once, the other
// every time.
draw_set_alpha(1);
var _dc = merge_colour(c_hsv(168, 160, 5), c_black, .3);
__rr(desc_x, desc_y, desc_w, desc_h, _dc, 1);

// && short-circuits, so an out-of-range pick never indexes the array -
// which it can be for a frame after the slot count changes
var _has_pick = (pick >= 0 && pick < _n && is_struct(g.upg.slot[pick]));
var _px = desc_x + 8;
var _pr = desc_x + desc_w - 8;

if (!_has_pick) {
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
	var _ps   = g.upg.slot[pick];
	var _pe   = upgrade_entry(_ps.id);
	var _pc   = __rar_col(_ps.rar);
	var _pcap = upgrade_cap(pick);

	// the picked capsule's colour, washed up the inspector's left edge
	// the way it washes across its row
	__rr_grad(desc_x, desc_y, desc_w, desc_h, merge_colour(_pc, c_black, .78), _dc, 1);

	// ---- the top: what it IS ----
	draw_set_color(c_white);
	draw_set_alpha(.95);
	draw_text(_px + 2, desc_y + 7, (_pe == -1) ? _ps.id : _pe.name);
	draw_set_color(_pc);
	draw_set_alpha(.9);
	draw_text(_px + 2, desc_y + 18, __rar_name(_ps.rar));
	draw_set_halign(fa_right);
	draw_set_color(_dim);
	draw_set_alpha(.8);
	draw_text(_pr, desc_y + 18, (_ps.tier > 0)
		? ("tier " + string(_ps.tier) + " / " + string(_pcap))
		: ("offer  " + string(_pcap) + ((_pcap == 1) ? " tier" : " tiers")));
	draw_set_halign(fa_left);
	// a rule in the rarity's colour under the head
	draw_sprite_ext(spr_pixel_1x1, 0, _px + 2, desc_y + 30, desc_w - 18, 1, 0, _pc, .35);
	// the words
	draw_set_color(_ink);
	draw_set_alpha(.75);
	draw_text_ext(_px + 2, desc_y + 37,
		(_pe == -1) ? "no longer in the roster" : _pe.help, 9, desc_w - 18);

	// ---- the bottom: the ledger ----
	// what the NEXT tier buys, what THIS slot gives, what you HOLD
	// across everything. Reading down is reading outward.
	var _rows_txt = [];
	if (_pe != -1 && _pe.stat != "") {
		var _sfx  = (_ps.id == "crit_multi") ? "x" : "%";
		var _mine = upgrade_tier_value(_ps.val, _ps.tier, _pcap);
		var _nxt  = __next_str(pick);
		array_push(_rows_txt,
			{ k : (_ps.tier + 1 >= _pcap) ? "final tier" : "next tier",
			  v : (_nxt == "") ? "complete" : _nxt, c : c_sgreen });
		array_push(_rows_txt,
			{ k : "this slot",
			  v : (_ps.tier > 0)
			      ? ("+" + string_format(_mine, 1, 2) + _sfx)
			      : ("+0" + _sfx + " until bought"),
			  c : (_ps.tier > 0) ? c_white : _dim });
		array_push(_rows_txt,
			{ k : "total",
			  v : "+" + string_format(_ub[$ _pe.stat], 1, 2) + _sfx,
			  c : merge_colour(_pe.col, c_white, .3) });
	} else {
		array_push(_rows_txt,
			{ k : "a one-off", v : "spent when bought", c : _dim });
		array_push(_rows_txt,
			{ k : "gives", v : (_pe == -1) ? "-" : _pe.help, c : c_white });
		array_push(_rows_txt,
			{ k : "slots", v : string(upgrade_slots()) + " / "
			  + string(UPG_SLOT_MAX), c : c_white });
	}
	// the mode's verb over the ledger, so what the button does is
	// written where you read about the thing
	var _lh = 12;
	var _ly = desc_y + desc_h - 5 - array_length(_rows_txt) * _lh;
	draw_set_color(_dim);
	draw_set_alpha(.5);
	draw_text(_px + 2, _ly - 11, (mode == 0)
		? ((upgrade_cost(pick) < 0) ? "at its last tier" : "hold the price to buy")
		: "hold the price to sell");
	for (var _q = 0; _q < array_length(_rows_txt); _q++) {
		var _ln = _rows_txt[_q];
		// light to dark down the stack, so the eye lands on the total
		draw_sprite_ext(spr_pixel_1x1, 0, desc_x + 4, _ly, desc_w - 8, _lh - 1,
			0, c_black, .14 + .16 * _q);
		draw_set_halign(fa_left);
		draw_set_color(_dim);
		draw_set_alpha(.65);
		draw_text(_px + 2, _ly + 3, _ln.k);
		draw_set_halign(fa_right);
		draw_set_color(_ln.c);
		draw_set_alpha(.95);
		draw_text(_pr - 2, _ly + 3, _ln.v);
		_ly += _lh;
	}
	draw_set_halign(fa_left);
}

draw_set_alpha(1);
draw_set_color(c_white);
