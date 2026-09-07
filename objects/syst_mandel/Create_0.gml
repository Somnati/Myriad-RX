/// rm_mandel's driver. The shader does the fractal (sh_mandel's header
/// is where the technique lives); this owns the view, the input and the
/// iteration budget.
///
/// THE TWO THINGS THAT MAKE IT FEEL GOOD, both here rather than in the
/// shader:
///
/// 1. ZOOM TOWARD THE CURSOR. Zooming to the screen centre means
///    chasing anything interesting with a drag after every step, which
///    is most of why a fractal viewer feels bad. The fix is one line of
///    algebra: keep the complex point under the pointer fixed, so the
///    thing you are looking at stays exactly where you are looking.
///
/// 2. THE ZOOM IS EASED, NOT STEPPED. `scale` chases `scale_to`
///    geometrically, so a wheel notch is a glide rather than a jump and
///    holding the wheel down reads as a continuous dive.
///
/// THOSE TWO FIGHT EACH OTHER, and the first cut lost. It moved the
/// centre ONCE, instantly, to where it belongs at the FINAL scale - and
/// then glided the scale there over the next twenty frames, so the
/// point under the cursor was correct only after the animation
/// finished. It also measured the anchor against the live `scale` but
/// compensated with a ratio of `scale_to`, mixing two frames of
/// reference. Between them the view crawled away from wherever you
/// aimed, which is exactly what he reported.
///
/// THE FIX IS TO STOP COMPUTING A CORRECTION AT ALL. A wheel notch
/// records the complex point under the pointer and the screen pixel it
/// must stay at; every frame after, the centre is DERIVED from that
/// anchor at whatever the eased scale currently is. There is no
/// accumulating correction to drift, the anchor is exact on every
/// frame of the animation rather than only the last, and scrolling
/// repeatedly just re-anchors under the cursor each time.
///
/// AND THE HONEST LIMIT: float32 runs out around 1e-5 of span. Rather
/// than let the image melt into blocks and look broken, the zoom stops
/// there and the readout says why. That boundary is a property of the
/// number type, not of this code - going deeper means double-double
/// emulation or perturbation theory, which is its own project.

// ---- the view ----
cx = -0.75;          // a centre that frames the whole set
cy =  0.0;
scale    = 1.35;     // half-height of the view, in complex units
scale_to = 1.35;

// ---- the two precision floors ----
// float32 (24-bit mantissa) stops resolving neighbouring pixels at
// about 4e-6 of span. DOUBLE-DOUBLE carries the coordinate as a pair of
// floats, hi + lo, for ~48 bits and about 2e-13 - forty million times
// deeper. Written out longhand because GML's parser rejects scientific
// literals outright (1e-13 is a syntax error, not a small number).
SCALE_MIN_F32 = 0.000004;
SCALE_MIN_DD  = 0.0000000000002;
SCALE_MIN = SCALE_MIN_F32;   // live floor, swapped by __dd_on below
SCALE_MAX = 2.5;

// where the deep path switches on. Comfortably ABOVE the f32 floor, so
// the handover happens while single precision is still clean - crossing
// exactly at the point it breaks would show the seam.
DD_AT = 0.00002;

// double-double is roughly eight times the cost per iteration, so it is
// only paid once float32 has actually run out.
__dd_on = function() { return (scale_to < DD_AT) || (scale < DD_AT); };

// ---- input state ----
drag    = false;
drag_mx = 0;
drag_my = 0;
drag_cx = 0;
drag_cy = 0;
moved   = 0;         // pixels dragged, so a tap is not read as a pan

// ---- the zoom anchor ----
// while on, the centre is DERIVED each frame so that the complex point
// (anch_x, anch_y) stays under screen pixel (anch_px, anch_py). Any
// pan or jump clears it, because those set the centre themselves.
anch_on = false;
anch_x  = 0;
anch_y  = 0;
anch_px = 0;
anch_py = 0;

// ---- look ----
// the palette phase. Drifts very slowly on its own so a still image is
// never quite still, and [c] cycles it through some hand-picked sets
// rather than randomising - random palettes are mostly ugly.
pal_set = 0;
pal_list = [
	{ r : 0.00, g : 0.10, b : 0.20, name : "ember"   },
	{ r : 0.55, g : 0.60, b : 0.75, name : "ice"     },
	{ r : 0.30, g : 0.20, b : 0.20, name : "copper"  },
	{ r : 0.85, g : 0.90, b : 0.15, name : "orchid"  },
	{ r : 0.10, g : 0.55, b : 0.35, name : "lagoon"  },
];
pal_shift = 0;
glow      = 0.55;
show_hud  = true;

// ---- the iteration budget ----
// Detail costs iterations only as you zoom: at the default view a few
// dozen already resolve everything visible, and past that the useful
// budget grows with the LOG of the magnification. The +sqrt term is
// what keeps deep views from going flat and blobby - the boundary needs
// disproportionately more iterations exactly where it gets thinnest.
// Capped at the shader's own ceiling; going past it silently would just
// mean the picture stops improving while the cost keeps climbing.
__iter = function() {
	var _mag = SCALE_MAX / max(scale, SCALE_MIN_DD);
	return clamp(60 + 34 * log2(_mag) + 26 * sqrt(max(0, log2(_mag))), 60, 512);
};

// ---- splitting a double into a float pair ----
// ⚖️ THIS WORKS BECAUSE A GML `real` IS ALREADY A 64-BIT DOUBLE. The
// precision the shader lacks is sitting right here in the view
// variables; the only problem is getting it across, and a uniform is
// float32. So the number is handed over as two floats: `hi` is the
// value rounded to f32, `lo` is exactly what that rounding threw away.
// The shader adds them back together with error-free arithmetic.
//
// The round-trip through a 4-byte buffer IS the f32 rounding - GML has
// no float cast, and anything hand-rolled out of logs and powers would
// be approximate, which would defeat the entire point. One buffer for
// the whole run, made global so this object needs no CleanUp event to
// avoid leaking it per room entry.
if (!variable_global_exists("dd_buf")) g.dd_buf = buffer_create(4, buffer_fixed, 1);
__split = function(_v) {
	buffer_seek(g.dd_buf, buffer_seek_start, 0);
	buffer_write(g.dd_buf, buffer_f32, _v);
	buffer_seek(g.dd_buf, buffer_seek_start, 0);
	var _hi = buffer_read(g.dd_buf, buffer_f32);
	return [_hi, _v - _hi];   // hi + lo == _v, to the last bit
};

// the uniform handles, fetched ONCE - shader_get_uniform is a string
// lookup and doing it per frame per uniform is a real cost for no gain
u_centre = shader_get_uniform(sh_mandel, "u_centre");
u_scale  = shader_get_uniform(sh_mandel, "u_scale");
u_res    = shader_get_uniform(sh_mandel, "u_res");
u_iter   = shader_get_uniform(sh_mandel, "u_iter");
u_time   = shader_get_uniform(sh_mandel, "u_time");
u_pal    = shader_get_uniform(sh_mandel, "u_pal");
u_glow   = shader_get_uniform(sh_mandel, "u_glow");
u_cdd    = shader_get_uniform(sh_mandel, "u_centre_dd");
u_sdd    = shader_get_uniform(sh_mandel, "u_scale_dd");
u_dd     = shader_get_uniform(sh_mandel, "u_dd");

// AND CHECK THEM. shader_get_uniform returns -1 when a uniform is not
// found, and shader_set_uniform_f on -1 is a SILENT no-op - so a name
// that does not match, or one the shader compiler optimised away,
// shows up only as a picture that is subtly or completely wrong. This
// screen's failure mode for that is "one flat colour", which says
// nothing about the cause; a named line in the log says everything.
var _uni = [["u_centre", u_centre], ["u_scale", u_scale], ["u_res", u_res],
	["u_iter", u_iter], ["u_time", u_time], ["u_pal", u_pal],
	["u_glow", u_glow], ["u_centre_dd", u_cdd], ["u_scale_dd", u_sdd],
	["u_dd", u_dd]];
for (var _i = 0; _i < array_length(_uni); _i++)
	if (_uni[_i][1] < 0)
		show("sh_mandel > uniform NOT FOUND: " + _uni[_i][0]
			+ " (the shader will fall back and the view will be wrong)");

// screen pixel -> complex plane, at the CURRENT view. The one place
// that conversion is written; the zoom-toward-cursor maths below and
// any future click-to-do-something both go through it, so they cannot
// disagree about where the pointer is.
__at = function(_px, _py) {
	var _ar = room_width / room_height;
	return {
		x : cx + ((_px / room_width)  - 0.5) * 2 * scale * _ar,
		y : cy + ((_py / room_height) - 0.5) * 2 * scale,
	};
};

// a small set of places worth arriving at, for [space]. Hand-picked:
// the interesting parts of this set are not where you land by accident.
tour = [
	{ x : -0.75,               y :  0.0,                s : 1.35,     n : "the whole set" },
	{ x : -0.7436438870371587, y :  0.1318259042053120, s : 0.00002,  n : "seahorse valley" },
	{ x :  0.2929859127507,    y :  0.6117376419055,    s : 0.00003,  n : "the spiral" },
	{ x : -1.7687798000000,    y :  0.0017396000000,    s : 0.00004,  n : "the antenna" },
	{ x : -0.1010963000000,    y :  0.9562865000000,    s : 0.00002,  n : "triple spiral" },
];
tour_i = 0;
