/// the puck's state machine. Five states, and they are named by flags
/// exactly as DE named them, because the transitions genuinely overlap:
///
///   resting   spd == 0, nobody holding
///   held      the pointer owns it, chasing the cursor
///   docked    held AND locked to a magnet (there is one - the cannon)
///   cannon    that magnet, armed: aiming
///   flying    spd > 0, bouncing off the tray
///
/// Order matters here: sparks decay, then input, then the follow, then
/// the flight. Reading input before moving is what keeps a release from
/// launching with last frame's aim.

// the material rides the settings pick live (the dice's arrangement)
visible = unfold_has("puck");   // (the unfold: the chain's graduation; invisible = no draw, and syst_input never hands it a press)
if (!visible) exit;
if (variable_global_exists("puck_mat") && g.puck_mat != mat_id) __mat_apply();

// ---- sparks: age, then compact ----
// backwards so removal cannot skip the next entry
for (var _i = array_length(sparks) - 1; _i >= 0; _i--) {
	var _s = sparks[_i];
	_s.l -= delta;
	if (_s.l <= 0) { array_delete(sparks, _i, 1); continue; }
	_s.x += lengthdir_x(_s.s * delta, _s.d);
	_s.y += lengthdir_y(_s.s * delta, _s.d);
	_s.s *= power(.90, delta);
}

stun = max(0, stun - delta);
if (cannon) cannon_t += delta; else cannon_t = 0;

// ⚖️ THE SPIN IS WHAT SELLS THE SOLID. A dark cylinder rotating about
// its own axis is invisibly rotating - it is the shader's knurled edge
// that turns yaw into something the eye can see, and it is the spin
// that turns the knurl from a texture into motion. Neither is worth
// much without the other.
//
// It decays on its own clock rather than riding the puck's friction:
// a puck that stops sliding is still spinning for a moment afterwards,
// and that half-second of residual rotation is most of what makes it
// read as a heavy object coming to rest rather than a sprite stopping.
yaw += yaw_spd * delta;
if (yaw >= 360 || yaw < 0) yaw -= 360 * floor(yaw / 360);
yaw_spd *= power(.985, delta);
if (abs(yaw_spd) < .02) yaw_spd = 0;

var _t   = __tray();
var _max = max(room_width, room_height);   // the speed scale, DE's _mxspd

// ---- the tint ----
// red while stunned, aqua while docked, its own colour otherwise. Three
// states you can read without looking at anything but the puck.
var _want = col;
if (docked) _want = c_aqua;
if (stun > 0) _want = c_hred;
tint = merge_colour(tint, _want, .45);

// ==================== GRAB ====================
// mouse_over() is arbitrated - obj_puck is a syst_input family member,
// so a press the menu or a widget already owns can never reach here.
if (!held)
if (input_free())
if (mouse_over())
if (mouse_check_button_pressed(mb_left)) {
	held = true;
	sl_ang = point_direction(__cx(), __cy(), mousex, mousey);   // the sling's sweep starts here
	sl_sum = 0; sl_charge = 0;
	hvx = 0; hvy = 0;   // the tether starts slack (a catch stops it dead, below)

	// ⚖️ THE CATCH BONUS (DE's, and the best thing in the whole toy):
	// grabbing it MID-FLIGHT pays PUCK_CATCH times a bounce. Snatching a
	// fast puck out of the air is the highest-skill thing in the game
	// and it is the one moment that rewards it. It also gives a good
	// player a reason to interrupt a throw rather than watch it die.
	if (spd > 0) {
		puck_pay(spd / _max, PUCK_CATCH, __cx(), __cy());
		__burst(14, 360, 3.2);
	}

	spd = 0;
	bounces = 0;
	peak = 0;
	resist = 0;
	cur_profit = 0;   // a new throw starts its ledger fresh (the tracker has faded by then)
	docked = false;
	cannon = false;
	__roll_voice();
	__grip();
	gx = x; gy = y;
	play_sound_ext(snd_softclick, 1.05, 1.25, .3, 1);
	__burst(10, 360, 1.8);
}

// ==================== HELD ====================
if (held) {
	__grip();
	var _px = mousex - grip_x;    // where the pointer wants the top-left
	var _py = mousey - grip_y;
	var _reach = point_distance(__cx(), __cy(), mousex, mousey);

	// ---- the dock ----
	// A list of one (see __docks for why), but it stays a list: the
	// loop is four lines, and the day a second magnet earns its place
	// it is a row in that function rather than a rewrite here.
	var _dk = __docks();
	var _dki = -1;
	for (var _i = 0; _i < array_length(_dk); _i++) {
		var _dc = _dk[_i];
		if (point_distance(clamp(mousex, _t.x1, room_width),
			clamp(mousey, _t.y1, room_height),
			_dc.x + r, _dc.y + r) < _dc.r) _dki = _i;
	}

	if (_dki >= 0) {
		var _o = _dk[_dki];
		_px = _o.x;
		_py = _o.y;
		// ⚖️ THE DOCK ONLY SPEAKS ONCE. DE gates the snap sound on the
		// puck being further than a threshold from the dock it is
		// entering - without it, sitting in a corner re-triggers the
		// sound every frame the cursor jitters. PUCK_SNAP_R is that
		// threshold, and it is why docking is an event rather than a
		// noise.
		if (!docked && point_distance(x, y, _o.x, _o.y) > PUCK_SNAP_R) {
			play_sound_ext(_o.snd, .85, 1.15, .5, 1);
			if (_o.cannon) __burst(16, 360, 2.6);
		}
		docked = true;
		cannon = _o.cannon;
	} else {
		docked = false;
		cannon = false;
	}

	// ---- the aim, while the cannon is armed ----
	if (cannon) {
		dir = point_direction(__cx(), __cy(), mousex, mousey);
		aim = _reach;
		// the reach is an ELLIPSE, not a circle (DE's _ra_len): pulling
		// straight down has more range than pulling sideways, because
		// the room is wider than it is tall in one shape and taller
		// than it is wide in the other. Without this the tiers are
		// trivially easy on the long axis and unreachable on the short.
		var _rl = lerp(room_width * .5, room_height, abs(dsin(dir))) * .8;
		var _pull = clamp(aim / max(1, _rl), 0, 1);
		tier = min(PUCK_TIERS, floor(_pull * (PUCK_TIERS + 1)));
		// the puck leans into the shot rather than sitting square
		_px += lengthdir_x(aim * .1, dir);
		_py += lengthdir_y(aim * .1, dir);
	} else {
		aim = 0;
		tier = 0;
	}

	// ---- THE HELD MASS ----
	// ⚖️ THE WHOLE SENSATION OF WEIGHT IS HERE. The puck never snaps
	// to the cursor and - since 2026-09-10 - never merely lags it
	// either: it is a MASS on a SPRING to the pointer's target, with
	// its own velocity. Move the hand and the puck takes a moment to
	// get going, overshoots a touch when the hand stops, and swings out
	// wide when the hand circles - momentum, which a lag can't fake
	// (the old trickle-with-a-distance-scaled-rate could stretch, but
	// it could never pass the hand). PUCK_HOLD_K is the spring and the
	// weight knob; PUCK_HOLD_DAMP keeps it from ringing forever.
	//
	// The cannon and the docks keep the old trickle: a magnet that
	// swings is not a magnet. The cannon locks in hard for the first
	// PUCK_CANNON_LOCK frames (arming feels decisive) then goes very
	// slow (aiming feels deliberate).
	var _gx0 = gx, _gy0 = gy;
	if (cannon || docked) {
		var _adj = cannon ? ((cannon_t < PUCK_CANNON_LOCK) ? 1.5 : PUCK_FOLLOW * 2.5) : 1.5;
		gx = trickle(gx, _px, _adj);
		gy = trickle(gy, _py, _adj);
		hvx = 0; hvy = 0;
	} else {
		// semi-implicit euler on the spring: the pull this frame joins
		// the velocity first, then the velocity moves the puck - stable
		// at every frame rate the game runs at, and delta keeps the
		// feel the same at 144 as at 60
		hvx += (_px - gx) * PUCK_HOLD_K * delta;
		hvy += (_py - gy) * PUCK_HOLD_K * delta;
		var _dk = power(PUCK_HOLD_DAMP, delta);
		hvx *= _dk; hvy *= _dk;
		gx += hvx * delta;
		gy += hvy * delta;
		// the tray's walls hold a swung puck the way they hold a thrown
		// one: it stops at the wall and the speed INTO it is lost (no
		// bounce while held - the hand has it)
		if (gx < _t.x1) { gx = _t.x1; hvx = max(0, hvx); }
		if (gx > _t.x2) { gx = _t.x2; hvx = min(0, hvx); }
		if (gy < _t.y1) { gy = _t.y1; hvy = max(0, hvy); }
		if (gy > _t.y2) { gy = _t.y2; hvy = min(0, hvy); }
	}
	x = clamp(gx, _t.x1, _t.x2);
	y = clamp(gy, _t.y1, _t.y2);
	// the hand rides the puck (settings > input; obj_cursor draws the
	// arrow at the grip point, which lags the real pointer with the puck)
	g.cursor_ride = (variable_global_exists("puck_hand") && g.puck_hand)
		? { x : x + grip_x, y : y + grip_y, owner : id } : undefined;

	// ---- THE SLING'S SWEEP (see the Create) ----
	// the pointer's angle about the puck this frame against last;
	// weighted by reach so a tight twitch is not a swing, and the sum
	// forgets fast so it is about the swing you are making NOW
	var _a = point_direction(__cx(), __cy(), mousex, mousey);
	var _da = angle_difference(_a, sl_ang) * clamp((_reach - 6) / 18, 0, 1);
	sl_ang = _a;
	if (abs(_da) < 60) sl_sum += _da;            // (a jump through the centre is not a sweep)
	sl_sum *= power(.92, delta);
	sl_vx = gx - _gx0; sl_vy = gy - _gy0;   // the puck's own travel this frame (the tangent)
	sl_charge = trickle(sl_charge, clamp(abs(sl_sum) / 360, 0, 2), 3, 0);

	// ==================== RELEASE ====================
	if (!mouse_check_button(mb_left)) {
		held = false;
		g.cursor_ride = undefined;   // the hand lets go: the arrow is the pointer again
		var _launch = cannon;
		was_cannon = _launch;

		// ⚖️ NO `!docked` HERE ANY MORE. That condition is what ate his
		// throws: docked and not the cannon meant the release did
		// nothing at all. With the cannon as the only dock, docked
		// IMPLIES _launch and the test could not fail - so rather than
		// leave a condition that is true by construction and will read
		// as load-bearing to whoever finds it next, it is gone.
		if (_reach > PUCK_MIN_PULL) {
			dir = point_direction(__cx(), __cy(), mousex, mousey);
			// speed from pull length, with a mild bonus for long pulls -
			// DE's _band term, which stops a full-screen drag from being
			// exactly twice a half-screen one
			spd = _reach * lerp(1, 1.35, clamp(_reach / _max, 0, 1));
			resist = PUCK_RESIST + (abi_on("ad_th_bounce1") ? 7 : 0);   // bounce+ (DE's deck, 2026-09-13)

			// ---- THE SLING RELEASE (see the Create) ----
			// a swing worth a third of a turn or more is a sling: the
			// speed climbs with the loops banked (x2.6 at two), the
			// combo with them, and the puck leaves along its own
			// travel - the tangent - if it was moving at all. And the
			// puck's REAL speed at the moment of release counts too:
			// a mass swung wide and let go carries what it had (the
			// tether's velocity, in px/frame, scaled up to the throw's
			// units) - so the same loops released at the fast point of
			// the swing fly harder than at the slow point
			var _loops = clamp(abs(sl_sum) / 360, 0, 2);
			if (_loops > .33) {
				spd *= 1 + .8 * _loops;
				spd = max(spd, point_distance(0, 0, hvx, hvy) * 9);
				resist += round(_loops * 2);
				if (point_distance(0, 0, sl_vx, sl_vy) > 1.5)
					dir = point_direction(0, 0, sl_vx, sl_vy);
				// the spin follows the swing's own sense
				yaw_spd = (spd / max(1, _max)) * PUCK_SPIN * 1.4 * sign(sl_sum);
				play_sound_ext(voice, lerp(1.1, 1.6, _loops * .5), lerp(1.3, 2, _loops * .5), .5, 1);
				__burst(round(6 + 8 * _loops), 60, 3 + _loops);
			}
			sl_sum = 0;

			if (_launch) {
				// the cannon multiplies by tier, and buys combo with it:
				// a stronger shot is also a LONGER one, which is what
				// makes charging worth the wait rather than just louder
				spd *= 1 + PUCK_TIER_SPD * (tier + 1);
				resist += PUCK_TIER_RESIST * tier;
				yaw_spd *= 1.6;   // a cannon shot leaves spinning hard
				y = _t.y2;
				play_sound_ext(snd_tierup, .9, 1.1, 0.125, 2);
				__burst(20, 120, 4.2);
			} else {
				play_sound_ext(snd_softclick, .9, 1.1, .35, 1);
			}

			// SPIN FROM THE THROW, signed by which way the release
			// crossed the puck. A flick that passes to the left of the
			// centre spins it one way and to the right the other, which
			// is what a real wrist does - and it means two throws down
			// the same line can still look different.
			var _cross = dsin(point_direction(__cx(), __cy(), mousex, mousey)
				- point_direction(gx + r, gy + r, __cx(), __cy()));
			if (_loops <= .33)   // (a sling set its own spin above)
			yaw_spd = (spd / max(1, _max)) * PUCK_SPIN
				* ((_cross == 0) ? choose(-1, 1) : sign(_cross))
				* random_range(.6, 1.4);

			resist0 = max(1, resist);
			stun = 0;
		}
		docked = false;
		cannon = false;
		tier = 0;
		aim = 0;
	}
}

// ==================== FLYING ====================
if (!held && spd > 0) {
	peak = max(peak, spd);

	// ---- move, then resolve ----
	// One step, then test: a swept solve would be more correct and this
	// is a disc in a box at a few hundred px/s, where the only symptom
	// of not sweeping is a bounce resolving a pixel late.
	x += lengthdir_x(spd * delta, dir);
	y += lengthdir_y(spd * delta, dir);

	// ---- the bounce ----
	// ONE rect (see __tray). DE tested the far edge on two walls and the
	// near edge on the other two while clamping to a third rectangle,
	// which let the puck hang half off the right and bottom.
	// ⚖️ STRICTLY OUTSIDE, not "at or outside". With <= the puck clamped
	// exactly onto a wall still tests true the next frame, and a slow
	// throw dying in a corner would bounce - and pay - forever. Strict
	// inequalities make the clamp itself the thing that ends it.
	var _wall = false;
	// THE CONTACT POINT (his ask, 2026-09-10: the tap effects belong on
	// the side that hit the wall, not the centre): the rim on the wall's
	// side - both sides in a corner
	var _hx = 0, _hy = 0;
	if (x < _t.x1) { dir = 180 - dir; _wall = true; _hx = -r; }
	else if (x > _t.x2) { dir = 180 - dir; _wall = true; _hx = r; }
	if (y < _t.y1) { dir = 360 - dir; _wall = true; _hy = -r; }
	else if (y > _t.y2) { dir = 360 - dir; _wall = true; _hy = r; }

	if (_wall) {
		x = clamp(x, _t.x1, _t.x2);
		y = clamp(y, _t.y1, _t.y2);
		bounces++;

		// ⚖️ THE PAYOUT HAPPENS AT IMPACT SPEED, before restitution
		// takes its cut. The number you are paid is the number you can
		// see coming - a bounce that LOOKS fast pays fast. It pays FROM
		// THE POINT OF CONTACT: the float, the motes and the tap effect
		// all leave the rim where it struck.
		var _frac = clamp(spd / _max, 0, 1);
		// THE DECK (DE's throwable card, 2026-09-13; the base one cut 2026-09-14):
		// bounce earnings - x5 on a fast bounce, x10 on a slow one
		var _pm = 1;
		if (abi_on("ad_th_bouncegain2")) _pm *= (_frac >= .5) ? 5 : 10;
		puck_pay(_frac, _pm, __cx() + _hx, __cy() + _hy);

		// restitution: fast bounces keep more than slow ones, so a
		// throw decays gently at first and then falls off a cliff -
		// which is what makes the last few bounces tense
		spd *= lerp(PUCK_BNC_SLOW, PUCK_BNC_FAST, _frac);

		// ⚖️ HIT-STUN, and the reason it works. The freeze itself is
		// only two or three frames; what sells it is that friction is
		// switched OFF for the duration (below). Impact -> freeze ->
		// full speed out. Damping the frame after a hit is what makes
		// most bounce toys feel like they are made of wet cardboard.
		stun  = PUCK_STUN * _frac * _frac;
		stun0 = max(stun, .001);

		// each wall spends one point of the throw's combo budget
		resist = max(0, resist - 1);

		// a wall kicks the spin as well as the direction - a puck that
		// bounces without its rotation changing reads as a sprite being
		// reflected rather than as an object hitting something
		yaw_spd = yaw_spd * -.55 + (_frac * PUCK_SPIN * .5 * choose(-1, 1));

		play_sound_ext(voice, lerp(.6, 1.5, _frac), lerp(.8, 1.9, _frac),
			lerp(.15, .6, _frac), 1);
		__burst(round(lerp(3, 12, _frac)), 150, lerp(1.4, 4, _frac));
	}

	// ---- friction ----
	// ⚖️ FRAME-RATE CORRECT, which DE's could not be. DE carried
	// hand-written fps buckets at 60/50/40/30 to keep the decay honest;
	// the real answer is exponential decay raised to the frame's length.
	// power(f, delta) is exact at every rate, including 144 - which is
	// what this machine actually runs at, and a rate none of DE's
	// buckets covered.
	var _fric = lerp(PUCK_FRIC_SLOW, PUCK_FRIC_FAST, clamp(spd / _max, 0, 1));
	// stun frictionlessness: cubed, so it releases sharply rather than
	// bleeding back in over the freeze
	if (stun > 0) _fric = lerp(_fric, 1, clamp(power(stun / stun0, 3), 0, 1));
	// and the combo budget, which is the same immunity bought in bulk
	if (resist > 0) _fric = lerp(_fric, 1, clamp(resist / resist0, 0, 1));
	spd *= power(_fric, delta);

	// a soft ceiling: past the scale speed the decay turns into a flat
	// subtraction, so a supercharged launch is fast but not unbounded
	if (spd > _max) spd -= (_max - _max * _fric) * delta;

	if (spd < PUCK_STOP) {
		spd = 0;
		resist = 0;
		bounces = 0;
	}
}

// keep dir in 0..360 so the aim maths and the readout agree
if (dir >= 360 || dir < 0) dir -= 360 * floor(dir / 360);
