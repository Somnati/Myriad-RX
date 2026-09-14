/// obj_scale_rx - THE MILESTONE SCALE, rebuilt (his ask 2026-09-13,
/// after "if you were to improve it how would you?": "build 2 so i can
/// see mine exactly as it is in game from DE and your version of it").
/// DE's obj_scale_profit is obj_scale_de beside it; this keeps what DE
/// got right and changes what it TELLS you:
///
/// KEPT (DE's, verbatim): the bar is a sliding window of ORDERS OF
/// MAGNITUDE around the profit pile; every order is a tick and the
/// ticks fade off both ends; the window TIGHTENS as a milestone nears,
/// so the milestone tick slides in from the right edge and the fill
/// creeps up to it (the whole feel); the fill's colour walks the dial
/// letter colours from the last milestone to the next; the pennant of
/// the run before; the rise from under the floor.
///
/// CHANGED:
///   WHEN, not just where - the pile's rate in orders per second is
///     measured over the last minute and the milestone tick wears an
///     eta ("~14m"). Two orders away is ten seconds early in a run and
///     two hours late in one; the eta is the number the scale is for.
///   TWO PENNANTS - the run before (bright) and the BEST run ever (dim,
///     g.rebirth.best_profit): every run is "beat last time" and "beat
///     the record" at once.
///   THE REBIRTH READOUT - "rebirth +N" under the bar's left end, live
///     off rebirth_calc (the units a rebirth pays right now), so the
///     ruler is the reason to push on or cash out, not decoration.
///   GLYPHS ON THE GRID - labels at 1x (DE scaled .6 -> 1.1 through a
///     sprite font, which shimmers); only the y-arc carries the sweep.
///     The milestone's label is fnt_outline in its colour and its tick
///     breathes a glow; every order is labelled when there is room
///     (landscape), every third when there is not (DE's rule).
///   THE WIDTH - the room's, less the dial column: 12 orders in the
///     window (3 behind, 9 ahead) instead of DE's 6, so a run's whole
///     next stretch is in view.
///   THE REVEAL - the objective chain teaches it (a batch after
///     rebirth: hold 1e8, then reach 1e16); the unfold row is the
///     safety net. On the grant the window opens forty orders wide
///     and zooms in (DE's three-hundred-order opening, shortened).
///
/// Depth 10: over the tap surface (50) AND the visualizer's fx layers
/// (glow 20 / subtle_blur 30 / vignette 40 - an fx layer warps everything
/// deeper than itself; his report: "visually skewed by the effects"),
/// under the tap handler (0) and the dial column (-20); over the rebirth
/// overlay while that is open (DE's placement).
depth = 10;

bb = 16;    // the milestone law (rebirth_calc's): 1e16, then every 10 orders
ii = 10;
ms_seen = 0;   // the rungs this instance has chimed for

// geometry: the bar spans the room, clear of the docked dial column
var _dock = instance_exists(syst_dials) ? syst_dials.dock_w : 12;
x0 = 12;
W  = max(96, room_width - x0 - _dock - 10);
by = room_height + 20;   // the bar's top edge, live (rises in)
seat = room_height - 15; // where it sits (DE's seat; above DE's while both are up)
BH = sprite_get_height(spr_scale_bar);
SW = sprite_get_width(spr_scale_bar);

track  = rebirth_fed();
income = 0;     // the true log10 of the pile, continuous (floor + digits)
lv = 0; prevxp = 0; maxxp = bb;
cprev = c_white; cnext = c_white;
mn = 3; mx = 9;             // the window's eased offsets (behind / ahead)
lo = 0; hi = 12; perc = 0; ppo = W / 12;
open = false;
tic = 0;                    // DE's five-second guard between milestone chimes
cel = 0;                    // the crossing celebration, 1 -> 0 over two seconds
t = 0;                      // the glow's breath

// the rate: one sample of `income` a second, a minute deep
hist = []; hist_t = 0; rate = 0; eta = -1;

// the rebirth readout, refreshed on the second
units_txt = ""; units_tic = 0;

// the reveal: this instance watches the unfold flip
seen = unfold_has("scale");

if (variable_global_exists("rebirth")) {
	rebirth_init();
	var _lv0 = ceil(clamp_min((track - bb) / ii, 0));
	if (g.rebirth.hi_ms < _lv0) g.rebirth.hi_ms = _lv0;   // a pre-key save: not news
	ms_seen = _lv0;   // the rungs already passed are not news to this instance either
}

/// the fill's two colours by the milestone index (DE's law, through the
/// dial letter colours; the thirteenth is the wrap DE skipped)
__colors = function() {
	cprev = (lv - 1 >= 0) ? dial_color(lv - 1) : c_white;
	cnext = dial_color(lv);
	if (lv >= 14) { cprev = dial_color(13); cnext = c_gold; }
	if (lv >= 15) { cprev = c_gold; cnext = c_gold; }
};

/// @func __px(lg)
/// @desc a magnitude's x along the bar (unclamped)
__px = function(_lg) {
	return W * (_lg - lo) / max(.0001, hi - lo);
};

/// @func __edge(px, mm)
/// @desc DE's end fade: full a quarter in from either end (mm 2), sooner for the milestone (4)
__edge = function(_px, _mm) {
	var _h = W * .5;
	return clamp(((_px > _h) ? (W - _px) : _px) / _h * _mm, 0, 1);
};

/// @func __pennant(lg, a, dim)
__pennant = function(_lg, _a, _dim) {
	if (!(_lg > 0)) return;
	var _px = __px(_lg);
	if (_px <= 0 || _px >= W) return;
	var _al = __edge(_px, 2) * _a * (_dim ? .45 : 1);
	draw_sprite_ext(spr_rebirthflag, (income >= _lg) ? 1 : 0, x0 + floor(_px), by + 4, 1, 1, 0, c_white, _al);
};
