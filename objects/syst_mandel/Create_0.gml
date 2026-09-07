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
///    holding the wheel down reads as a continuous dive. The centre
///    eases with it, which is what stops the eased zoom from sliding
///    off the point you aimed at.
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

// float32 stops resolving neighbouring pixels below about here (see the
// header). Measured in the same units as `scale`.
SCALE_MIN = 0.000004;
SCALE_MAX = 2.5;

// ---- input state ----
drag    = false;
drag_mx = 0;
drag_my = 0;
drag_cx = 0;
drag_cy = 0;
moved   = 0;         // pixels dragged, so a tap is not read as a pan

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
	var _mag = SCALE_MAX / max(scale, SCALE_MIN);
	return clamp(60 + 34 * log2(_mag) + 26 * sqrt(max(0, log2(_mag))), 60, 256);
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
