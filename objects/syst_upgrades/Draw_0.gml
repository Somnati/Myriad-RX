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
	var _tabc = _on ? merge_colour(_mcol[_m], c_black, .55) : c_black;
	draw_sprite_ext(spr_pixel_1x1, 0, _r.x, _r.y, _r.w, _r.h, 0, _tabc, _on ? .95 : .5);
	// THE ACTIVE TAB IS RAISED, the other is a flat outline. Tabs are the
	// one place where "which of these am I standing on" has to be
	// answerable at a glance, and a bevel says it before the colour does
	// - which matters because the two colours here (green and lavender)
	// are close in value even though they are far apart in hue.
	if (_on) {
		draw_sprite_ext(spr_pixel_1x1, 0, _r.x, _r.y, _r.w, 1, 0,
			merge_colour(_mcol[_m], c_white, .45), .95);
		draw_sprite_ext(spr_pixel_1x1, 0, _r.x, _r.y, 1, _r.h, 0,
			merge_colour(_mcol[_m], c_white, .45), .95);
		draw_sprite_ext(spr_pixel_1x1, 0, _r.x, _r.y + _r.h - 1, _r.w, 1, 0,
			merge_colour(_mcol[_m], c_black, .6), .95);
		draw_sprite_ext(spr_pixel_1x1, 0, _r.x + _r.w - 1, _r.y, 1, _r.h, 0,
			merge_colour(_mcol[_m], c_black, .6), .95);
	} else {
		draw_px_rect(_r.x, _r.y, _r.w, _r.h, _mcol[_m], _hov ? .55 : .3);
	}
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
	// THE RARITY WASH, bleeding in from the colour band. It fades to the
	// panel colour rather than to transparent, because the panel is
	// opaque and a colour fade needs no second alpha to read cleanly.
	if (_has) {
		var _gr = __rar_grad(_s.rar, row_w, _c);
		draw_sprite_general(spr_pixel_1x1, 0, 0, 0, 1, 1,
			row_x, _ry, _gr.w, row_h, 0, _gr.col, _c, _c, _gr.col, 1);
	}

	// ⚖️ THE BEVEL (his ask: bevel the slot sides). Four 1px edges, lit
	// from the top-left, which is the same light every raised thing in
	// this game is lit from - the statistics rows, the menu buttons, the
	// rebirth banner. It costs four strips and it is the difference
	// between a slot that looks like a PLATE you could pick up and a
	// slot that looks like a coloured stripe on a background.
	//
	// The top and left catch, the bottom and right fall away. Solid, not
	// gradient: the old seams were horizontal gradients fading to black
	// at the ends, which read as a smudge on a 16px row rather than as
	// an edge. An edge is a hard line or it is nothing.
	//
	// ⚖️ AND IT INVERTS WHEN THE SLOT IS EMPTY. A filled slot is a PLATE
	// sitting on the table; an empty one is the HOLE the plate goes in.
	// Same four strips, light swapped to the bottom-right, and the
	// difference is instantly legible across a whole column without
	// reading a word of it - which is what the dim "empty slot" text was
	// failing to do on its own. It is also the honest shape: a socket
	// with nothing in it should not look pressable.
	var _lit = merge_colour(_c, c_white, .22);
	var _shd = merge_colour(_c, c_black, .55);
	if (!_has) {
		var _sw = _lit; _lit = _shd; _shd = _sw;
		// and the well itself sits a shade darker than the table, the
		// way a recess catches less light
		draw_sprite_ext(spr_pixel_1x1, 0, row_x + 1, _ry + 1, row_w - 2,
			row_h - 2, 0, c_black, .22);
	}
	draw_sprite_ext(spr_pixel_1x1, 0, row_x, _ry, row_w, 1, 0, _lit, .9);
	draw_sprite_ext(spr_pixel_1x1, 0, row_x, _ry, 1, row_h, 0, _lit, .9);
	draw_sprite_ext(spr_pixel_1x1, 0, row_x, _ry + row_h - 1, row_w, 1, 0, _shd, .9);
	draw_sprite_ext(spr_pixel_1x1, 0, row_x + row_w - 1, _ry, 1, row_h, 0, _shd, .9);
	// the corners the two pairs share: without these, a lit edge runs
	// into a dark one and the join reads as a nick in the plate
	draw_sprite_ext(spr_pixel_1x1, 0, row_x, _ry + row_h - 1, 1, 1, 0, _c, 1);
	draw_sprite_ext(spr_pixel_1x1, 0, row_x + row_w - 1, _ry, 1, 1, 0, _c, 1);

	// the identity band, INSIDE the bevel now (it used to paint over the
	// left edge, which is exactly the pixel the bevel needs)
	draw_sprite_ext(spr_pixel_1x1, 0, row_x + 1, _ry + 1, 2, row_h - 2, 0,
		_col, _has ? .9 : .3);

	if (sel == _i)
		draw_sprite_ext(spr_pixel_1x1, 0, row_x + 1, _ry + 1, row_w - 2,
			row_h - 2, 0, c_white, .04);
	// the PICKED row keeps a brighter wash and a lit band, so the panel
	// below always has a visible owner
	if (pick == _i) {
		draw_sprite_ext(spr_pixel_1x1, 0, row_x + 1, _ry + 1, row_w - 2,
			row_h - 2, 0, c_white, .07);
		draw_sprite_ext(spr_pixel_1x1, 0, row_x + 1, _ry + 1, 2, row_h - 2, 0,
			c_white, .85);
		// ...and the bevel's top edge lights in its rarity colour, so
		// the selected plate reads as raised FURTHER rather than just
		// as washed brighter
		draw_sprite_ext(spr_pixel_1x1, 0, row_x, _ry, row_w, 1, 0,
			merge_colour(_col, c_white, .35), .8);
	}

	var _b = __btn(_i);

	if (!_has) {
		// no button: rolling is ONE control under the table now. The
		// text sits dimmer than it did, because the recess is now
		// carrying the message and two things saying "empty" is one
		// too many.
		draw_set_color(_dim);
		draw_set_alpha(.38);
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
	draw_text(_cx_eff, _ry + 4, (_e == -1) ? "retired" : __eff_str(_i));

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
		// inside the bevel: a fill that paints over the plate's own edge
		// makes the plate look like it is dissolving rather than filling
		draw_sprite_ext(spr_pixel_1x1, 0, row_x + 1, _ry + 1,
			(row_w - 2) * _hf, row_h - 2, 0, _hc, .6);
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
// TWO HALVES (his layout): the TOP says what the thing is, in words,
// and the BOTTOM is a little ledger of banded rows about the bonus -
// darkest at the bottom, where the total lives. The two jobs wanted
// separating: one is read once, the other is read every time.
draw_set_alpha(1);
var _dc = merge_colour(c_hsv(168, 160, 5), c_black, .35);
draw_sprite_ext(spr_pixel_1x1, 0, desc_x, desc_y, desc_w, desc_h, 0, _dc, 1);
// the same bevel the slots wear, from the same light. A panel that sits
// beside eight bevelled plates and has none of its own reads as a hole
// in the layout rather than as a surface.
var _dl = merge_colour(_dc, c_white, .20);
var _ds = merge_colour(_dc, c_black, .55);
draw_sprite_ext(spr_pixel_1x1, 0, desc_x, desc_y, desc_w, 1, 0, _dl, .9);
draw_sprite_ext(spr_pixel_1x1, 0, desc_x, desc_y, 1, desc_h, 0, _dl, .9);
draw_sprite_ext(spr_pixel_1x1, 0, desc_x, desc_y + desc_h - 1, desc_w, 1, 0, _ds, .9);
draw_sprite_ext(spr_pixel_1x1, 0, desc_x + desc_w - 1, desc_y, 1, desc_h, 0, _ds, .9);
draw_sprite_ext(spr_pixel_1x1, 0, desc_x, desc_y + desc_h - 1, 1, 1, 0, _dc, 1);
draw_sprite_ext(spr_pixel_1x1, 0, desc_x + desc_w - 1, desc_y, 1, 1, 0, _dc, 1);

// && short-circuits, so an out-of-range pick never indexes the array -
// which it can be for a frame after the slot count changes
var _has_pick = (pick >= 0 && pick < _n && is_struct(g.upg.slot[pick]));

// the same rarity wash the rows wear, so the panel is visibly ABOUT the
// row you tapped rather than a separate thing that happens to agree
if (_has_pick) {
	var _dg = __rar_grad(g.upg.slot[pick].rar, desc_w, _dc);
	draw_sprite_general(spr_pixel_1x1, 0, 0, 0, 1, 1,
		desc_x, desc_y, _dg.w, desc_h, 0, _dg.col, _dc, _dc, _dg.col, 1);
}
draw_sprite_general(spr_pixel_1x1, 0, 0, 0, 1, 1, desc_x, desc_y, desc_w, 1, 0,
	c_white, c_white, c_black, c_black, .18);
draw_px_rect(desc_x, desc_y, desc_w, desc_h, sett_ink, .18);

var _px = desc_x + 7;
var _pr = desc_x + desc_w - 7;

if (!_has_pick) {
	draw_set_color(_dim);
	draw_set_alpha(.45);
	draw_text(_px, desc_y + 8, "tap a slot to read it");
	draw_text(_px, desc_y + 19, "what it changes, what it gives you,");
	draw_text(_px, desc_y + 28, "and what you hold of it in total");
} else {
	var _ps = g.upg.slot[pick];
	var _pe = upgrade_entry(_ps.id);
	var _pc = __rar_col(_ps.rar);
	var _pcap = upgrade_cap(pick);

	// ---- the top half: what it IS ----
	draw_set_halign(fa_left);
	draw_set_color(c_white);
	draw_set_alpha(.95);
	draw_text(_px, desc_y + 4, (_pe == -1) ? _ps.id : _pe.name);
	draw_set_halign(fa_right);
	draw_set_color(_pc);
	draw_set_alpha(.85);
	draw_text(_pr, desc_y + 4, __rar_name(_ps.rar) + "  "
		+ string(_ps.tier) + "/" + string(_pcap));
	draw_set_halign(fa_left);
	draw_set_color(sett_ink);
	draw_set_alpha(.7);
	draw_text(_px, desc_y + 14, (_pe == -1) ? "no longer in the roster" : _pe.help);

	// ---- the bottom half: the ledger ----
	// Three banded rows, each darker than the last, ending on the total.
	// The order is deliberate: what the NEXT tier buys, then what this
	// slot is giving, then what you hold across everything. Reading down
	// is reading outward.
	var _rows_txt = [];
	if (_pe != -1 && _pe.stat != "") {
		var _sfx  = (_ps.id == "crit_multi") ? "x" : "%";
		var _mine = upgrade_tier_value(_ps.val, _ps.tier, _pcap);
		var _nxt  = __next_str(pick);
		array_push(_rows_txt,
			{ k : (_ps.tier + 1 >= _pcap) ? "final tier" : "next tier",
			  v : (_nxt == "") ? "complete" : _nxt, c : c_sgreen });
		array_push(_rows_txt,
			{ k : "this upgrade",
			  v : (_ps.tier > 0)
			      ? ("+" + string_format(_mine, 1, 2) + _sfx)
			      : ("+0" + _sfx + " until bought"),
			  c : (_ps.tier > 0) ? c_white : _dim });
		array_push(_rows_txt,
			{ k : "total " + _pe.name,
			  v : "+" + string_format(_ub[$ _pe.stat], 1, 2) + _sfx,
			  c : _pe.col });
	} else {
		array_push(_rows_txt,
			{ k : "a one-off", v : "spent when bought", c : _dim });
		array_push(_rows_txt,
			{ k : "gives", v : (_pe == -1) ? "-" : _pe.help, c : c_white });
		array_push(_rows_txt,
			{ k : "slots", v : string(upgrade_slots()) + " / "
			  + string(UPG_SLOT_MAX), c : c_white });
	}

	var _lh = 11;
	var _ly = desc_y + desc_h - 4 - array_length(_rows_txt) * _lh;
	for (var _q = 0; _q < array_length(_rows_txt); _q++) {
		var _rr = _rows_txt[_q];
		// light to dark down the stack, so the eye lands on the total
		draw_sprite_ext(spr_pixel_1x1, 0, desc_x + 1, _ly, desc_w - 2, _lh - 1,
			0, c_black, .12 + .16 * _q);
		draw_set_halign(fa_left);
		draw_set_color(_dim);
		draw_set_alpha(.6);
		draw_text(_px, _ly + 2, _rr.k);
		draw_set_halign(fa_right);
		draw_set_color(_rr.c);
		draw_set_alpha(.95);
		draw_text(_pr, _ly + 2, _rr.v);
		_ly += _lh;
	}
	draw_set_halign(fa_left);
}

draw_set_alpha(1);
draw_set_color(c_white);
