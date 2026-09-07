/// rm_mandel's driver. The shader draws the fractal (sh_mandel's header
/// is where the per-pixel technique lives); this owns the view, the
/// input, the iteration budget and the REFERENCE ORBIT that deep views
/// are drawn relative to.
///
/// THE PRECISION LADDER, each tier taking over where the last runs out.
/// datafiles/mandel_twin.py proves every rung of it in python before it
/// was written here, because it has to be written in two languages at
/// once and Claude can run neither.
///
///   f32      to 4e-6     plain single precision in the shader
///   f32x2    to 2e-13    the coordinate as a hi/lo float pair
///   perturb  to ~1e-350  the per-pixel loop iterates the tiny DELTA
///                        from a reference orbit, so it stays float32
///                        at ANY depth - and all the precision lives
///                        here, on the CPU, in a bignum
///
/// AND THE DEPTH IS NO LONGER THE BINDING LIMIT - the ITERATION BUDGET
/// is. The formula asks for 2546 iterations at 1e-26 and 11780 at
/// 1e-130, so a ceiling of 900 was stopping the picture resolving long
/// before the numbers ran out. A coordinate precise enough to address a
/// place you cannot resolve is not depth, it is arithmetic. Hence 3000,
/// and the progressive renderer in Draw that makes 3000 affordable.
///
/// ⚖️ WHY THE BIGNUM AND NOT JUST PERTURBATION. Perturbation alone
/// bought almost nothing: at the f32x2 floor a float64 centre still had
/// ~9 values per pixel, so moving the per-pixel loop to float32 removed
/// the SHADER as the limit and hit the CENTRE one order later. Then
/// double-double on GML's float64 pushed that to ~1e-26 and hit it
/// again. Depth is a property of the number the CPU can hold, and
/// nothing else - perturbation is only what stops the GPU caring.

// ================= THE BIGNUM =================
// Fixed point, sign and magnitude, base 2^20. Every one of those is a
// GML constraint rather than a preference:
//
//  - FIXED POINT, not floating: coordinates live in (-8, 8) and need
//    absolute precision at the far end. An exponent would buy nothing
//    and cost a normalisation in the inner loop.
//  - SIGN AND MAGNITUDE: GML has no integers and no bit operations
//    worth using, so two's complement would be a fight for no gain.
//  - ⚖️ BASE 2^20. A GML `real` is a float64, exact on integers only to
//    2^53. A multiply accumulates up to L*(BASE-1)^2 in one column, so
//    L*2^40 < 2^53 leaves room for thousands of limbs. BASE 2^24 would
//    cap it at 31 and start silently rounding at 32 - the failure would
//    be wrong digits, not an error.
//
// LAYOUT: a plain array, [0] = sign (1 or -1), [1..L] = limbs, where
// limb 1 is the integer part and limb i is the coefficient of
// BASE^-(i-1). One array rather than a struct holding an array: this
// allocates a few thousand times per reference build, and halving the
// allocations matters more than the tidier shape would.
BN_BASE = 1048576;      // 2^20, about 6.02 decimal digits per limb
BN_MAX  = 64;           // ceiling on limbs, ~385 digits, see __bn_want

bn_L = 4;               // live limb count, follows the zoom

__bnzero = function(_L) {
	var _a = array_create(_L + 1, 0);
	_a[0] = 1;
	return _a;
};

__bnfrom = function(_v, _L) {
	var _a = array_create(_L + 1, 0);
	_a[0] = (_v < 0) ? -1 : 1;
	var _u = abs(_v);
	_a[1] = floor(_u);
	var _f = _u - _a[1];
	for (var _i = 2; _i <= _L; _i++) {
		_f *= BN_BASE;
		_a[_i] = floor(_f);
		_f -= _a[_i];
	}
	return _a;
};

// back to a float64. ONLY meaningful when the value is small - a
// DIFFERENCE of two nearby coordinates, never an absolute one, because
// a double cannot hold what the bignum is carrying.
__bnreal = function(_a) {
	var _v = 0, _m = 1;
	for (var _i = 1; _i < array_length(_a); _i++) {
		_v += _a[_i] * _m;
		_m /= BN_BASE;
	}
	return _v * _a[0];
};

// grow (or shrink) to L limbs. Growing appends zeros and is EXACT,
// which is what lets the limb count follow the zoom without the view
// ever jumping.
__bngrow = function(_a, _L) {
	var _b = array_create(_L + 1, 0);
	_b[0] = _a[0];
	var _n = min(_L, array_length(_a) - 1);
	for (var _i = 1; _i <= _n; _i++) _b[_i] = _a[_i];
	return _b;
};

__bncmp = function(_a, _b) {          // magnitudes only
	for (var _i = 1; _i < array_length(_a); _i++)
		if (_a[_i] != _b[_i]) return (_a[_i] > _b[_i]) ? 1 : -1;
	return 0;
};

__bnaddmag = function(_a, _b, _L) {
	var _d = array_create(_L + 1, 0);
	var _c = 0;
	for (var _i = _L; _i >= 1; _i--) {
		var _t = _a[_i] + _b[_i] + _c;
		_c = (_t >= BN_BASE) ? 1 : 0;
		_d[_i] = _t - _c * BN_BASE;
	}
	return _d;
};

__bnsubmag = function(_a, _b, _L) {   // |a| - |b|, assuming |a| >= |b|
	var _d = array_create(_L + 1, 0);
	var _r = 0;
	for (var _i = _L; _i >= 1; _i--) {
		var _t = _a[_i] - _b[_i] - _r;
		_r = (_t < 0) ? 1 : 0;
		_d[_i] = _t + _r * BN_BASE;
	}
	return _d;
};

__bnadd = function(_a, _b) {
	var _L = array_length(_a) - 1;
	var _d;
	if (_a[0] == _b[0]) {
		_d = __bnaddmag(_a, _b, _L);
		_d[0] = _a[0];
		return _d;
	}
	var _c = __bncmp(_a, _b);
	if (_c == 0) return __bnzero(_L);
	if (_c > 0) { _d = __bnsubmag(_a, _b, _L); _d[0] = _a[0]; }
	else        { _d = __bnsubmag(_b, _a, _L); _d[0] = _b[0]; }
	return _d;
};

__bnneg = function(_a) {
	var _b = array_create(array_length(_a), 0);
	array_copy(_b, 0, _a, 0, array_length(_a));
	_b[0] = -_a[0];
	return _b;
};

__bnsub = function(_a, _b) { return __bnadd(_a, __bnneg(_b)); };

// convolution, then carries from the small end upward. limb i times
// limb j lands at position i+j-1 because position k weighs BASE^-(k-1);
// everything past L is below the precision being kept and is dropped
// only AFTER it has contributed its carry.
__bnmul = function(_a, _b) {
	var _L = array_length(_a) - 1;
	var _W = 2 * _L;
	var _p = array_create(_W + 1, 0);
	for (var _i = 1; _i <= _L; _i++) {
		var _ai = _a[_i];
		if (_ai == 0) continue;
		for (var _j = 1; _j <= _L; _j++)
			_p[_i + _j - 1] += _ai * _b[_j];
	}
	var _c = 0;
	for (var _k = _W; _k >= 2; _k--) {
		var _t = _p[_k] + _c;
		_c = floor(_t / BN_BASE);
		_p[_k] = _t - _c * BN_BASE;
	}
	_p[1] += _c;
	var _d = array_create(_L + 1, 0);
	_d[0] = _a[0] * _b[0];
	for (var _k = 1; _k <= _L; _k++) _d[_k] = _p[_k];
	return _d;
};

// ⚖️ THE LIMB COUNT MUST FOLLOW THE ZOOM. A multiply is O(L^2) and the
// reference runs hundreds of steps, so a fixed ceiling would make every
// shallow view pay for depth it is not using - 24 limbs costs twelve
// times what 7 does, and 7 already reaches 1e-26.
__bn_want = function() {
	var _dig = -log10(max(scale, power(10, -360))) + 8;
	return clamp(ceil(_dig / 6.02) + 2, 4, BN_MAX);
};

// ---- the view. The CENTRE is a bignum; SCALE is an ordinary real and
// does not need to be more: a float64 represents 1e-350 perfectly well.
// It is the centre, sitting at 0.75 and needing to move by 1e-351, that
// runs out of digits.
cx = __bnfrom(-0.75, bn_L);
cy = __bnfrom(0, bn_L);
scale    = 1.35;
scale_to = 1.35;

// ---- the floors ----
// power() rather than literals: GML's parser rejects scientific
// notation outright, and writing 1e-130 by hand as zeros is a typo
// waiting to happen.
SCALE_MIN_F32  = 0.000004;
SCALE_MIN_DD   = 0.0000000000002;
SCALE_MIN_PERT = power(10, -350);
SCALE_MIN = SCALE_MIN_F32;
SCALE_MAX = 2.5;

DD_AT = 0.00002;   // below this, single precision is no longer enough

// ---- input state ----
drag    = false;
drag_mx = 0;
drag_my = 0;
drag_cx = cx;
drag_cy = cy;
moved   = 0;

// ---- the zoom anchor ----
anch_on = false;
anch_x  = cx;
anch_y  = cy;
anch_px = 0;
anch_py = 0;

// ---- hold to dive ----
// ⚖️ THE WHEEL ALONE CANNOT REACH THE FLOOR - it is 119 notches to the
// f32x2 floor and hundreds beyond. A viewer that only zooms by notches
// is a viewer whose depth is theoretical.
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
__iter = function() {
	var _mag = SCALE_MAX / max(scale, SCALE_MIN_PERT);
	return clamp(60 + 26 * log2(_mag) + 22 * sqrt(max(0, log2(_mag))), 60, MAX_ITER);
};

// ================= THE REFERENCE ORBIT =================
// Perturbation rewrites z(n+1) = z^2 + c for c = C + d as
//     e(n+1) = 2*Z(n)*e(n) + e(n)^2 + d
// where Z is the orbit of the reference point C. e and d are tiny, so
// the shader runs that in float32 at any depth - the precision is spent
// HERE, once per reference, instead of per pixel per frame.
//
// ⚖️ STORED AS 24-BIT FIXED POINT IN AN RGB888 TEXTURE, where two
// limits meet exactly: 24 bits is what a texel holds, and it is also
// the most a float32 shader can DECODE, since reconstructing more needs
// sums past 2^24. The twin confirms 24 bits renders identically to full
// precision, so no float surface and no buffer_set_surface byte-order
// gamble - ordinary draws.
REF_W    = 256;
REF_MAX  = 3000;   // must reach MAX_ITER, or deep views rebase constantly
MAX_ITER = 3000;   // matches sh_mandel's MAX_I

ref_surf  = -1;
ref_len   = 0;
ref_cx    = cx;
ref_cy    = cy;
ref_valid = false;
ref_built = 0;
ref_esc   = false;
ref_L     = 0;    // limb count the current reference was computed at

__ref_pack = function(_v) {
	var _u = clamp((_v + 2) / 4, 0, 1) * 16777215;
	var _i = floor(_u);
	return make_colour_rgb(_i mod 256, (_i div 256) mod 256, (_i div 65536) mod 256);
};

// ================= BUILDING IT, A SLICE AT A TIME =================
// ⚖️ THE BUILD CANNOT BE SYNCHRONOUS ANY MORE. At 64 limbs a 3000-step
// orbit is ~37 million limb-multiplies, which in GML is seconds - a
// freeze every time the reference goes stale. So it runs as a JOB: a
// bounded slice per frame, with the OLD reference still serving the
// screen until the new one is finished. A dive keeps rendering the
// whole time; it just renders against a slightly stale reference for a
// second or two, which perturbation tolerates by construction.
rj_on   = false;
rj_list = [];        // candidate points still to try
rj_ci   = 0;
rj_zx   = 0;
rj_zy   = 0;
rj_i    = 0;
rj_lim  = 0;
rj_ox   = [];
rj_oy   = [];
rj_bx   = [];
rj_by   = [];
rj_best = -1;
rj_besc = true;
rj_bpx  = 0;
rj_bpy  = 0;
rj_L    = 0;

// how many orbit steps to afford this frame. O(L^2) per step, so the
// deep end takes many more frames - which is exactly right, because the
// deep end is also where the old reference stays valid longest.
__rj_budget = function() {
	return clamp(floor(90000 / (3 * bn_L * bn_L)), 6, 3000);
};

// ⚖️ THE ANCHOR IS THE FIRST CANDIDATE, and that is what makes a dive
// affordable at all. A reference at the view CENTRE goes stale as the
// centre slides toward the anchor - the drift test then fires about
// every time the scale halves, so a continuous dive would start a new
// job every second and never finish one. The anchor is a FIXED point in
// the plane that stays put on screen, so a reference built there
// survives the entire descent.
//
// After it, the centre and four points across the view. A reference
// that escapes after forty steps is nearly useless - the shader rebases
// every forty iterations and a rebase throws away the smallness that
// lets the delta run in float32 - and the obvious choices escape often,
// because just outside the set is exactly where anything worth looking
// at is. A bad candidate dies cheaply though: it escapes early, so
// trying several costs far less than it sounds.
__ref_begin = function() {
	var _n = __iter();
	rj_lim = min(REF_MAX, max(64, ceil(_n * 1.6)));
	rj_L   = bn_L;

	var _ar = room_width / room_height;
	rj_list = [];
	if (anch_on) array_push(rj_list, [anch_x, anch_y]);
	array_push(rj_list, [cx, cy]);
	var _off = [[-.35, -.35], [.35, -.35], [-.35, .35], [.35, .35]];
	for (var _k = 0; _k < 4; _k++)
		array_push(rj_list, [
			__bnadd(cx, __bnfrom(_off[_k][0] * 2 * scale * _ar, rj_L)),
			__bnadd(cy, __bnfrom(_off[_k][1] * 2 * scale, rj_L))]);

	rj_ox = array_create(rj_lim + 2, 0);
	rj_oy = array_create(rj_lim + 2, 0);
	rj_bx = array_create(rj_lim + 2, 0);
	rj_by = array_create(rj_lim + 2, 0);
	rj_best = -1;
	rj_besc = true;
	rj_ci   = 0;
	rj_on   = true;
	__rj_cand();
};

// start the current candidate from z = 0
__rj_cand = function() {
	rj_zx = __bnzero(rj_L);
	rj_zy = __bnzero(rj_L);
	rj_i  = 0;
};

// keep the candidate just finished if it beat the best so far, then
// move on - or paint, if it survived the whole budget or we are out
__rj_close = function(_esc) {
	if (rj_i > rj_best) {
		rj_best = rj_i;
		rj_besc = _esc;
		rj_bpx  = rj_list[rj_ci][0];
		rj_bpy  = rj_list[rj_ci][1];
		array_copy(rj_bx, 0, rj_ox, 0, rj_lim + 2);
		array_copy(rj_by, 0, rj_oy, 0, rj_lim + 2);
	}
	// a survivor cannot be beaten, so stop looking
	if (!_esc) { __ref_paint(); return; }
	rj_ci += 1;
	if (rj_ci >= array_length(rj_list)) { __ref_paint(); return; }
	__rj_cand();
};

// advance the running candidate by at most `_budget` orbit steps
__ref_step = function(_budget) {
	if (!rj_on) return;
	var _px = rj_list[rj_ci][0];
	var _py = rj_list[rj_ci][1];
	repeat (_budget) {
		if (rj_i >= rj_lim) { __rj_close(false); return; }
		rj_i += 1;
		var _zx2 = __bnmul(rj_zx, rj_zx);
		var _zy2 = __bnmul(rj_zy, rj_zy);
		var _xy  = __bnmul(rj_zx, rj_zy);
		var _nzy = __bnadd(__bnadd(_xy, _xy), _py);
		rj_zx = __bnadd(__bnsub(_zx2, _zy2), _px);
		rj_zy = _nzy;
		// the escape test only needs the top limbs, so it reads the
		// flattened value - a double is plenty to know whether |z| > 2
		var _fx = __bnreal(rj_zx), _fy = __bnreal(rj_zy);
		rj_ox[rj_i] = _fx;
		rj_oy[rj_i] = _fy;
		if (_fx * _fx + _fy * _fy > 4) { __rj_close(true); return; }
	}
};

__ref_paint = function() {
	rj_on = false;
	if (rj_best <= 0) { ref_valid = false; return; }

	// ceil, not a bare divide: (REF_MAX+1)*2/REF_W is fractional, and a
	// surface that is 23.4 texels tall drops the last row of the orbit.
	if (!surface_exists(ref_surf))
		ref_surf = surface_create(REF_W, ceil((REF_MAX + 1) * 2 / REF_W) + 1);
	surface_set_target(ref_surf);
	draw_clear_alpha(c_black, 1);
	for (var _i = 0; _i <= rj_best; _i++) {
		var _k = _i * 2;
		draw_sprite_ext(spr_pixel_1x1, 0, _k mod REF_W, _k div REF_W, 1, 1, 0,
			__ref_pack(rj_bx[_i]), 1);
		_k += 1;
		draw_sprite_ext(spr_pixel_1x1, 0, _k mod REF_W, _k div REF_W, 1, 1, 0,
			__ref_pack(rj_by[_i]), 1);
	}
	surface_reset_target();

	ref_len   = rj_best;
	ref_esc   = rj_besc;
	ref_cx    = rj_bpx;
	ref_cy    = rj_bpy;
	ref_L     = rj_L;
	ref_valid = true;
	ref_built += 1;
};

// ⚖️ `!ref_esc` ON THE LENGTH TEST IS WHY THAT FLAG EXISTS. An escaped
// orbit is already as long as it will ever be, so without it the "too
// short" branch starts a job every frame forever - which from outside
// does not look like a rebuild loop, it looks like the zoom refusing to
// go any deeper.
__ref_check = function() {
	if (scale > DD_AT) return;
	if (!surface_exists(ref_surf)) ref_valid = false;
	if (rj_on) { __ref_step(__rj_budget()); return; }

	var _need = false;
	if (!ref_valid) _need = true;
	else if (ref_L != bn_L) _need = true;    // computed at a coarser width
	else if (!ref_esc && ref_len < __iter()) _need = true;
	else {
		var _dx = __bnreal(__bnsub(cx, ref_cx));
		var _dy = __bnreal(__bnsub(cy, ref_cy));
		if (abs(_dx) > scale * 2.5 || abs(_dy) > scale * 2.5) _need = true;
	}
	if (_need) { __ref_begin(); __ref_step(__rj_budget()); }
};

// the limb count follows the zoom; growing is exact, so the view never
// jumps when it changes. Everything holding a coordinate has to grow
// together or the arithmetic starts comparing arrays of two lengths.
__bn_check = function() {
	var _w = __bn_want();
	if (_w == bn_L) return;
	bn_L    = _w;
	cx      = __bngrow(cx, _w);
	cy      = __bngrow(cy, _w);
	anch_x  = __bngrow(anch_x, _w);
	anch_y  = __bngrow(anch_y, _w);
	drag_cx = __bngrow(drag_cx, _w);
	drag_cy = __bngrow(drag_cy, _w);
	ref_cx  = __bngrow(ref_cx, _w);
	ref_cy  = __bngrow(ref_cy, _w);
	// NOT invalidated: growing is exact, so the old reference keeps
	// serving the screen while __ref_check starts a job for a new one at
	// the wider precision. Blanking it here would drop the picture to
	// the f32x2 fallback - which at this depth is noise - for however
	// many frames the rebuild takes.
};

__pert_on = function() {
	return (scale <= DD_AT) && ref_valid && surface_exists(ref_surf);
};
// f32x2 is the FALLBACK now: it covers the frame or two after a view
// change when the reference has not been rebuilt yet, which is exactly
// the gap that would otherwise show as a flicker of garbage.
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
// wrong in a way that says nothing about the cause.
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
// A different job from the bignum: that carries the coordinate, this
// cuts one float64 into two float32s so it can cross a uniform. The
// round-trip through a 4-byte buffer IS the f32 rounding - GML has no
// float cast, and anything built from logs and powers would be
// approximate, which defeats the point.
if (!variable_global_exists("dd_buf")) g.dd_buf = buffer_create(4, buffer_fixed, 1);
__split = function(_v) {
	buffer_seek(g.dd_buf, buffer_seek_start, 0);
	buffer_write(g.dd_buf, buffer_f32, _v);
	buffer_seek(g.dd_buf, buffer_seek_start, 0);
	var _hi = buffer_read(g.dd_buf, buffer_f32);
	return [_hi, _v - _hi];
};

// ================= THE RENDER SURFACE =================
// See Draw's header for why. The state is here so it survives the frame.
rend_surf  = -1;
rend_dirty = true;
rend_band  = 0;
// the signature the renderer compares against to notice a change
rend_k_scale = -1;
rend_k_dx    = -1;
rend_k_dy    = -1;
rend_k_pal   = -1;
rend_k_glow  = -1;
rend_k_dbg   = -1;
rend_k_ref   = -1;
rend_k_pert  = -1;
rend_k_it    = -1;

// EVERY uniform, in one place, so the coarse pass and the refine pass
// cannot drift apart - they differ only in the iteration count, and
// that difference is the argument.
__shade = function(_iter, _p, _pert, _dd) {
	shader_set(sh_mandel);
	// ⚖️ u_res IS THE RENDER TARGET, and the target is now the room-sized
	// surface, so this is simply the room. gl_FragCoord counts
	// render-target pixels; when this drew straight to the display the
	// target was application_surface, sized to the WINDOW, and dividing
	// by the room gave a coordinate wrong by the window/room ratio -
	// which made the picture a stretched crop and made zoom-toward-
	// cursor point somewhere the cursor was not.
	shader_set_uniform_f(u_res,    room_width, room_height);
	shader_set_uniform_f(u_aspect, room_width / room_height);
	shader_set_uniform_f(u_dbg,    dbg ? 1 : 0);

	// the shallow paths read the centre as plain floats, which is safe
	// BECAUSE they are only reached above 2e-5
	shader_set_uniform_f(u_centre, __bnreal(cx), __bnreal(cy));
	shader_set_uniform_f(u_scale,  scale);
	shader_set_uniform_f(u_iter,   _iter);
	shader_set_uniform_f(u_time,   current_time / 1000);
	shader_set_uniform_f(u_pal,    _p.r, _p.g, _p.b, pal_shift);
	shader_set_uniform_f(u_glow,   glow);

	var _sx = __split(__bnreal(cx));
	var _sy = __split(__bnreal(cy));
	var _ss = __split(scale);
	shader_set_uniform_f(u_cdd, _sx[0], _sx[1], _sy[0], _sy[1]);
	shader_set_uniform_f(u_sdd, _ss[0], _ss[1]);
	shader_set_uniform_f(u_dd,  _dd ? 1 : 0);

	shader_set_uniform_f(u_pert, _pert ? 1 : 0);
	if (_pert) {
		// ⚖️ THE ONLY THING THAT CROSSES IS A DIFFERENCE. cx and ref_cx
		// are bignums with hundreds of digits and neither would survive
		// a float uniform - but their DIFFERENCE is at most a view span,
		// which is exactly the size a float carries perfectly. That is
		// the whole reason perturbation makes depth a CPU question.
		shader_set_uniform_f(u_dcoff,
			__bnreal(__bnsub(cx, ref_cx)), __bnreal(__bnsub(cy, ref_cy)));
		shader_set_uniform_f(u_reflen, ref_len);
		shader_set_uniform_f(u_reftex, REF_W, surface_get_height(ref_surf));
		texture_set_stage(s_ref, surface_get_texture(ref_surf));
		// NEAREST, and no repeat: the orbit is read at exact texel
		// centres, and a filtered read would blend two unrelated
		// iterations of the reference into one - not a soft error, a
		// wrong number in the middle of a recurrence.
		gpu_set_tex_filter_ext(s_ref, false);
		gpu_set_tex_repeat_ext(s_ref, false);
	} else {
		shader_set_uniform_f(u_dcoff,  0, 0);
		shader_set_uniform_f(u_reflen, 0);
		shader_set_uniform_f(u_reftex, 1, 1);
	}
};

// screen pixel -> complex plane at the CURRENT view, in bignum. THE one
// place that conversion is written, so the anchor maths and anything
// added later cannot disagree about where the pointer is.
__at = function(_px, _py) {
	var _ar = room_width / room_height;
	return {
		x : __bnadd(cx, __bnfrom(((_px / room_width)  - 0.5) * 2 * scale * _ar, bn_L)),
		y : __bnadd(cy, __bnfrom(((_py / room_height) - 0.5) * 2 * scale, bn_L)),
	};
};

// a small set of places worth arriving at, for [space]. The coordinates
// are float64 literals, so these are shallow destinations by
// construction; past ~1e-14 you steer there yourself, where the anchor
// carries the full bignum precision.
tour = [
	{ x : -0.75,               y :  0.0,                s : 1.35,     n : "the whole set" },
	{ x : -0.7436438870371587, y :  0.1318259042053120, s : 0.00002,  n : "seahorse valley" },
	{ x :  0.2929859127507,    y :  0.6117376419055,    s : 0.00003,  n : "the spiral" },
	{ x : -1.7687798000000,    y :  0.0017396000000,    s : 0.00004,  n : "the antenna" },
	{ x : -0.1010963000000,    y :  0.9562865000000,    s : 0.00002,  n : "triple spiral" },
];
tour_i = 0;
