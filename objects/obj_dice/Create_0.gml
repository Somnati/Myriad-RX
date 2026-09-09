/// a REAL lil d6 on a top-down table: full rigid-body simulation.
/// the screen is the table (x/y), pz is height toward the camera; the
/// shader raycasts straight down so the face you read is the face
/// that's up. nothing about the motion is scripted anymore:
///  - contacts happen at the 8 corner spheres of the rounded cube
///    (the EXACT shape the shader draws), against 5 half-space planes:
///    the table and the four tray walls (half-spaces can't tunnel)
///  - every contact applies a restitution impulse plus a COULOMB
///    FRICTION impulse, both with full torque coupling and the cube's
///    isotropic inertia (a real property of cubes: I = m*s^2/6 about
///    ANY center axis) - so a sliding die catches, tips, tumbles,
///    slaps face after face and settles because the equations say so
///  - dice-dice contacts sample each die's 8 corners + 12 edge
///    midpoints against the OTHER die's rounded-box SDF (again: the
///    shader's exact function), two-body impulses, torque on both
///  - a micro-assist only acts inside ~10 degrees of flat so a die
///    can never balance on an edge, then it sleeps
///
/// input: press near a die to start a scoop - the hand only holds
/// what the cursor PASSES OVER (drag around to gather more), held
/// dice hover above the table, release throws the handful. a quick
/// tap hops the die under the cursor.
///
/// modular: no controller, drop obj_dice instances anywhere.

if (!variable_global_exists("dice_scoop")) g.dice_scoop = false;

// ⚖️ REBASED FROM THE TECH DEMO'S -700 (the port, 2026-09-09). That
// number was right in a room whose chrome sat at -750; in RX it puts
// the dice over the menu drawer (-520), over the settings and
// statistics overlays (-510), and inside the menu_blur layer's shadow
// at -500 - so a die would have rolled across an open settings page,
// unblurred, while the room behind it softened.
//
// 10 puts them exactly where a toy on the table belongs: ON the
// visualiser (obj_bignum5 sits at 50), UNDER every readout drawn on
// the glass (the per-tap and the clicker's tps both sit at 0) and
// under the header, the drawer and both overlays. Deeper than -500, so
// they blur with the room when the menu opens, which is the whole
// point of being part of the room. Shallower than the glow/blur/
// vignette FX layers at 20/30/40, which is the same treatment every
// other piece of room UI gets.
depth = 10;

// ---- shape (must match sh_dice) ----
r  = 11;       // half-extent, px
RD = .17;      // edge rounding fraction
rr   = RD * r; // rounding radius, px
core = r - rr; // rounded-box core half-extent
QP = 2;        // draw quad half-extent in half-extents
px_cell = 1;   // pixel-shader cell size in room px

// body from the house random-color roll; finish anywhere on the
// matte..metallic slide; pips flip to white when black would drown
tint  = color_set_random();
metal = random(1);
var _lum = (.299 * colour_get_red(tint) + .587 * colour_get_green(tint)
	+ .114 * colour_get_blue(tint)) / 255;
ink = (_lum < .42) ? [.94, .94, .97] : [.08, .08, .12];

// ---- rigid body ----
pz = r + 20 + irandom(20); // drops in from above the table
vx = 0; vy = 0; vz = 0;
wx = random_range(-.08, .08); // angular velocity, RADIANS/step,
wy = random_range(-.08, .08); // world-frame axis vector
wz = random_range(-.05, .05);
orient = mat3_mul(mat3_rot(1, 0, 0, irandom(359)), mat3_rot(0, 1, 0, irandom(359)));

invm = 1;                    // mass 1
invi = 1 / (2 * r * r / 3);  // solid cube: I = m*(2h)^2/6 = 2h^2/3,
                             // isotropic - no tensor rotation needed
grav = .34;  // pulls toward the table (down the z axis)
mu   = .45;  // coulomb friction coefficient
e_pl = .48;  // restitution vs table/walls
e_dd = .52;  // restitution dice-on-dice
sleeping = false;
bal_t = 0;   // edge-balance rescue timer
gr_n  = 0;   // grounded-corner count, from the plane pass
lean  = 0;   // frames since last dice-dice contact (piles may rest tilted)

// tray: the screen edges (and the header's underside where one exists)
xmin = 3; xmax = room_width - 3;
ymin = instance_exists(obj_ui_header) ? obj_ui_header.sprite_height + 2 : 3;
ymax = room_height - 3;

// contact samplers, object space: sphere centers of radius rr at the
// 8 corners then 12 edge midpoints - together they trace the whole
// rounded hull (corners handle planes; both sets handle dice-dice)
spts = [];
for (var _sx = -1; _sx <= 1; _sx += 2)
for (var _sy = -1; _sy <= 1; _sy += 2)
for (var _sz = -1; _sz <= 1; _sz += 2)
	array_push(spts, _sx * core, _sy * core, _sz * core);
for (var _sa = -1; _sa <= 1; _sa += 2)
for (var _sb = -1; _sb <= 1; _sb += 2) {
	array_push(spts, _sa * core, _sb * core, 0);
	array_push(spts, _sa * core, 0, _sb * core);
	array_push(spts, 0, _sa * core, _sb * core);
}
n_corner = 8;
n_spts = array_length(spts) div 3; // 20

// ---- scoop / hand ----
held = false;
scoop_r = 30;     // cursor gather radius
hover = r + 24;   // held dice float this high
ox = 0; oy = 0;   // this die's nook in the hand
thx = 0; thy = 0; // smoothed hand velocity = the throw
mpx = mousex; mpy = mousey;
stic = 0;         // impact-sound throttle

// ---- math ----

// rodrigues rotation, RADIANS, plain right-hand algebra - NOT
// mat3_rot (its screen-y angle flip would make the integrated
// orientation disagree with the cross products in the contact
// solver; self-consistency is what makes friction roll the die
// the right way, so physics gets its own constructor)
__rot = function(_ax, _ay, _az, _rad) {
	var _l = sqrt(_ax * _ax + _ay * _ay + _az * _az);
	if (_l <= 0) return [1, 0, 0, 0, 1, 0, 0, 0, 1];
	_ax /= _l; _ay /= _l; _az /= _l;
	var _c = cos(_rad);
	var _s = sin(_rad);
	var _t = 1 - _c;
	return [
		_t * _ax * _ax + _c,       _t * _ax * _ay - _s * _az, _t * _ax * _az + _s * _ay,
		_t * _ax * _ay + _s * _az, _t * _ay * _ay + _c,       _t * _ay * _az - _s * _ax,
		_t * _ax * _az - _s * _ay, _t * _ay * _az + _s * _ax, _t * _az * _az + _c,
	];
};

// gram-schmidt the columns back to orthonormal (integration shears)
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

// this die's rounded-box SDF, object space, px (the shader's function)
__sdf = function(_qx, _qy, _qz) {
	var _ax = abs(_qx) - core;
	var _ay = abs(_qy) - core;
	var _az = abs(_qz) - core;
	var _mx = max(_ax, 0);
	var _my = max(_ay, 0);
	var _mz = max(_az, 0);
	return sqrt(_mx * _mx + _my * _my + _mz * _mz)
		+ min(max(_ax, max(_ay, _az)), 0) - rr;
};

// shader handles
u_quad2  = shader_get_uniform(sh_dice, "u_quad");
u_or2    = shader_get_uniform(sh_dice, "u_or");
u_light2 = shader_get_uniform(sh_dice, "u_light");
u_col2   = shader_get_uniform(sh_dice, "u_col");
u_pad2   = shader_get_uniform(sh_dice, "u_pad");
u_cells2 = shader_get_uniform(sh_dice, "u_cells");
u_ink2   = shader_get_uniform(sh_dice, "u_ink");
u_metal2 = shader_get_uniform(sh_dice, "u_metal");

// impact clack, pitch/volume by impulse, throttled
__clack = function(_j) {
	if (_j < .9 || stic > 0) return;
	stic = 4;
	var _p = clamp(.55 + _j * .1, .5, 1.25);
	play_sound_ext(snd_matclick, _p, _p + .15, clamp(_j * .09, .08, .38), 1);
};

// one corner sphere vs one static half-space: restitution + coulomb
// friction impulses with torque, plus a soft positional correction.
// returns 1 when the corner is supporting (for the settle logic)
__contact = function(_cx, _cy, _cz, _nx, _ny, _nz, _pen, _e) {
	var _rx = (_cx - _nx * rr) - x;
	var _ry = (_cy - _ny * rr) - y;
	var _rz = (_cz - _nz * rr) - pz;
	var _vcx = vx + wy * _rz - wz * _ry;
	var _vcy = vy + wz * _rx - wx * _rz;
	var _vcz = vz + wx * _ry - wy * _rx;
	var _vn = _vcx * _nx + _vcy * _ny + _vcz * _nz;
	if (_vn < 0) {
		// low-speed restitution cutoff: rest, not chatter
		var _en = (_vn < -1.1) ? _e : 0;
		var _kx = _ry * _nz - _rz * _ny; // r x n
		var _ky = _rz * _nx - _rx * _nz;
		var _kz = _rx * _ny - _ry * _nx;
		var _j = -(1 + _en) * _vn / (invm + invi * (_kx * _kx + _ky * _ky + _kz * _kz));
		vx += _nx * _j * invm;
		vy += _ny * _j * invm;
		vz += _nz * _j * invm;
		wx += invi * _j * _kx;
		wy += invi * _j * _ky;
		wz += invi * _j * _kz;
		// friction: kill tangential contact motion, clamped to mu*j
		_vcx = vx + wy * _rz - wz * _ry;
		_vcy = vy + wz * _rx - wx * _rz;
		_vcz = vz + wx * _ry - wy * _rx;
		var _vn2 = _vcx * _nx + _vcy * _ny + _vcz * _nz;
		var _tx = _vcx - _nx * _vn2;
		var _ty = _vcy - _ny * _vn2;
		var _tz = _vcz - _nz * _vn2;
		var _tl = sqrt(_tx * _tx + _ty * _ty + _tz * _tz);
		if (_tl > .001) {
			_tx /= -_tl; _ty /= -_tl; _tz /= -_tl;
			var _fx = _ry * _tz - _rz * _ty; // r x t
			var _fy = _rz * _tx - _rx * _tz;
			var _fz = _rx * _ty - _ry * _tx;
			var _jt = _tl / (invm + invi * (_fx * _fx + _fy * _fy + _fz * _fz));
			_jt = min(_jt, mu * _j);
			vx += _tx * _jt * invm;
			vy += _ty * _jt * invm;
			vz += _tz * _jt * invm;
			wx += invi * _jt * _fx;
			wy += invi * _jt * _fy;
			wz += invi * _jt * _fz;
		}
		__clack(_j);
		return 1;
	}
	return 1; // penetrating = supporting even without an impulse
};

// all 8 corners against the 5 tray planes; returns floor supports.
// impulses are per corner, but the POSITION correction is applied
// once per plane at the deepest corner, past a small slop - per-
// corner pushes stacked up and launched the die a hair off the
// table every frame, where friction couldn't reach it (the slow
// endless slide). the slop keeps the contact alive frame to frame
__plane_pass = function() {
	var _sup = 0;
	var _pf = 0; var _pl = 0; var _pr = 0; var _pt = 0; var _pb = 0;
	for (var _i = 0; _i < n_corner; _i++) {
		var _ox3 = spts[_i * 3];
		var _oy3 = spts[_i * 3 + 1];
		var _oz3 = spts[_i * 3 + 2];
		var _cx = x  + orient[0] * _ox3 + orient[1] * _oy3 + orient[2] * _oz3;
		var _cy = y  + orient[3] * _ox3 + orient[4] * _oy3 + orient[5] * _oz3;
		var _cz = pz + orient[6] * _ox3 + orient[7] * _oy3 + orient[8] * _oz3;
		var _pen = rr - _cz;
		if (_pen > 0) { _sup += __contact(_cx, _cy, _cz, 0, 0, 1, _pen, e_pl); _pf = max(_pf, _pen); }
		_pen = rr - (_cx - xmin);
		if (_pen > 0) { __contact(_cx, _cy, _cz, 1, 0, 0, _pen, e_pl); _pl = max(_pl, _pen); }
		_pen = rr - (xmax - _cx);
		if (_pen > 0) { __contact(_cx, _cy, _cz, -1, 0, 0, _pen, e_pl); _pr = max(_pr, _pen); }
		_pen = rr - (_cy - ymin);
		if (_pen > 0) { __contact(_cx, _cy, _cz, 0, 1, 0, _pen, e_pl); _pt = max(_pt, _pen); }
		_pen = rr - (ymax - _cy);
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

// dice-on-dice, one direction: _s's sample spheres against MY rounded
// box. two-body impulses (restitution + friction), torque on both,
// positional split. normals come from MY SDF gradient - the exact
// surface the shader shows. the pair pass calls this both ways
__pair_dir = function(_s) {
	var _n = _s.n_spts;
	for (var _i = 0; _i < _n; _i++) {
		var _ox3 = _s.spts[_i * 3];
		var _oy3 = _s.spts[_i * 3 + 1];
		var _oz3 = _s.spts[_i * 3 + 2];
		// sampler sphere center: _s object -> world
		var _sxw = _s.x  + _s.orient[0] * _ox3 + _s.orient[1] * _oy3 + _s.orient[2] * _oz3;
		var _syw = _s.y  + _s.orient[3] * _ox3 + _s.orient[4] * _oy3 + _s.orient[5] * _oz3;
		var _szw = _s.pz + _s.orient[6] * _ox3 + _s.orient[7] * _oy3 + _s.orient[8] * _oz3;
		// world -> MY object space (columns dot = transpose)
		var _dx = _sxw - x;
		var _dy = _syw - y;
		var _dz = _szw - pz;
		var _qx = orient[0] * _dx + orient[3] * _dy + orient[6] * _dz;
		var _qy = orient[1] * _dx + orient[4] * _dy + orient[7] * _dz;
		var _qz = orient[2] * _dx + orient[5] * _dy + orient[8] * _dz;
		var _pen = _s.rr - __sdf(_qx, _qy, _qz);
		if (_pen <= 0) continue;
		lean = 4;   // touching another die: a tilted rest is legit
		_s.lean = 4;

		// my surface normal at the contact: tetrahedral SDF gradient
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
		// to world (points from me toward _s)
		var _nx = orient[0] * _lx + orient[1] * _ly + orient[2] * _lz;
		var _ny = orient[3] * _lx + orient[4] * _ly + orient[5] * _lz;
		var _nz = orient[6] * _lx + orient[7] * _ly + orient[8] * _lz;

		// contact point: the sampler sphere's surface toward me
		var _cx = _sxw - _nx * _s.rr;
		var _cy = _syw - _ny * _s.rr;
		var _cz = _szw - _nz * _s.rr;
		var _rax = _cx - x;      // me = A
		var _ray = _cy - y;
		var _raz = _cz - pz;
		var _rbx = _cx - _s.x;   // _s = B
		var _rby = _cy - _s.y;
		var _rbz = _cz - _s.pz;

		// positional split
		x  -= _nx * _pen * .32;  y  -= _ny * _pen * .32;  pz -= _nz * _pen * .32;
		_s.x += _nx * _pen * .32; _s.y += _ny * _pen * .32; _s.pz += _nz * _pen * .32;

		// relative contact velocity (B minus A), along n
		var _vax = vx + wy * _raz - wz * _ray;
		var _vay = vy + wz * _rax - wx * _raz;
		var _vaz = vz + wx * _ray - wy * _rax;
		var _vbx = _s.vx + _s.wy * _rbz - _s.wz * _rby;
		var _vby = _s.vy + _s.wz * _rbx - _s.wx * _rbz;
		var _vbz = _s.vz + _s.wx * _rby - _s.wy * _rbx;
		var _vrx = _vbx - _vax;
		var _vry = _vby - _vay;
		var _vrz = _vbz - _vaz;
		var _vn = _vrx * _nx + _vry * _ny + _vrz * _nz;
		if (_vn >= 0) continue; // separating

		var _en = (_vn < -1.1) ? e_dd : 0;
		var _kax = _ray * _nz - _raz * _ny; // ra x n
		var _kay = _raz * _nx - _rax * _nz;
		var _kaz = _rax * _ny - _ray * _nx;
		var _kbx = _rby * _nz - _rbz * _ny; // rb x n
		var _kby = _rbz * _nx - _rbx * _nz;
		var _kbz = _rbx * _ny - _rby * _nx;
		var _den = invm + _s.invm
			+ invi * (_kax * _kax + _kay * _kay + _kaz * _kaz)
			+ _s.invi * (_kbx * _kbx + _kby * _kby + _kbz * _kbz);
		var _j = -(1 + _en) * _vn / _den;
		vx -= _nx * _j * invm;    vy -= _ny * _j * invm;    vz -= _nz * _j * invm;
		wx -= invi * _j * _kax;   wy -= invi * _j * _kay;   wz -= invi * _j * _kaz;
		_s.vx += _nx * _j * _s.invm; _s.vy += _ny * _j * _s.invm; _s.vz += _nz * _j * _s.invm;
		_s.wx += _s.invi * _j * _kbx; _s.wy += _s.invi * _j * _kby; _s.wz += _s.invi * _j * _kbz;

		// friction on the tangential slip, clamped to the cone
		_vax = vx + wy * _raz - wz * _ray;
		_vay = vy + wz * _rax - wx * _raz;
		_vaz = vz + wx * _ray - wy * _rax;
		_vbx = _s.vx + _s.wy * _rbz - _s.wz * _rby;
		_vby = _s.vy + _s.wz * _rbx - _s.wx * _rbz;
		_vbz = _s.vz + _s.wx * _rby - _s.wy * _rbx;
		_vrx = _vbx - _vax;
		_vry = _vby - _vay;
		_vrz = _vbz - _vaz;
		var _vn2 = _vrx * _nx + _vry * _ny + _vrz * _nz;
		var _tx = _vrx - _nx * _vn2;
		var _ty = _vry - _ny * _vn2;
		var _tz = _vrz - _nz * _vn2;
		var _tl = sqrt(_tx * _tx + _ty * _ty + _tz * _tz);
		if (_tl > .001) {
			_tx /= _tl; _ty /= _tl; _tz /= _tl;
			var _fax = _ray * _tz - _raz * _ty;
			var _fay = _raz * _tx - _rax * _tz;
			var _faz = _rax * _ty - _ray * _tx;
			var _fbx = _rby * _tz - _rbz * _ty;
			var _fby = _rbz * _tx - _rbx * _tz;
			var _fbz = _rbx * _ty - _rby * _tx;
			var _dent = invm + _s.invm
				+ invi * (_fax * _fax + _fay * _fay + _faz * _faz)
				+ _s.invi * (_fbx * _fbx + _fby * _fby + _fbz * _fbz);
			var _jt = min(_tl / _dent, mu * _j);
			vx += _tx * _jt * invm;    vy += _ty * _jt * invm;    vz += _tz * _jt * invm;
			wx += invi * _jt * _fax;   wy += invi * _jt * _fay;   wz += invi * _jt * _faz;
			_s.vx -= _tx * _jt * _s.invm; _s.vy -= _ty * _jt * _s.invm; _s.vz -= _tz * _jt * _s.invm;
			_s.wx -= _s.invi * _jt * _fbx; _s.wy -= _s.invi * _jt * _fby; _s.wz -= _s.invi * _jt * _fbz;
		}

		sleeping = false;
		_s.sleeping = false;
		if (_j > .9 && stic <= 0) {
			stic = 4;
			play_sound_ext(snd_matclick2, 1.05 + random(.35), 1.5, clamp(.08 + _j * .06, .08, .3), 1);
		}
	}
};
