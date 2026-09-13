/// obj_scale_de - Myriad DE's obj_scale_profit, AS IT WAS (his ask,
/// 2026-09-13: "build 2 so i can see mine exactly as it is in game from
/// DE and your version of it"). Every variable, rule and pixel here is
/// DE's, in DE's names; only the data sources were renamed for RX:
///   DE's income (cycle income, or the gold pile by its networth
///     setting)                      -> the PROFIT PILE (RX's rebirth is
///                                      classic: profit held)
///   g.flagxp (the run before)      -> g.rebirth.prev_profit
///   g.highest_rebmil               -> g.rebirth.hi_ms
///   g.uf_rebirthmilestone          -> unfold_has("scale")
///   modules / main options open    -> an overlay up / the menu out
///   the rebirth ROOM               -> the rebirth OVERLAY (its strip
///                                      draws over it the same)
/// The 144 x 5 bar (spr_scale_bar) is the instance sprite, so DE's
/// sprite_width / swdiv arithmetic reads exactly as it did. Its twin,
/// obj_scale_rx, is the rebuilt one - the comparison is the point.
sprite_index = spr_scale_bar;
image_speed  = 0;
image_index  = 0;

income_track_scale_max = 120;
income_track_scale_min = 120;
scale_max_os = 5;
scale_max = scale_max_os;
scale_min = 0;
scale_min_os = 1;
segments = 0;
segment_scale = 1;
x = room_width / 2;
x -= swdiv;
x_ = 0;
income = 0;
income_track = (variable_global_exists("profit") && g.profit >= arb(1)) ? g.profit : 0;
scale_max_os_des = 5;
scale_min_os_des = 1;
lv = 0;
prevxp = -1;
maxxp = -1;
cprev = c_white;
cnext = c_white;
tic = 0;
tic_ = tsec * 5;
open = false;
alpha = 0;
perc = 0;
deci = 0;
desy = room_height + 20;
y = room_height + 20;   // DE's room placed it below the floor; it rises in
// DE's 80 sat under its tap surface. RX's tap room runs FX LAYERS over the
// visualizer (glow 20 / subtle_blur 30 / vignette 40) and an fx layer
// warps everything deeper than itself - his report: "visually skewed by
// the effects" - so the ruler sits at 10, over all three and still under
// the tap handler (0) and the dial column (-20)
depth = 10;

// DE's milestone law: bb + ii x lv - 1e16, 1e26, 1e36... (rebirth_calc's)
bb = 16;
ii = 10;

// the unlock, as this instance saw it (DE flipped uf_rebirthmilestone
// itself; RX's unfold row grants "scale", and this watches for the flip)
seen = unfold_has("scale");

// a save from before this key: the milestones already passed are not news
if (variable_global_exists("rebirth")) {
	rebirth_init();
	var _lv0 = ceil(clamp_min((income_track - bb) / ii, 0));
	if (g.rebirth.hi_ms < _lv0) g.rebirth.hi_ms = _lv0;
}

/// update_scale_milestone(), DE's: the fill's two colours by the milestone
/// index, through the dial letter colours (get_letter_color)
__colors = function() {
	cnext = c_white; cprev = c_white;
	if (lv <= 12) {
		if (lv - 1 >= 0) cprev = dial_color(lv - 1); else cprev = c_white;
		cnext = dial_color(lv);
	}
	if (lv >= 14) {
		cprev = dial_color(13);
		cnext = c_gold;
	}
	if (lv >= 15) {
		cprev = c_gold;
		cnext = c_gold;
	}
};
