// ---- where it wants to be ----
// out only while there is a pool to collect and nothing covers the
// room. DE's list of things that push it back off screen, in RX's
// names: an overlay, the rebirth screen, the menu, the dial drawer.
visible = unfold_has("battery");   // (the unfold: invisible = no draw, and syst_input never hands it a press)
if (!visible) exit;
var _has = (g.offline_pool >= arb(1));
desx = x1;
if (_has)
if (ui_overlay() == noone)
if (!(instance_exists(syst_rebirth) && syst_rebirth.open))
if (!(instance_exists(obj_ui_menu2) && obj_ui_menu2.open))
if (!(instance_exists(syst_dials) && syst_dials.stage > 0))
	desx = x2;
x = trickle(x, desx, 2.75);

pt += 3 * delta;
flash = max(0, flash - delta);

// ---- the collect ----
// THE ABILITY that auto-collects (DE's ad_offlinecollect) fires it
// without a press. Otherwise: a press ON the button (it is a family
// member, so g.click_owner says so) while it is out.
var _auto = variable_global_exists("ad_offlinecollect") && g.ad_offlinecollect == 1;
var _tap  = (x >= x2 - 1) && input_free()
	&& g.click_owner == id && mouse_check_button_pressed(mb_left);
if (_has && (_tap || _auto)) {
	var _add = g.offline_pool;
	g.offline_pool = 0;
	give_profit(_add);
	save_mark_dirty();

	if (!_auto) {
		// DE's ceremony: motes from the button into the counter,
		// CARRYING the amount so the header climbs as they land (its
		// emit_gold), scaled with what was earned - a 1-profit pool is
		// one mote, an overnight is a fistful
		var _n = 7;
		if (_add < arb(15)) _n = clamp(round(power(10, arb_log10(_add))), 1, 15);
		else _n = round(lerp(7, 20, clamp(arb_log10(_add) / 12, 0, 1)));
		bezier_bits(x + 7, y + 8, _n, g.profit_color, undefined, undefined, -1, _add);
		play_sound_ext(snd_cointoss, .9, 1.1, .5, 2);
		vibrate(40, 2);
		flash = 20;
		assign_banner("got +" + crunch_arb(_add), g.profit_color, g.profit_color);
		if (instance_exists(syst_banner)) syst_banner.hp[0] *= 3;
	} else {
		// no motes carry it, so the counter must not hold it back
		// (offline_replay's own rule for a bulk gain)
		g.profit_flight = (g.profit_flight > _add)
			? do_subtract(g.profit_flight, _add) : 0;
	}
}
