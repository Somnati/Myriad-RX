
stic -= delta;
lean -= delta;

// ================= scoop input =================
// press near a die starts the scoop (arbitrated region pattern)
if (input_free())
if (!variable_global_exists("click_owner") || g.click_owner == noone)
if (mouse_check_button_pressed(mb_left))
if (point_distance(mousex, mousey, x, y) < scoop_r)
	g.dice_scoop = true;

// the hand only holds what the cursor passes over: while the button
// is down, any die inside the scoop radius joins - drag to gather
if (g.dice_scoop && !held)
if (point_distance(mousex, mousey, x, y) < scoop_r) {
	held = true;
	sleeping = false;
	// nook: a golden-angle rosette slot by join order - first die
	// rides the cursor, the rest ring around it without overlapping
	// targets (the pair contacts handle the rest of the spacing)
	var _hn = 0;
	with (obj_dice) if (held && id != other.id) _hn++;
	if (_hn == 0) { ox = 0; oy = 0; }
	else {
		var _ring = 1 + ((_hn - 1) div 6);
		var _ang = _hn * 137.5;
		ox = dcos(_ang) * r * 1.9 * _ring;
		oy = -dsin(_ang) * r * 1.9 * _ring;
	}
	thx = 0; thy = 0;
	// grabbing out of a pile wakes whatever was leaning on this die
	var _jid = id;
	with (obj_dice) if (id != _jid)
	if (point_distance(x, y, _jid.x, _jid.y) < r * 3.2) sleeping = false;
	play_sound_ext(snd_softclick, 1.1, 1.3, .25, 1);
}

// own mouse-velocity tracker (step-order safe)
var _mdx = mousex - mpx;
var _mdy = mousey - mpy;
mpx = mousex; mpy = mousey;

// ================= in the hand =================
if (held) {
	// hover above the table, nested in this die's nook
	var _tx = clamp(mousex + ox, xmin + r, xmax - r);
	var _ty = clamp(mousey + oy, ymin + r, ymax - r);
	vx = (vx + (_tx - x) * .26 * delta) * power(.7, delta);
	vy = (vy + (_ty - y) * .26 * delta) * power(.7, delta);
	vz = (vz + (hover - pz) * .3 * delta) * power(.6, delta);
	x += vx * delta;
	y += vy * delta;
	pz += vz * delta;

	// smoothed hand velocity: this IS the throw
	thx = lerp(thx, _mdx, .45);
	thy = lerp(thy, _mdy, .45);

	// shaking agitates the handful (the pair contacts make it clack)
	var _ag = point_distance(0, 0, _mdx, _mdy);
	if (_ag > 3) {
		wx += random_range(-1, 1) * _ag * .012;
		wy += random_range(-1, 1) * _ag * .012;
		wz += random_range(-1, 1) * _ag * .012;
	}

	// release: quick tap = hop, a real drag = THROW across the table
	if (!mouse_check_button(mb_left)) {
		held = false;
		g.dice_scoop = false;
		if (touch_time < 13 && touch_dragdist < 8) {
			vz = 3.6 + random(1.4);
			vx += random_range(-1, 1);
			vy += random_range(-1, 1);
			wx = random_range(-.3, .3);
			wy = random_range(-.3, .3);
			wz = random_range(-.3, .3);
			play_sound_ext(snd_matclick, 1.15, 1.45, .3, 1);
		}
		else {
			var _pw = point_distance(0, 0, thx, thy);
			if (_pw > 13) { thx *= 13 / _pw; thy *= 13 / _pw; _pw = 13; }
			vx = thx * 1.05 + random_range(-.6, .6);
			vy = thy * 1.05 + random_range(-.6, .6);
			vz = .8 + min(_pw * .12, 1.6); // a little launch arc
			// initial tumble FORWARD over the travel axis (friction
			// will keep it honest once it lands)
			if (_pw > .5) {
				var _tum = (_pw / r) * random_range(.6, 1.1);
				wx = (-thy / _pw) * _tum;
				wy = (thx / _pw) * _tum;
			}
			wz = random_range(-.2, .2);
			play_sound_ext(snd_matclick, .7, .9, .35, 1);
		}
	}
}
// ================= free body =================
else if (!sleeping) {
	vz -= grav * delta;
	x += vx * delta;
	y += vy * delta;
	pz += vz * delta;

	// contacts: two solver iterations settle multi-corner landings
	gr_n = __plane_pass();
	gr_n = max(gr_n, __plane_pass());

	// rolling resistance: pure impulse friction converts slide<->spin
	// forever at micro speeds instead of absorbing it (the classic
	// creep), so once grounded and slow the felt just eats the rest
	if (gr_n > 0) {
		var _s2 = vx * vx + vy * vy;
		if (_s2 < 2.25) { // under 1.5 px/step
			var _gd = power(lerp(.86, .97, _s2 / 2.25), delta);
			vx *= _gd; vy *= _gd;
			wx *= _gd; wy *= _gd; wz *= _gd;
		}
	}
}

// ================= tumble integration =================
if (!sleeping) {
	var _wl = sqrt(wx * wx + wy * wy + wz * wz);
	if (_wl > .6) { // cap spin (also guards the integrator)
		wx *= .6 / _wl; wy *= .6 / _wl; wz *= .6 / _wl;
		_wl = .6;
	}
	if (_wl > .0004) {
		orient = mat3_mul(__rot(wx / _wl, wy / _wl, wz / _wl, _wl * delta), orient);
		orient = __ortho(orient);
	}
	var _sl = sqrt(vx * vx + vy * vy + vz * vz);
	if (_sl > 13) { vx *= 13 / _sl; vy *= 13 / _sl; vz *= 13 / _sl; }
}

// ================= dice on dice =================
// both directions of SDF sampling per pair, resolved once (lower id
// hosts). runs even while sleeping so a thrown die can wake this one
var _me = id;
with (obj_dice) if (id > _me) {
	if (sleeping && _me.sleeping) continue;
	var _ddx = x - _me.x;
	var _ddy = y - _me.y;
	var _ddz = pz - _me.pz;
	var _rng = (r + _me.r) * 1.8;
	if (_ddx * _ddx + _ddy * _ddy + _ddz * _ddz > _rng * _rng) continue;
	_me.__pair_dir(id);   // my samples vs _me's box
	__pair_dir(_me);      // _me's samples vs my box
}

// ================= settle & sleep =================
// natural physics does the tipping and the face-slaps. the assist
// ONLY rotates the nearly-flat up face down onto the table (gravity's
// last word) - yaw is never touched, so the die keeps whatever
// heading it landed with, like real dice. tilted dice propped on
// other dice are a valid rest (a pile); only an unsupported edge
// balance gets tipped over
if (!held && !sleeping) {
	var _sp2 = vx * vx + vy * vy + vz * vz;
	var _wl2 = wx * wx + wy * wy + wz * wz;
	if (gr_n > 0 && _sp2 < .09 && _wl2 < .004) {
		// which object axis points up, and how far off flat?
		var _k = 0;
		if (abs(orient[7]) > abs(orient[6 + _k])) _k = 1;
		if (abs(orient[8]) > abs(orient[6 + _k])) _k = 2;
		var _sgn = (orient[6 + _k] >= 0) ? 1 : -1;
		var _ux = orient[_k] * _sgn;
		var _uy = orient[3 + _k] * _sgn;
		var _uz = orient[6 + _k] * _sgn; // cos of the tilt
		if (_uz > .978) {
			// inside ~12 deg of flat: ease the up face onto vertical
			// about the horizontal axis (up x world-up) - pure flatten
			var _ang = arccos(clamp(_uz, -1, 1));
			if (_ang > .0005) {
				var _amt = min(_ang, _ang * .2 * delta + .002);
				orient = mat3_mul(__rot(_uy, -_ux, 0, _amt), orient);
				orient = __ortho(orient);
			}
			wx *= power(.7, delta);
			wy *= power(.7, delta);
			wz *= power(.7, delta);
			if (_ang < .012 && _sp2 < .004) {
				orient = mat3_mul(__rot(_uy, -_ux, 0, _ang), orient);
				orient = __ortho(orient);
				vx = 0; vy = 0; vz = 0;
				wx = 0; wy = 0; wz = 0;
				pz = r;
				sleeping = true;
				bal_t = 0;
			}
		}
		else if (lean > 0) {
			// tilted but touching another die: piles rest as they lie
			if (_sp2 < .004 && _wl2 < .0004) {
				vx = 0; vy = 0; vz = 0;
				wx = 0; wy = 0; wz = 0;
				sleeping = true;
				bal_t = 0;
			}
		}
		else {
			// stalled on an edge with nothing propping it - tip over
			bal_t += delta;
			if (bal_t > 14) {
				bal_t = 0;
				wx += random_range(-.06, .06);
				wy += random_range(-.06, .06);
			}
		}
	}
	else bal_t = 0;
}

// higher dice draw over lower ones (held hand floats above the table).
// Base rebased for RX's depth stack - see the Create.
depth = 10 - pz * .05;
