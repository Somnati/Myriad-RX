/// rm_mandel's driver. The shader draws the fractal (sh_mandel's header
/// is where the per-pixel technique lives); this owns the view, the
/// input, the iteration budget and - since the perturbation pass - the
/// REFERENCE ORBIT the deep views are drawn relative to.
///
/// THE PRECISION LADDER, three tiers, each taking over where the last
/// runs out. datafiles/mandel_twin.py proves all of it in python before
/// any of it was written here, because it has to be written in two
/// languages at once and Claude can run neither.
///
///   f32      down to 4e-6    plain single precision in the shader
///   f32x2    down to 2e-13   the coordinate as a hi/lo float pair
///   perturb  down to 1e-26   the per-pixel loop iterates the tiny
///                            DELTA from a reference orbit, so it can
///                            be float32 again - and the precision
///                            lives here, on the CPU, where a GML
///                            `real` is a float64 and a PAIR of them
///                            is ~32 significant digits.
///
/// ⚖️ THE FINDING THAT SHAPED THIS: perturbation alone would have
/// bought almost nothing. At the f32x2 floor of 2e-13 a float64 centre
/// still has ~9 distinct values per pixel, and float64 does not bind
/// until ~2.2e-14 - so moving the per-pixel loop to float32 removes the
/// SHADER as the limit and immediately hits the CENTRE as the next one,
/// one order of magnitude later. The depth comes from double-double on
/// the CPU side; perturbation is what lets the GPU keep up with it.
///
/// THE TWO THINGS THAT MAKE IT FEEL GOOD, both here rather than in the
/// shader:
///
/// 1. ZOOM TOWARD THE CURSOR. A wheel notch records the complex point
///    under the pointer and the pixel it must stay at; the centre is
///    then DERIVED from that anchor every frame at whatever the eased
///    scale currently is. Deriving rather than correcting is what
///    makes it exact on every frame of the animation instead of only
///    its last - the first cut corrected once, instantly, to where the
///    centre belonged at the FINAL scale, and then took twenty frames
///    to get there.
/// 2. THE ZOOM IS EASED GEOMETRICALLY, so a notch is the same size at
///    every depth.

// ================= double-double, on GML's own float64 =================
// The same error-free transformations the shader runs on float32
// (Dekker, Knuth), one size up. `hi` is the value a float64 can hold
// and `lo` is exactly what that rounding discarded, so the pair carries
// ~32 significant digits - which is what a centre coordinate needs
// before it is worth perturbing around.
//
// ⚖️ THE SPLIT CONSTANT IS 134217729 = 2^27+1 HERE, for float64's
// 53-bit mantissa. The shader's is 4097 = 2^12+1 for float32's 24. Use
// one for the other and it does not fail, it silently loses exactly the
// precision the whole thing exists to buy.
DD_SPLIT = 134217729;

__ddq = function(_a, _b) {          // exact sum, given |a| >= |b|
	var _s = _a + _b;
	return [_s, _b - (_s - _a)];
};
__ddadd = function(_a, _b) {
	var _s = _a[0] + _b[0];
	var _v = _s - _a[0];
	var _e = (_a[0] - (_s - _v)) + (_b[0] - _v);
	return __ddq(_s, _e + _a[1] + _b[1]);
};
__ddsub = function(_a, _b) { return __ddadd(_a, [-_b[0], -_b[1]]); };
__ddmul = function(_a, _b) {
	var _ac = DD_SPLIT * _a[0]; var _ah = _ac - (_ac - _a[0]); var _al = _a[0] - _ah;
	var _bc = DD_SPLIT * _b[0]; var _bh = _bc - (_bc - _b[0]); var _bl = _b[0] - _bh;
	var _p  = _a[0] * _b[0];
	var _e  = ((_ah * _bh - _p) + _ah * _bl + _al * _bh) + _al * _bl;
	return __ddq(_p, _e + _a[0] * _b[1] + _a[1] * _b[0]);
};
// a plain real again. Only safe where the magnitude is small - a
// DIFFERENCE of two nearby dd values, never an absolute coordinate.
__ddflat = function(_a) { return _a[0] + _a[1]; };

// ---- the view. The CENTRE is a dd pair; SCALE is not, and does not
// need to be: a float64 represents 1e-26 perfectly well. It is the
// centre, sitting at ~0.75 and needing to move by 1e-27, that runs out.
cx = [-0.75, 0];
cy = [0, 0];
scale    = 1.35;
scale_to = 1.35;

// ---- the three floors ----
// power() rather than a literal, because GML's parser rejects
// scientific notation outright and 0.00000000000000000000000001 is a
// typo waiting to happen.
SCALE_MIN_F32  = 0.000004;
SCALE_MIN_DD   = 0.0000000000002;
SCALE_MIN_PERT = power(10, -26);
SCALE_MIN = SCALE_MIN_F32;
SCALE_MAX = 2.5;

DD_AT = 0.00002;   // below this, single precision is no longer enough

// ---- input state ----
drag    = false;
drag_mx = 0;
drag_my = 0;
drag_cx = [0, 0];
drag_cy = [0, 0];
moved   = 0;

// ---- the zoom anchor ----
// while on, the centre is DERIVED each frame so the complex point
// (anch_x, anch_y) stays under screen pixel (anch_px, anch_py).
anch_on = false;
anch_x  = [0, 0];
anch_y  = [0, 0];
anch_px = 0;
anch_py = 0;

// ---- hold to dive ----
// ⚖️ THE WHEEL ALONE CANNOT REACH THE FLOOR. At 0.78 per notch it is
// 119 notches to the f32x2 floor and 242 to the perturbation one -
// a full minute of unbroken scrolling. Nobody does that, so a viewer
// that only zooms by notches is a viewer whose depth is theoretical.
// Holding the right button dives continuously toward the cursor and
// ACCELERATES, so the deep end is seconds away instead of minutes -
// and because it re-anchors under the pointer every frame, you steer
// while you fall rather than stopping to correct.
dive_t = 0;

// ---- look ----
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
dbg       = false;   // [v] paints the raw screen coordinate

// ---- the iteration budget ----
// Detail costs iterations only as you zoom, and the useful budget grows
// with the LOG of the magnification. The sqrt term keeps deep views
// from going blobby: the boundary needs disproportionately more
// iterations exactly where it gets thinnest.
__iter = function() {
	var _mag = SCALE_MAX / max(scale, SCALE_MIN_PERT);
	return clamp(60 + 26 * log2(_mag) + 22 * sqrt(max(0, log2(_mag))), 60, 900);
};

// ================= THE REFERENCE ORBIT =================
// Perturbation rewrites z(n+1) = z^2 + c for a point c = C + d as
//     e(n+1) = 2*Z(n)*e(n) + e(n)^2 + d
// where Z is the orbit of the reference point C. e and d are tiny, so
// the shader can run that in float32 no matter how deep the view is -
// all the precision is spent HERE, once per reference, instead of per
// pixel per frame.
//
// ⚖️ THE ORBIT IS STORED AS 24-BIT FIXED POINT IN AN RGB888 TEXTURE,
// and the two limits meet exactly: 24 bits is what an RGB texel holds,
// and it is also the most a float32 shader can DECODE, because
// reconstructing more would need sums past 2^24. The twin confirms 24
// bits renders identically to full precision. So no float surface and
// no buffer_set_surface byte-order gamble - just ordinary draws.
REF_W   = 256;    // texels across; two texels per orbit step (x then y)
REF_MAX = 900;    // matches the iteration ceiling

ref_surf  = -1;
ref_len   = 0;
ref_cx    = [0, 0];
ref_cy    = [0, 0];
ref_valid = false;
ref_built = 0;    // how many times, for the readout
ref_esc   = false;// did the chosen orbit escape? (see __ref_check)

// pack a value in [-2, 2] into a colour. |Z| never exceeds 2 for a
// reference that stays in the set, which is the only kind worth having.
__ref_pack = function(_v) {
	var _u = clamp((_v + 2) / 4, 0, 1) * 16777215;
	var _i = floor(_u);
	var _r = _i mod 256;
	var _g = (_i div 256) mod 256;
	var _b = (_i div 65536) mod 256;
	return make_colour_rgb(_r, _g, _b);
};

// one candidate's orbit, at dd precision. Returns how far it got and
// whether it ESCAPED, which is the difference between "this reference
// is as long as it will ever be" and "this reference is too short".
__ref_orbit = function(_px, _py, _lim, _ox, _oy) {
	var _zx = [0, 0], _zy = [0, 0];
	for (var _i = 1; _i <= _lim; _i++) {
		var _zx2 = __ddmul(_zx, _zx);
		var _zy2 = __ddmul(_zy, _zy);
		var _nzy = __ddadd(__ddmul(__ddmul(_zx, _zy), [2, 0]), _py);
		_zx = __ddadd(__ddsub(_zx2, _zy2), _px);
		_zy = _nzy;
		var _fx = __ddflat(_zx), _fy = __ddflat(_zy);
		_ox[_i] = _fx;
		_oy[_i] = _fy;
		if (_fx * _fx + _fy * _fy > 4) return { len : _i, esc : true };
	}
	return { len : _lim, esc : false };
};

// Compute the orbit at double-double precision and paint it into the
// texture. Costs a couple of thousand draw calls, so it must NOT happen
// every frame - see __ref_check.
//
// ⚖️ THE REFERENCE HAS TO SURVIVE. A reference that escapes after forty
// steps is nearly useless: the shader rebases every forty iterations,
// and a rebase throws away the very smallness that lets the delta run
// in float32. The obvious choice - the view centre - escapes whenever
// it lands just outside the set, which is most of the time, because
// just outside the set is precisely where anything worth looking at is.
// So a handful of candidates across the view are tried and the
// LONGEST-SURVIVING one wins. Each costs a few hundred dd iterations,
// which is nothing next to painting the texture afterwards.
__ref_build = function() {
	var _n = __iter();
	var _lim = min(REF_MAX, max(64, ceil(_n * 1.6)));

	var _ox = array_create(_lim + 1, 0);
	var _oy = array_create(_lim + 1, 0);
	var _bx = array_create(_lim + 1, 0);
	var _by = array_create(_lim + 1, 0);

	// the centre first, then four points spread across the view. The
	// centre usually wins; when it does not, it usually loses badly.
	var _cand = [[0, 0], [-.35, -.35], [.35, -.35], [-.35, .35], [.35, .35]];
	var _ar = room_width / room_height;
	var _best = -1, _besc = true, _bpx = cx, _bpy = cy;

	for (var _k = 0; _k < array_length(_cand); _k++) {
		var _px = __ddadd(cx, [_cand[_k][0] * 2 * scale * _ar, 0]);
		var _py = __ddadd(cy, [_cand[_k][1] * 2 * scale, 0]);
		var _r  = __ref_orbit(_px, _py, _lim, _ox, _oy);
		if (_r.len > _best) {
			_best = _r.len;
			_besc = _r.esc;
			_bpx  = _px;
			_bpy  = _py;
			array_copy(_bx, 0, _ox, 0, _lim + 1);
			array_copy(_by, 0, _oy, 0, _lim + 1);
		}
		if (!_r.esc) break;   // it survived the whole budget; nothing beats that
	}

	// ---- paint it ----
	// ceil, not a bare divide: (REF_MAX+1)*2/REF_W is fractional, and
	// asking for a surface 7.03 texels tall is asking for the last row
	// of the orbit to land outside the texture.
	if (!surface_exists(ref_surf))
		ref_surf = surface_create(REF_W, ceil((REF_MAX + 1) * 2 / REF_W) + 1);
	surface_set_target(ref_surf);
	draw_clear_alpha(c_black, 1);
	for (var _i = 0; _i <= _best; _i++) {
		var _k2 = _i * 2;
		draw_sprite_ext(spr_pixel_1x1, 0, _k2 mod REF_W, _k2 div REF_W, 1, 1, 0,
			__ref_pack(_bx[_i]), 1);
		_k2 += 1;
		draw_sprite_ext(spr_pixel_1x1, 0, _k2 mod REF_W, _k2 div REF_W, 1, 1, 0,
			__ref_pack(_by[_i]), 1);
	}
	surface_reset_target();

	ref_len   = _best;
	ref_esc   = _besc;
	ref_cx    = _bpx;
	ref_cy    = _bpy;
	ref_valid = true;
	ref_built += 1;
};

// Rebuild only when the reference has stopped being useful: it drifted
// out of the view, it is too short for the budget, or the surface was
// lost (they are volatile on windows).
//
// ⚖️ `!ref_esc` ON THE LENGTH TEST IS THE WHOLE POINT OF THAT FLAG. An
// escaped orbit is already as long as it will ever be, so without this
// the "too short" branch fires every frame forever, rebuilding a couple
// of thousand texels per frame and grinding the room to a crawl - which
// does not look like a rebuild loop, it looks like the zoom refusing to
// go any deeper.
__ref_check = function() {
	if (scale > DD_AT) return;                       // shallow: not needed
	if (!surface_exists(ref_surf)) ref_valid = false;
	if (!ref_valid) { __ref_build(); return; }
	if (!ref_esc && ref_len < __iter()) { __ref_build(); return; }
	var _dx = __ddflat(__ddsub(cx, ref_cx));
	var _dy = __ddflat(__ddsub(cy, ref_cy));
	if (abs(_dx) > scale * 1.5 || abs(_dy) > scale * 1.5) __ref_build();
};

__pert_on = function() {
	return (scale <= DD_AT) && ref_valid && surface_exists(ref_surf);
};
// the f32x2 path is the FALLBACK now: it covers the frame or two after
// a view change when the reference has not been rebuilt yet, which is
// exactly the gap that would otherwise show as a flicker of garbage.
__dd_on = function() { return (scale <= DD_AT) && !__pert_on(); };

// ---- uniform handles, fetched once ----
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
u_aspect = shader_get_uniform(sh_mandel, "u_aspect");
u_dbg    = shader_get_uniform(sh_mandel, "u_dbg");
u_pert   = shader_get_uniform(sh_mandel, "u_pert");
u_dcoff  = shader_get_uniform(sh_mandel, "u_dcoff");
u_reflen = shader_get_uniform(sh_mandel, "u_reflen");
u_reftex = shader_get_uniform(sh_mandel, "u_reftex");
s_ref    = shader_get_sampler_index(sh_mandel, "u_ref");

// AND CHECK THEM. shader_get_uniform returns -1 when a name does not
// match or the compiler optimised it away, and shader_set_uniform_f on
// -1 is a SILENT no-op - so the only evidence is a picture that is
// wrong in a way that says nothing about the cause. Each one names
// itself in the log instead.
var _uni = [["u_centre", u_centre], ["u_scale", u_scale], ["u_res", u_res],
	["u_iter", u_iter], ["u_time", u_time], ["u_pal", u_pal],
	["u_glow", u_glow], ["u_centre_dd", u_cdd], ["u_scale_dd", u_sdd],
	["u_dd", u_dd], ["u_aspect", u_aspect], ["u_dbg", u_dbg],
	["u_pert", u_pert], ["u_dcoff", u_dcoff], ["u_reflen", u_reflen],
	["u_reftex", u_reftex], ["u_ref sampler", s_ref]];
for (var _i = 0; _i < array_length(_uni); _i++)
	if (_uni[_i][1] < 0)
		show("sh_mandel > uniform NOT FOUND: " + _uni[_i][0]
			+ " (the shader will fall back and the view will be wrong)");

// ---- splitting a double for the SHADER's f32x2 path ----
// Different job from the dd arithmetic above: that carries GML's own
// float64s in pairs, this cuts one float64 into two float32s so it can
// cross a uniform. The round-trip through a 4-byte buffer IS the f32
// rounding - GML has no float cast, and anything built from logs and
// powers would be approximate, which defeats the point.
if (!variable_global_exists("dd_buf")) g.dd_buf = buffer_create(4, buffer_fixed, 1);
__split = function(_v) {
	buffer_seek(g.dd_buf, buffer_seek_start, 0);
	buffer_write(g.dd_buf, buffer_f32, _v);
	buffer_seek(g.dd_buf, buffer_seek_start, 0);
	var _hi = buffer_read(g.dd_buf, buffer_f32);
	return [_hi, _v - _hi];
};

// screen pixel -> complex plane, at the CURRENT view, in dd. THE one
// place that conversion is written, so the anchor maths and anything
// added later cannot disagree about where the pointer is.
__at = function(_px, _py) {
	var _ar = room_width / room_height;
	return {
		x : __ddadd(cx, [((_px / room_width)  - 0.5) * 2 * scale * _ar, 0]),
		y : __ddadd(cy, [((_py / room_height) - 0.5) * 2 * scale, 0]),
	};
};

// a small set of places worth arriving at, for [space]. Hand-picked -
// the interesting parts of this set are not where you land by accident.
// The coordinates are float64 literals, so these are shallow
// destinations by construction; going deeper than ~1e-14 means steering
// there yourself, where the anchor carries the full dd precision.
tour = [
	{ x : -0.75,               y :  0.0,                s : 1.35,     n : "the whole set" },
	{ x : -0.7436438870371587, y :  0.1318259042053120, s : 0.00002,  n : "seahorse valley" },
	{ x :  0.2929859127507,    y :  0.6117376419055,    s : 0.00003,  n : "the spiral" },
	{ x : -1.7687798000000,    y :  0.0017396000000,    s : 0.00004,  n : "the antenna" },
	{ x : -0.1010963000000,    y :  0.9562865000000,    s : 0.00002,  n : "triple spiral" },
];
tour_i = 0;
