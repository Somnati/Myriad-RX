/// DE's obj_click_multi Step, rebuilt on its own laws:
///   charge   overcharge_tap adds xp per tap (tap_fire) and refills hp
///   level    xp past the level's need -> lv + 1 (to OC_MAX_LV), the
///            figure pops, the disc kicks, the colour glides
///   drain    hp runs down every frame; below 40% of OC_HOLD the xp
///            drains at a level per OC_DRAIN_SEC seconds, dropping a
///            level each time it empties, until x1 - where it fades
///            and resets
///   gate     overcharge_live(): off = x1, always

var _live = overcharge_live();
var _lv   = g.overcharge_lv;
var _xp   = g.overcharge_xp;
var _need = overcharge_need(_lv);
var _max  = overcharge_maxlv();

hp = max(0, hp - delta);

if (!_live) { _lv = 1; _xp = 0; }
if (_lv >= _max) _xp = 0;   // full: nothing to fill toward
_xp = clamp(_xp, 0, _need);

// ---- the drain (DE: past 40% of the hold, xp leaves at a level per
// four seconds; at x2 empty it fades, then resets) ----
if (_lv > 1 && _live) {
	if (hp >= OC_HOLD * .4) alpha = trickle(alpha, 1, 5);
	else {
		_xp -= _need / (OC_DRAIN_SEC * 60) * delta;
		if (_xp <= 0) {
			if (_lv > 2) {
				_lv -= 1;
				_xp = overcharge_need(_lv) - 1;
			} else {
				alpha = trickle(alpha, 0, 8);
				if (alpha <= 0) { _lv = 1; _xp = 0; }
			}
		}
	}
}
if (_lv <= 1) alpha = 0;

// ---- the level-up ----
if (_live && _lv < _max && _xp >= _need) {
	_xp -= _need;
	_lv += 1;
	tsize  = 2;
	talpha = 0;
	rdv   += 2;     // DE's push_wiggle(2)
	// DE's ceremony: snd_vibrate under the taps, a burst of blue
	// particles across the figure (create_particle_burst 25, blue) -
	// the house sparks stand in for its particle system
	if (in_room(rm_clicker)) {
		play_sound_ext(snd_vibrate, .9, 1.1, .2, 0);
		draw_set_font(fnt_outline);
		var _bw = string_width("X" + string(overcharge_multi()));
		spark_burst(x + _bw * .5, y, 18, c_blue);
	}
}

// ---- the colour glides between levels - the moment they change ----
if (_lv != prev_lv) {
	col_from = col;
	col_to   = __col_of(_lv);
	col_t    = 0;
	prev_lv  = _lv;
	// the tap's worth changed: re-derive it (DE's syst_production.update)
	g.overcharge_lv = _lv;
	update_click();
}
col_t = min(1, col_t + .12 * delta);
col = merge_colour(col_from, col_to, col_t);

tsize  = trickle(tsize,  1, 7);
talpha = trickle(talpha, 1, 7);
flash  = max(0, flash - .05 * delta);

// ---- the charge, eased, and the disc's spring toward it ----
var _tgt = (_xp <= 0 || _lv >= _max) ? ((_lv >= _max) ? 1 : 0) : (_xp / _need);
fperc = (_xp <= 0 && _lv < _max) ? 0 : trickle(fperc, _tgt, 5);
fperc = clamp(fperc, 0, 1) * alpha;
rdv += (OC_DISC_R * fperc - rd) * .05 * delta;
rdv *= power(.96, delta);
rd  += rdv * delta;

g.overcharge_lv = _lv;
g.overcharge_xp = _xp;

__seat();
visible = in_room(rm_clicker) && alpha > 0;
