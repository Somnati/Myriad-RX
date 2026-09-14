/// THE COIN (his call, 2026-09-13: "we do need a coin but tech demo's
/// coin looked bad"). The dice's rigid-body engine - the same solver,
/// the same laws - wearing a COIN HULL: contact spheres ring both rim
/// edges and the equator (so it bounces on its edge, rolls on its rim
/// and wobbles down flat) and the SDF is the rounded cylinder sh_coin
/// draws, so contacts match pixels. The shader is where the demo's
/// went wrong: its engraving was a darkened mask; this one is RELIEF.
///
/// Tap = FLIP: a hard launch with an end-over-end spin; at rest the up
/// face is read - heads or tails - said above the coin and tallied
/// (g.coin, saved). Drag = throw. Scooped like the dice.
///
/// Depth 10 - pz: on the table with the dice (see obj_dice's note on
/// the depth stack).
if (!variable_global_exists("coin_scoop")) g.coin_scoop = false;
coin_init();
depth = 10;

// ---- shape (must match sh_coin) ----
r   = 14;         // radius, px
CT  = .18;        // half thickness, in radii
RDC = .10;        // edge rounding, in radii
ct  = CT * r;     // half thickness, px
rrc = RDC * r;    // rounding = the contact sphere radius
rr  = rrc;        // (the dice's name for it - their pair pass reads it)
QP  = 1.3;        // draw quad half-extent in radii
px_cell = 1;

// the finish: the dice roster by g.coin_mat (settings > visuals), gold by
// default - coin_mat_apply; the Step repaints on the setting changing
tint = c_gold; metal = 1; iri = 0; mat_id = "";
coin_mat_apply();

// ---- rigid body ----
pz = r + 16 + irandom(12);
vx = 0; vy = 0; vz = 0;
wx = random_range(-.06, .06); wy = random_range(-.06, .06); wz = random_range(-.04, .04);
orient = mat3_mul(mat3_rot(1, 0, 0, random_range(-12, 12)), mat3_rot(0, 0, 1, irandom(359)));

invm = 1;
// ⚖️ THE TENSOR (round two, 2026-09-14): a thin cylinder is NOT isotropic
// - about its axle I_z = r^2/2, across it I_x = I_y = r^2/4 + h^2/3 (h
// the half thickness, m 1) - and that difference IS a coin's motion: a
// tumble is twice as easy to start and stop as a spin, which is why a
// spun coin wobbles down faster and faster while a tumbling one flops.
// The contact maths runs its angular term through I^-1 in OBJECT space
// (__winv); the scalar below is only what the dice's pair pass reads
// for the far side of a coin-die contact - their mean
invI_xy = 1 / (r * r / 4 + ct * ct / 3);
invI_z  = 1 / (r * r / 2);
invi    = (2 * invI_xy + invI_z) / 3;
grav = .34;
mu   = .42;
e_pl = .36;   // a coin rings and settles quicker than a die
e_dd = .45;
sleeping = false;
bal_t = 0;
gr_n  = 0;
lean  = 0;
flipping = false;   // a flip is in the air: the landing gets read
land_t   = 0;

xmin = 3; xmax = room_width - 3;
ymin = instance_exists(obj_ui_header) ? obj_ui_header.bar_h + 2 : 3;
ymax = room_height - 3;

// contact samplers, object space: sphere centres of radius rrc on the
// two rim edges (16 each), the equator (12) and the two face centres -
// together they trace the whole rounded hull
spts = [];
var _re = r - rrc, _ze = ct - rrc;
for (var _k = 0; _k < 16; _k++) {
	var _a = _k * 22.5;
	array_push(spts, dcos(_a) * _re, dsin(_a) * _re,  _ze);
	array_push(spts, dcos(_a) * _re, dsin(_a) * _re, -_ze);
}
for (var _k = 0; _k < 12; _k++) {
	var _a = _k * 30 + 15;
	array_push(spts, dcos(_a) * _re, dsin(_a) * _re, 0);
}
array_push(spts, 0, 0,  _ze);
array_push(spts, 0, 0, -_ze);
n_spts   = array_length(spts) div 3;   // 46
n_corner = n_spts;                     // every sampler meets the planes

// ---- hand ----
held = false;
scoop_r = 26;
hover = r + 20;
thx = 0; thy = 0;
mpx = mousex; mpy = mousey;
stic = 0;

// ---- math (the die's, verbatim - see obj_dice for the reasoning) ----
__rot = function(_ax, _ay, _az, _rad) {
	var _l = sqrt(_ax * _ax + _ay * _ay + _az * _az);
	if (_l <= 0) return [1, 0, 0, 0, 1, 0, 0, 0, 1];
	_ax /= _l; _ay /= _l; _az /= _l;
	var _c = cos(_rad), _s = sin(_rad), _t = 1 - _c;
	return [
		_t * _ax * _ax + _c,       _t * _ax * _ay - _s * _az, _t * _ax * _az + _s * _ay,
		_t * _ax * _ay + _s * _az, _t * _ay * _ay + _c,       _t * _ay * _az - _s * _ax,
		_t * _ax * _az - _s * _ay, _t * _ay * _az + _s * _ax, _t * _az * _az + _c,
	];
};
__ortho = function(_m) {
	var _x0 = _m[0], _y0 = _m[3], _z0 = _m[6];
	var _l = sqrt(_x0 * _x0 + _y0 * _y0 + _z0 * _z0);
	if (_l <= 0) _l = 1;
	_x0 /= _l; _y0 /= _l; _z0 /= _l;
	var _x1 = _m[1], _y1 = _m[4], _z1 = _m[7];
	var _d = _x1 * _x0 + _y1 * _y0 + _z1 * _z0;
	_x1 -= _d * _x0; _y1 -= _d * _y0; _z1 -= _d * _z0;
	_l = sqrt(_x1 * _x1 + _y1 * _y1 + _z1 * _z1);
	if (_l <= 0) _l = 1;
	_x1 /= _l; _y1 /= _l; _z1 /= _l;
	var _x2 = _y0 * _z1 - _z0 * _y1;
	var _y2 = _z0 * _x1 - _x0 * _z1;
	var _z2 = _x0 * _y1 - _y0 * _x1;
	return [_x0, _x1, _x2, _y0, _y1, _y2, _z0, _z1, _z2];
};

/// @func __winv(ax, ay, az)
/// @desc I^-1 applied to a world vector: into object space (columns dot),
///       scaled by the diagonal, back out
__winv = function(_ax, _ay, _az) {
	var _ox = orient[0] * _ax + orient[3] * _ay + orient[6] * _az;
	var _oy = orient[1] * _ax + orient[4] * _ay + orient[7] * _az;
	var _oz = orient[2] * _ax + orient[5] * _ay + orient[8] * _az;
	_ox *= invI_xy; _oy *= invI_xy; _oz *= invI_z;
	return [orient[0] * _ox + orient[1] * _oy + orient[2] * _oz,
	        orient[3] * _ox + orient[4] * _oy + orient[5] * _oz,
	        orient[6] * _ox + orient[7] * _oy + orient[8] * _oz];
};

// this coin's rounded-cylinder SDF, object space, px (sh_coin's)
__sdf = function(_qx, _qy, _qz) {
	var _ax = sqrt(_qx * _qx + _qy * _qy) - (r - rrc);
	var _az = abs(_qz) - (ct - rrc);
	var _mx = max(_ax, 0), _mz = max(_az, 0);
	return min(max(_ax, _az), 0) + sqrt(_mx * _mx + _mz * _mz) - rrc;
};

// shader handles
u_quad2  = shader_get_uniform(sh_coin, "u_quad");
u_or2    = shader_get_uniform(sh_coin, "u_or");
u_light2 = shader_get_uniform(sh_coin, "u_light");
u_col2   = shader_get_uniform(sh_coin, "u_col");
u_metal2 = shader_get_uniform(sh_coin, "u_metal");
u_iri2   = shader_get_uniform(sh_coin, "u_iri");
u_pad2   = shader_get_uniform(sh_coin, "u_pad");
u_cells2 = shader_get_uniform(sh_coin, "u_cells");
s_scene2   = shader_get_sampler_index(sh_coin, "u_scene");
s_scene2w  = shader_get_sampler_index(sh_coin, "u_scene2");
u_sceneuv2 = shader_get_uniform(sh_coin, "u_scene_uv");
u_sceneam2 = shader_get_uniform(sh_coin, "u_scene_amt");

// the ring: a coin on a table, pitched high, by impulse, throttled
__clack = function(_j) {
	if (_j < .9 || stic > 0) return;
	stic = 4;
	var _p = clamp(1.15 + _j * .08, 1.1, 1.7);
	play_sound_ext(snd_matclick, _p, _p + .15, clamp(_j * .08, .08, .34), 1);
};

// one sampler sphere vs one static half-space (the die's __contact)
__contact = function(_cx, _cy, _cz, _nx, _ny, _nz, _pen, _e) {
	var _rx = (_cx - _nx * rrc) - x;
	var _ry = (_cy - _ny * rrc) - y;
	var _rz = (_cz - _nz * rrc) - pz;
	var _vcx = vx + wy * _rz - wz * _ry;
	var _vcy = vy + wz * _rx - wx * _rz;
	var _vcz = vz + wx * _ry - wy * _rx;
	var _vn = _vcx * _nx + _vcy * _ny + _vcz * _nz;
	if (_vn < 0) {
		var _en = (_vn < -1.1) ? _e : 0;
		// the angular term through the tensor: b = I^-1 (r x n); the
		// effective inverse mass along n is invm + (b x r) . n
		var _kx = _ry * _nz - _rz * _ny;
		var _ky = _rz * _nx - _rx * _nz;
		var _kz = _rx * _ny - _ry * _nx;
		var _b = __winv(_kx, _ky, _kz);
		var _bxr = (_b[1] * _rz - _b[2] * _ry) * _nx + (_b[2] * _rx - _b[0] * _rz) * _ny + (_b[0] * _ry - _b[1] * _rx) * _nz;
		var _j = -(1 + _en) * _vn / (invm + _bxr);
		vx += _nx * _j * invm; vy += _ny * _j * invm; vz += _nz * _j * invm;
		wx += _b[0] * _j; wy += _b[1] * _j; wz += _b[2] * _j;
		_vcx = vx + wy * _rz - wz * _ry;
		_vcy = vy + wz * _rx - wx * _rz;
		_vcz = vz + wx * _ry - wy * _rx;
		var _vn2 = _vcx * _nx + _vcy * _ny + _vcz * _nz;
		var _tx = _vcx - _nx * _vn2, _ty = _vcy - _ny * _vn2, _tz = _vcz - _nz * _vn2;
		var _tl = sqrt(_tx * _tx + _ty * _ty + _tz * _tz);
		if (_tl > .001) {
			_tx /= -_tl; _ty /= -_tl; _tz /= -_tl;
			var _fx = _ry * _tz - _rz * _ty;
			var _fy = _rz * _tx - _rx * _tz;
			var _fz = _rx * _ty - _ry * _tx;
			var _bf = __winv(_fx, _fy, _fz);
			var _bfr = (_bf[1] * _rz - _bf[2] * _ry) * _tx + (_bf[2] * _rx - _bf[0] * _rz) * _ty + (_bf[0] * _ry - _bf[1] * _rx) * _tz;
			var _jt = _tl / (invm + _bfr);
			_jt = min(_jt, mu * _j);
			vx += _tx * _jt * invm; vy += _ty * _jt * invm; vz += _tz * _jt * invm;
			wx += _bf[0] * _jt; wy += _bf[1] * _jt; wz += _bf[2] * _jt;
		}
		__clack(_j);
		return 1;
	}
	return 1;
};

// every sampler against the 5 tray planes; the position correction once
// per plane at the deepest one, past a slop (the die's rule)
__plane_pass = function() {
	var _sup = 0;
	var _pf = 0, _pl = 0, _pr = 0, _pt = 0, _pb = 0;
	for (var _i = 0; _i < n_corner; _i++) {
		var _ox3 = spts[_i * 3], _oy3 = spts[_i * 3 + 1], _oz3 = spts[_i * 3 + 2];
		var _cx = x  + orient[0] * _ox3 + orient[1] * _oy3 + orient[2] * _oz3;
		var _cy = y  + orient[3] * _ox3 + orient[4] * _oy3 + orient[5] * _oz3;
		var _cz = pz + orient[6] * _ox3 + orient[7] * _oy3 + orient[8] * _oz3;
		var _pen = rrc - _cz;
		if (_pen > 0) { _sup += __contact(_cx, _cy, _cz, 0, 0, 1, _pen, e_pl); _pf = max(_pf, _pen); }
		_pen = rrc - (_cx - xmin);
		if (_pen > 0) { __contact(_cx, _cy, _cz, 1, 0, 0, _pen, e_pl); _pl = max(_pl, _pen); }
		_pen = rrc - (xmax - _cx);
		if (_pen > 0) { __contact(_cx, _cy, _cz, -1, 0, 0, _pen, e_pl); _pr = max(_pr, _pen); }
		_pen = rrc - (_cy - ymin);
		if (_pen > 0) { __contact(_cx, _cy, _cz, 0, 1, 0, _pen, e_pl); _pt = max(_pt, _pen); }
		_pen = rrc - (ymax - _cy);
		if (_pen > 0) { __contact(_cx, _cy, _cz, 0, -1, 0, _pen, e_pl); _pb = max(_pb, _pen); }
	}
	var _sl = .06;
	if (_pf > _sl) pz += (_pf - _sl) * .55;
	if (_pl > _sl) x  += (_pl - _sl) * .55;
	if (_pr > _sl) x  -= (_pr - _sl) * .55;
	if (_pt > _sl) y  += (_pt - _sl) * .55;
	if (_pb > _sl) y  -= (_pb - _sl) * .55;
	return _sup;
};

// body-on-body, one direction: _s's sample spheres against MY hull (the
// die's __pair_dir verbatim - it reads spts / n_spts / rr / invm / invi
// off either kind of body, so a die and this coin trade contacts)
__pair_dir = function(_s) {
	var _n = _s.n_spts;
	for (var _i = 0; _i < _n; _i++) {
		var _ox3 = _s.spts[_i * 3], _oy3 = _s.spts[_i * 3 + 1], _oz3 = _s.spts[_i * 3 + 2];
		var _sxw = _s.x  + _s.orient[0] * _ox3 + _s.orient[1] * _oy3 + _s.orient[2] * _oz3;
		var _syw = _s.y  + _s.orient[3] * _ox3 + _s.orient[4] * _oy3 + _s.orient[5] * _oz3;
		var _szw = _s.pz + _s.orient[6] * _ox3 + _s.orient[7] * _oy3 + _s.orient[8] * _oz3;
		var _dx = _sxw - x, _dy = _syw - y, _dz = _szw - pz;
		var _qx = orient[0] * _dx + orient[3] * _dy + orient[6] * _dz;
		var _qy = orient[1] * _dx + orient[4] * _dy + orient[7] * _dz;
		var _qz = orient[2] * _dx + orient[5] * _dy + orient[8] * _dz;
		var _pen = _s.rr - __sdf(_qx, _qy, _qz);
		if (_pen <= 0) continue;
		lean = 4;
		_s.lean = 4;
		var _e = .5;
		var _f1 = __sdf(_qx + _e, _qy - _e, _qz - _e);
		var _f2 = __sdf(_qx - _e, _qy - _e, _qz + _e);
		var _f3 = __sdf(_qx - _e, _qy + _e, _qz - _e);
		var _f4 = __sdf(_qx + _e, _qy + _e, _qz + _e);
		var _lx = _f1 - _f2 - _f3 + _f4;
		var _ly = -_f1 - _f2 + _f3 + _f4;
		var _lz = -_f1 + _f2 - _f3 + _f4;
		var _ll = sqrt(_lx * _lx + _ly * _ly + _lz * _lz);
		if (_ll <= 0) continue;
		_lx /= _ll; _ly /= _ll; _lz /= _ll;
		var _nx = orient[0] * _lx + orient[1] * _ly + orient[2] * _lz;
		var _ny = orient[3] * _lx + orient[4] * _ly + orient[5] * _lz;
		var _nz = orient[6] * _lx + orient[7] * _ly + orient[8] * _lz;
		var _cx = _sxw - _nx * _s.rr, _cy = _syw - _ny * _s.rr, _cz = _szw - _nz * _s.rr;
		var _rax = _cx - x, _ray = _cy - y, _raz = _cz - pz;
		var _rbx = _cx - _s.x, _rby = _cy - _s.y, _rbz = _cz - _s.pz;
		x  -= _nx * _pen * .32;  y  -= _ny * _pen * .32;  pz -= _nz * _pen * .32;
		_s.x += _nx * _pen * .32; _s.y += _ny * _pen * .32; _s.pz += _nz * _pen * .32;
		var _vax = vx + wy * _raz - wz * _ray, _vay = vy + wz * _rax - wx * _raz, _vaz = vz + wx * _ray - wy * _rax;
		var _vbx = _s.vx + _s.wy * _rbz - _s.wz * _rby, _vby = _s.vy + _s.wz * _rbx - _s.wx * _rbz, _vbz = _s.vz + _s.wx * _rby - _s.wy * _rbx;
		var _vrx = _vbx - _vax, _vry = _vby - _vay, _vrz = _vbz - _vaz;
		var _vn = _vrx * _nx + _vry * _ny + _vrz * _nz;
		if (_vn >= 0) continue;
		var _en = (_vn < -1.1) ? e_dd : 0;
		var _kax = _ray * _nz - _raz * _ny, _kay = _raz * _nx - _rax * _nz, _kaz = _rax * _ny - _ray * _nx;
		var _kbx = _rby * _nz - _rbz * _ny, _kby = _rbz * _nx - _rbx * _nz, _kbz = _rbx * _ny - _rby * _nx;
		var _ba = __winv(_kax, _kay, _kaz);   // my side through the tensor
		var _bar = (_ba[1] * _raz - _ba[2] * _ray) * _nx + (_ba[2] * _rax - _ba[0] * _raz) * _ny + (_ba[0] * _ray - _ba[1] * _rax) * _nz;
		var _den = invm + _s.invm + _bar
			+ _s.invi * (_kbx * _kbx + _kby * _kby + _kbz * _kbz);
		var _j = -(1 + _en) * _vn / _den;
		vx -= _nx * _j * invm; vy -= _ny * _j * invm; vz -= _nz * _j * invm;
		wx -= _ba[0] * _j; wy -= _ba[1] * _j; wz -= _ba[2] * _j;
		_s.vx += _nx * _j * _s.invm; _s.vy += _ny * _j * _s.invm; _s.vz += _nz * _j * _s.invm;
		_s.wx += _s.invi * _j * _kbx; _s.wy += _s.invi * _j * _kby; _s.wz += _s.invi * _j * _kbz;
		_vax = vx + wy * _raz - wz * _ray; _vay = vy + wz * _rax - wx * _raz; _vaz = vz + wx * _ray - wy * _rax;
		_vbx = _s.vx + _s.wy * _rbz - _s.wz * _rby; _vby = _s.vy + _s.wz * _rbx - _s.wx * _rbz; _vbz = _s.vz + _s.wx * _rby - _s.wy * _rbx;
		_vrx = _vbx - _vax; _vry = _vby - _vay; _vrz = _vbz - _vaz;
		var _vn2 = _vrx * _nx + _vry * _ny + _vrz * _nz;
		var _tx = _vrx - _nx * _vn2, _ty = _vry - _ny * _vn2, _tz = _vrz - _nz * _vn2;
		var _tl = sqrt(_tx * _tx + _ty * _ty + _tz * _tz);
		if (_tl > .001) {
			_tx /= _tl; _ty /= _tl; _tz /= _tl;
			var _fax = _ray * _tz - _raz * _ty, _fay = _raz * _tx - _rax * _tz, _faz = _rax * _ty - _ray * _tx;
			var _fbx = _rby * _tz - _rbz * _ty, _fby = _rbz * _tx - _rbx * _tz, _fbz = _rbx * _ty - _rby * _tx;
			var _bfa = __winv(_fax, _fay, _faz);
			var _bfar = (_bfa[1] * _raz - _bfa[2] * _ray) * _tx + (_bfa[2] * _rax - _bfa[0] * _raz) * _ty + (_bfa[0] * _ray - _bfa[1] * _rax) * _tz;
			var _dent = invm + _s.invm + _bfar
				+ _s.invi * (_fbx * _fbx + _fby * _fby + _fbz * _fbz);
			var _jt = min(_tl / _dent, mu * _j);
			vx += _tx * _jt * invm; vy += _ty * _jt * invm; vz += _tz * _jt * invm;
			wx += _bfa[0] * _jt; wy += _bfa[1] * _jt; wz += _bfa[2] * _jt;
			_s.vx -= _tx * _jt * _s.invm; _s.vy -= _ty * _jt * _s.invm; _s.vz -= _tz * _jt * _s.invm;
			_s.wx -= _s.invi * _jt * _fbx; _s.wy -= _s.invi * _jt * _fby; _s.wz -= _s.invi * _jt * _fbz;
		}
		sleeping = false;
		_s.sleeping = false;
		if (_j > .9 && stic <= 0) {
			stic = 4;
			play_sound_ext(snd_matclick2, 1.2 + random(.35), 1.7, clamp(.08 + _j * .06, .08, .3), 1);
		}
	}
};

/// @func __flip()
/// @desc the toss: straight up, hard, end over end about a random
///       horizontal axis (the tech demo's launch; the read is new)
__flip = function() {
	held = false;
	sleeping = false;
	flipping = true;
	vz = 5.4 + random(1.6);
	vx += random_range(-.7, .7);
	vy += random_range(-.7, .7);
	var _fa = random(360);
	var _fs = .40 + random(.2);
	wx = dcos(_fa) * _fs;
	wy = dsin(_fa) * _fs;
	wz = random_range(-.08, .08);
	g.coin.flips += 1;
	play_sound_ext(snd_cointoss, .95, 1.15, .5, 1);
};

/// @func __read()
/// @desc at rest after a flip: which face is up, said and tallied
__read = function() {
	if (!flipping) return;
	flipping = false;
	var _heads = (orient[8] > 0);
	var _c = g.coin;
	if (_heads) _c.heads += 1; else _c.tails += 1;
	var _side = _heads ? 1 : 2;
	if (_c.last == _side) _c.streak += 1; else _c.streak = 1;
	_c.last = _side;
	_c.best = max(_c.best, _c.streak);
	float_text(x, y - r - 6, _heads ? "heads" : "tails", _heads ? c_gold : rgb(226, 232, 240), fnt_outline);
	play_sound_ext(snd_softclick, 1.3, 1.5, .3, 1);
	save_mark_dirty();
};
