/// the slot list. statistics_v2's row language - opaque panel, gradient
/// edge seams, a colour band at the left - so this reads as part of the
/// same game rather than a fourth invented style.
///
/// ONE LINE A ROW, in fixed columns: name, effect, tier, rarity, and
/// the one button the mode decides. Fixed columns rather than text
/// flowing after text, because a list you SCAN wants its numbers under
/// each other - eight rows whose tier column moves with the length of
/// the name is eight rows you have to read individually.

draw_set_font(fnt);
draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

var _dim = rgb(120, 130, 150);
var _n   = upgrade_slots();
var _ub  = upgrade_bonus();   // the TRUTH, not the gated reader - this
                              // screen shows what the slots would do
                              // even while UPG_LIVE keeps them idle

// ---- the title strip ----
draw_sprite_ext(spr_pixel_1x1, 0, 0, bby, room_width, list_y - bby, 0,
	c_hsv(169, 186, 5), 1);
draw_sprite_ext(spr_pixel_1x1, 0, 0, list_y - 1, room_width, 1, 0, sett_ink, .25);
draw_set_color(rgb(195, 205, 235));
draw_set_alpha(.85);
draw_text(6, bby + 5, "upgrades");

// the mode pills. menu2's colour language: the live one is a solid
// fill, the other sinks toward black.
var _mname = ["buy", "sell"];
var _mcol  = [c_sgreen, c_lavender];
for (var _m = 0; _m < 2; _m++) {
	var _r = __mode_rect(_m);
	var _on = (mode == _m);
	var _hov = point_in_rectangle(mouse_x, mouse_y, _r.x, _r.y, _r.x + _r.w, _r.y + _r.h);
	draw_set_alpha(1);
	draw_sprite_ext(spr_pixel_1x1, 0, _r.x, _r.y, _r.w, _r.h, 0,
		_on ? merge_colour(_mcol[_m], c_black, .55) : c_black, _on ? .95 : .5);
	draw_px_rect(_r.x, _r.y, _r.w, _r.h, _mcol[_m], _on ? .9 : (_hov ? .55 : .3));
	draw_set_halign(fa_center);
	draw_set_color(_on ? c_white : merge_colour(_mcol[_m], c_white, _hov ? .6 : .3));
	draw_set_alpha(_on ? .95 : .75);
	draw_text(_r.x + _r.w / 2 + 1, _r.y + 2, _mname[_m]);
}

// THE PURSE IS NOT DRAWN HERE ANY MORE (his call, DE's behaviour). The
// credit panel is a real object that already knows how to draw a
// balance, glide it, and flash on a drop; a second copy of the number
// painted into this screen's title strip is a second thing to keep in
// step and it cannot animate. The Step pins the panel instead - see the
// obj_display_credits block there.

var _bk = __back_rect();
draw_ui_back(_bk.x1, _bk.y1, _bk.x2 - _bk.x1, _bk.y2 - _bk.y1);

// ---- the slots ----
var _cx_eff = row_x + 132;   // the columns, shared by every row
var _cx_tir = row_x + 214;
var _cx_rar = row_x + 268;

for (var _i = 0; _i < _n; _i++) {
	var _ry  = __row_y(_i);
	var _s   = g.upg.slot[_i];
	var _has = is_struct(_s);
	var _col = _has ? __rar_col(_s.rar) : _dim;

	// the panel: statistics' recipe, opaque with gradient seams
	var _c = merge_colour(c_hsv(168, 160, 5), c_hsv(169, 186, 5), .2);
	draw_sprite_ext(spr_pixel_1x1, 0, row_x, _ry, row_w, row_h, 0, _c, 1);
	draw_sprite_general(spr_pixel_1x1, 0, 0, 0, 1, 1, row_x, _ry, row_w, 1, 0,
		_c, c_black, c_black, _c, .52);
	draw_sprite_general(spr_pixel_1x1, 0, 0, 0, 1, 1, row_x, _ry + row_h - 1,
		row_w, 1, 0, c_black, _c, _c, c_black, .52);
	draw_sprite_ext(spr_pixel_1x1, 0, row_x, _ry, 2, row_h, 0, _col, _has ? .9 : .3);
	if (sel == _i)
		draw_sprite_ext(spr_pixel_1x1, 0, row_x, _ry, row_w, row_h, 0, c_white, .04);
	// the PICKED row keeps a brighter wash and a lit band, so the panel
	// below always has a visible owner
	if (pick == _i) {
		draw_sprite_ext(spr_pixel_1x1, 0, row_x, _ry, row_w, row_h, 0, c_white, .07);
		draw_sprite_ext(spr_pixel_1x1, 0, row_x, _ry, 2, row_h, 0, c_white, .85);
	}

	var _b = __btn(_i);

	if (!_has) {
		// no button: rolling is ONE control under the table now
		draw_set_color(_dim);
		draw_set_alpha(.5);
		draw_text(row_x + 7, _ry + 4, "empty slot");
		continue;
	}

	var _e    = upgrade_entry(_s.id);
	var _cap  = upgrade_cap(_i);
	var _name = (_e == -1) ? _s.id : _e.name;

	draw_set_color((_s.tier > 0) ? c_white : _dim);
	draw_set_alpha(.95);
	draw_text(row_x + 7, _ry + 4, _name);

	draw_set_color(_col);
	draw_set_alpha(_s.tier > 0 ? .95 : .6);
	draw_text(_cx_eff, _ry + 4, (_e == -1) ? "retired" : __eff_str(_s));

	draw_set_color(_dim);
	draw_set_alpha(.8);
	draw_text(_cx_tir, _ry + 4,
		(_s.tier > 0) ? (string(_s.tier) + " / " + string(_cap)) : "offer");

	draw_set_color(_col);
	draw_set_alpha(.55);
	draw_text(_cx_rar, _ry + 4, __rar_name(_s.rar));

	// ---- the one button, whatever the mode says it is ----
	if (mode == 0) {
		var _cost   = upgrade_cost(_i);
		var _afford = (_cost > 0) && (g.credits >= arb(_cost));
		draw_ui_button(_b.x, _b.y, _b.w, _b.h,
			(_cost < 0) ? "maxed" : string(_cost),
			_afford ? c_sgreen : c_hred, _cost > 0, _afford);
	} else {
		// EVERY SLOT HAS A PRICE NOW, an untouched offer included - it
		// cost a stake to be here, so it is worth something to be rid
		// of. "discard" is gone with it.
		// every slot quotes a price, DE's way - see upgrade_sell_value
		draw_ui_button(_b.x, _b.y, _b.w, _b.h,
			string(upgrade_sell_value(_i)), c_lavender, true, true);
	}

	// ---- THE HOLD BAR (DE's) ----
	// A wash sweeping across the WHOLE ROW rather than across the
	// button, which is DE's shape and the right one: what is being
	// spent - or consumed - is the slot, so the row is the thing that
	// should be visibly filling up.
	//
	// GREEN AND LINEAR TO BUY, RED AND SQUARED TO SELL, exactly DE's
	// split (val = hp/100 against (hp/100)*(hp/100)). The squared one
	// crawls at the start, so a tap that was not meant to be a hold
	// barely moves it - the commitment is legible before it is
	// irreversible - while the linear one is a steady metronome you can
	// count tiers against as it repeats.
	if (hold_i == _i && hold_hp > 0) {
		var _hf = hold_hp / 100;
		if (mode == 1) _hf *= _hf;
		var _hc = merge_colour((mode == 0) ? c_sgreen : c_hred, c_black, .3);
		draw_sprite_ext(spr_pixel_1x1, 0, row_x, _ry, row_w * _hf, row_h, 0, _hc, .6);
	}

	__dots(_i, _ry);
}

// ---- THE ONE ROLL BUTTON ----
// Under the table, where a control that acts on the WHOLE table belongs.
// It says the stake and what it will do with it; when every slot is
// taken it says so instead of pretending to be pressable.
var _rr  = __roll_rect();
var _rc  = upgrade_roll_cost();
var _fs  = __free_slot();
var _ra  = (_fs != -1) && (_rc <= 0 || g.credits >= arb(_rc));
draw_ui_button(_rr.x, _rr.y, _rr.w, _rr.h,
	(_fs == -1) ? "no free slot"
	            : ((_rc > 0) ? ("roll a slot - " + string(_rc)) : "roll a slot"),
	(_fs == -1) ? c_gray : (_ra ? c_sblue : c_hred), (_fs != -1), _ra);

// ---- the status line: what just happened, on the screen it happened on
var _sy = __row_y(_n) + 21;
if (msg_hp > 0 && msg != "") {
	draw_set_color(msg_col);
	draw_set_alpha(.9 * min(1, msg_hp / 40));
	draw_text(row_x + 2, _sy, msg);
}

// ---- the footer: what all of it adds up to ----
// The screen is a list of individual purchases and the thing a player
// actually wants is the total. Two short lines in the left column now,
// because the right half belongs to the description panel.
draw_set_color(_dim);
draw_set_alpha(.6);
draw_text(row_x + 2, _sy + 11,
	"tap +" + string_format(_ub.tap_profit, 1, 0) + "%"
	+ "   dials +" + string_format(_ub.dial_profit, 1, 0) + "%"
	+ "   speed +" + string_format(_ub.dial_speed, 1, 0) + "%");
draw_text(row_x + 2, _sy + 20,
	"crit +" + string_format(_ub.crit_rate, 1, 0) + "%"
	+ "   cost -" + string_format(_ub.dial_cost, 1, 0) + "%"
	+ "   credits +" + string_format(_ub.credit_rate, 1, 0) + "%");

// ⚖️ AND SAY SO WHILE IT IS OFF. A screen that quotes bonuses the game
// is not applying, without saying so, is a screen that lies.
if (!UPG_LIVE) {
	draw_set_color(c_horange);
	draw_set_alpha(.75);
	draw_text(row_x + 2, _sy + 29,
		"preview - not affecting the game yet");
}

// ================= THE DESCRIPTION PANEL =================
draw_set_alpha(1);
draw_sprite_ext(spr_pixel_1x1, 0, desc_x, desc_y, desc_w, desc_h, 0,
	merge_colour(c_hsv(168, 160, 5), c_black, .35), 1);
draw_sprite_general(spr_pixel_1x1, 0, 0, 0, 1, 1, desc_x, desc_y, desc_w, 1, 0,
	c_white, c_white, c_black, c_black, .18);
draw_px_rect(desc_x, desc_y, desc_w, desc_h, sett_ink, .18);

var _px = desc_x + 7;
var _pr = desc_x + desc_w - 7;

// && short-circuits, so an out-of-range pick never indexes the array -
// which it can be for a frame after the slot count changes
var _has_pick = (pick >= 0 && pick < _n && is_struct(g.upg.slot[pick]));
if (!_has_pick) {
	draw_set_color(_dim);
	draw_set_alpha(.45);
	draw_text(_px, desc_y + 8, "tap a slot to read it");
	draw_text(_px, desc_y + 19, "the panel says what it changes,");
	draw_text(_px, desc_y + 28, "and what you already have of it");
} else {
	var _ps = g.upg.slot[pick];
	var _pe = upgrade_entry(_ps.id);
	var _pc = __rar_col(_ps.rar);

	// the name, and the rarity right-aligned against it
	draw_set_halign(fa_left);
	draw_set_color(c_white);
	draw_set_alpha(.95);
	draw_text(_px, desc_y + 5, (_pe == -1) ? _ps.id : _pe.name);
	draw_set_halign(fa_right);
	draw_set_color(_pc);
	draw_set_alpha(.85);
	draw_text(_pr, desc_y + 5, __rar_name(_ps.rar));
	draw_set_halign(fa_left);
	draw_sprite_ext(spr_pixel_1x1, 0, _px, desc_y + 15, desc_w - 14, 1, 0,
		sett_ink, .15);

	// WHAT IT MODIFIES - the roster's own sentence, which existed all
	// along and had nowhere to be shown once rows went to one line
	draw_set_color(sett_ink);
	draw_set_alpha(.7);
	draw_text(_px, desc_y + 19, (_pe == -1) ? "no longer in the roster" : _pe.help);

	if (_pe != -1 && _pe.stat != "") {
		// THE TOTAL YOU ALREADY HOLD for this stat, and this slot's
		// share of it. The total is the number that decides whether
		// another tier here is worth buying; the share is what you lose
		// if you sell. Neither means much without the other.
		var _tot = _ub[$ _pe.stat];
		var _mine = _ps.val * _ps.tier;
		var _sfx = (_ps.id == "crit_multi") ? "x" : "%";

		draw_set_color(_dim);
		draw_set_alpha(.6);
		draw_text(_px, desc_y + 33, "you have");
		draw_set_halign(fa_right);
		draw_set_color(_pe.col);
		draw_set_alpha(.95);
		draw_text(_pr, desc_y + 33, "+" + string_format(_tot, 1, 2) + _sfx);

		draw_set_halign(fa_left);
		draw_set_color(_dim);
		draw_set_alpha(.6);
		draw_text(_px, desc_y + 43, "this slot");
		draw_set_halign(fa_right);
		draw_set_color((_mine > 0) ? c_white : _dim);
		draw_set_alpha(.9);
		draw_text(_pr, desc_y + 43,
			(_ps.tier > 0) ? ("+" + string_format(_mine, 1, 2) + _sfx)
			               : "nothing yet");
		draw_set_halign(fa_left);
	} else {
		draw_set_color(c_white);
		draw_set_alpha(.8);
		draw_text(_px, desc_y + 35, "a one-off - it is spent when bought");
	}

	// the mechanical line: how deep it goes, what a tier is worth, and
	// what it would fetch
	draw_set_color(_dim);
	draw_set_alpha(.55);
	draw_text(_px, desc_y + 55, "tier " + string(_ps.tier) + " / "
		+ string(upgrade_cap(pick))
		+ "    +" + string_format(_ps.val, 1, 2) + " a tier");
	draw_text(_px, desc_y + 64,
		"sells for " + string(upgrade_sell_value(pick)) + " credits");
}

draw_set_alpha(1);
draw_set_color(c_white);
