visible = unfold_has("coin");   // (the unfold: an objective's reward)
if (!visible) exit;
stic -= delta;
lean -= delta;

// ================= grab =================
// a press near the coin takes it (arbitrated region pattern; obj_clicker
// asks the same question so a press is never both a grab and a tap)
if (input_free())
if (!variable_global_exists("click_owner") || g.click_owner == noone)
if (!held && mouse_check_button_pressed(mb_left))
if (point_distance(mousex, mousey, x, y) < scoop_r) {
	held = true;
	g.coin_scoop = true;
	sleeping = false;
	thx = 0; thy = 0;
	// waking whatever leans on it
	var _jid = id;
	with (obj_dice) if (point_distance(x, y, _jid.x, _jid.y) < (r + _jid.r) * 1.6) sleeping = false;
	play_sound_ext(snd_softclick, 1.2, 1.4, .25, 1);
}

var _mdx = mousex - mpx;
var _mdy = mousey - mpy;
mpx = mousex; mpy = mousey;

// ================= in the hand =================
if (held) {
	var _tx = clamp(mousex, xmin + r, xmax - r);
	var _ty = clamp(mousey, ymin + r, ymax - r);
	vx = (vx + (_tx - x) * .3 * delta) * power(.68, delta);
	vy = (vy + (_ty - y) * .3 * delta) * power(.68, delta);
	vz = (vz + (hover - pz) * .3 * delta) * power(.6, delta);
	x += vx * delta;
	y += vy * delta;
	pz += vz * delta;
	thx = lerp(thx, _mdx, .45);
	thy = lerp(thy, _mdy, .45);
	if (!mouse_check_button(mb_left)) {
		held = false;
		g.coin_scoop = false;
		if (touch_time < 13 && touch_dragdist < 8) __flip();
		else {
			var _pw = point_distance(0, 0, thx, thy);
			if (_pw > 13) { thx *= 13 / _pw; thy *= 13 / _pw; _pw = 13; }
			vx = thx * 1.05;
			vy = thy * 1.05;
			vz = .7 + min(_pw * .12, 1.5);
			if (_pw > .5) {
				wx = (-thy / _pw) * (_pw / r) * .8;
				wy = (thx / _pw) * (_pw / r) * .8;
			}
			wz = random_range(-.15, .15);
			flipping = true;   // a throw lands on a face too - read it
			play_sound_ext(snd_matclick, .9, 1.1, .3, 1);
		}
	}
}
// ================= free body =================
else if (!sleeping) {
	vz -= grav * delta;
	x += vx * delta;
	y += vy * delta;
	pz += vz * delta;
	gr_n = __plane_pass();
	gr_n = max(gr_n, __plane_pass());
	if (gr_n > 0) {
		var _s2 = vx * vx + vy * vy;
		if (_s2 < 2.25) {
			var _gd = power(lerp(.87, .97, _s2 / 2.25), delta);
			vx *= _gd; vy *= _gd;
			// a coin's spin about its axle dies slower than its wobble
			wx *= power(.985, delta); wy *= power(.985, delta); wz *= _gd;
		}
	}
}

// ================= tumble integration =================
if (!sleeping) {
	var _wl = sqrt(wx * wx + wy * wy + wz * wz);
	if (_wl > .7) { wx *= .7 / _wl; wy *= .7 / _wl; wz *= .7 / _wl; _wl = .7; }
	if (_wl > .0004) {
		orient = mat3_mul(__rot(wx / _wl, wy / _wl, wz / _wl, _wl * delta), orient);
		orient = __ortho(orient);
	}
	var _sl = sqrt(vx * vx + vy * vy + vz * vz);
	if (_sl > 13) { vx *= 13 / _sl; vy *= 13 / _sl; vz *= 13 / _sl; }
}

// ================= coin on dice =================
// the coin hosts its pairs with every die: both directions of sampling
var _me = id;
with (obj_dice) {
	if (!visible) continue;
	if (sleeping && _me.sleeping) continue;
	var _ddx = x - _me.x, _ddy = y - _me.y, _ddz = pz - _me.pz;
	var _rng = (r + _me.r) * 1.8;
	if (_ddx * _ddx + _ddy * _ddy + _ddz * _ddz > _rng * _rng) continue;
	_me.__pair_dir(id);   // the die's samples vs the coin's hull
	__pair_dir(_me);      // the coin's samples vs the die's box
}

// ================= settle & sleep =================
// the assist only flattens the near-flat face down (never yaw); a coin
// propped on a die may rest tilted; a coin stalled on its edge with
// nothing under it is tipped
if (!held && !sleeping) {
	var _sp2 = vx * vx + vy * vy + vz * vz;
	var _wl2 = wx * wx + wy * wy + wz * wz;
	if (gr_n > 0 && _sp2 < .09 && _wl2 < .004) {
		var _sgn = (orient[8] >= 0) ? 1 : -1;
		var _ux = orient[2] * _sgn, _uy = orient[5] * _sgn, _uz = orient[8] * _sgn;
		if (_uz > .96) {
			var _ang = arccos(clamp(_uz, -1, 1));
			if (_ang > .0005) {
				var _amt = min(_ang, _ang * .22 * delta + .002);
				orient = mat3_mul(__rot(_uy, -_ux, 0, _amt), orient);
				orient = __ortho(orient);
			}
			wx *= power(.7, delta); wy *= power(.7, delta); wz *= power(.7, delta);
			if (_ang < .012 && _sp2 < .004) {
				orient = mat3_mul(__rot(_uy, -_ux, 0, _ang), orient);
				orient = __ortho(orient);
				vx = 0; vy = 0; vz = 0; wx = 0; wy = 0; wz = 0;
				pz = ct;
				sleeping = true;
				bal_t = 0;
				__read();
			}
		}
		else if (lean > 0) {
			if (_sp2 < .004 && _wl2 < .0004) {
				vx = 0; vy = 0; vz = 0; wx = 0; wy = 0; wz = 0;
				sleeping = true;
				bal_t = 0;
				__read();
			}
		}
		else {
			bal_t += delta;
			if (bal_t > 10) {
				bal_t = 0;
				wx += random_range(-.05, .05);
				wy += random_range(-.05, .05);
			}
		}
	}
	else bal_t = 0;
}

depth = 10 - pz * .05;
