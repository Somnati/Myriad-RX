/// THE PUCK - a rebuild of Myriad DE's obj_throwable / do_throwable
/// (his ask, 2026-09-09: "a brand new one with your code... mirror it
/// with all its bells and whistles"). Every mechanic below is DE's; the
/// code is not.
///
/// ⚖️ WHAT IT IS. A disc you drag and fling around the tap room. Every
/// wall bounce pays taps. Catching it mid-flight pays triple. Docking it
/// bottom-centre turns it into a cannon with power tiers. It is the
/// game's one skill expression, and it converts aim into income.
///
/// ⚖️ THE ONE IDEA WORTH PRESERVING ABOVE ALL THE REST: a bounce pays a
/// MULTIPLE OF YOUR OWN TAP RATE, not a number of its own. DE used the
/// run's peak tps; this uses tap_rate() - see puck_pay. Either way the
/// puck needs no balance curve, can never be tuned wrong relative to the
/// rest of the game, and stays exactly as relevant at 1e40 as at 1e2.
///
/// ---- WHAT I KEPT, and why each one earns its place ----
///
///   POLAR MOTION (a direction and a scalar speed, never a velocity
///   vector). It is why bounces read as clean mirror reflections. A
///   vector solver would be more "correct" and would look worse.
///
///   THE ADAPTIVE FOLLOW. The puck never snaps to the cursor - it
///   trickles, at a rate that SLOWS as the cursor gets further away.
///   Yank fast and it stretches, lags, then catches up. That single
///   rule is the entire sensation of weight.
///
///   THE SLIDING GRIP. It does not hang from its own centre. The grab
///   point moves with where the puck sits in the room and with where
///   the cursor is vertically, so it reads as holding a physical object
///   by a shifting grip rather than dragging a sprite.
///
///   THE CANNON DOCK. Bottom-centre, with a sound, refusing to re-fire
///   while you are already sitting in it. DE had six magnets; the other
///   five were removed on his report - see __docks for why they were a
///   bug rather than a taste, and why they were vestigial to begin
///   with.
///
///   HIT-STUN, and the thing that makes it work: for the two or three
///   frames after a bounce, friction is lerped OFF entirely. The
///   impact freezes and then releases at full speed. Damping the moment
///   after a hit is what makes most bounce toys feel dead.
///
///   BOUNCE RESIST AS A COMBO RESOURCE. A launch buys N near-
///   frictionless bounces and each wall spends one. Upgrades that add
///   resist are buying combo LENGTH, which is a different axis from
///   speed and reads completely differently in the hand.
///
///   THE PER-THROW VOICE. Each grab re-rolls which sound this throw
///   bounces with, for the whole life of the throw. Cheap, and it makes
///   two throws in a row feel like two different events.
///
/// ---- WHAT I CHANGED, and why ----
///
///   FRICTION IS FRAME-RATE CORRECT. DE hand-rolled fps buckets at
///   60/50/40/30 to keep decay honest. The actual answer is
///   power(fric, delta) - exponential decay raised to the frame's
///   length - which is exact at every rate including the ones between
///   the buckets. This machine runs at monitor refresh; the buckets
///   would have been wrong at 144.
///
///   THE WALLS AGREE WITH THEMSELVES. DE's bounce test used the puck's
///   far edge on two walls and its near edge on the other two, while
///   the position clamp used a third rectangle. The puck could sit half
///   off the right and bottom edges. There is ONE rect here (__tray)
///   and the test, the clamp and the draw all read it.
///
///   THE PAYOUT RIDES tap_rate(). DE read g.max_cycle_tps, a run-peak
///   watermark that has to be stored, saved, and reset at rebirth. The
///   hold rate is the same quantity with no state: it already carries
///   every upgrade, it cannot drift, and there is nothing to reset.
///
///   BOUNCES ARE NOT TAPS. DE's give_click had an `is_cube` branch that
///   skipped the lifetime tap counter; here tap_fire takes a `_stat`
///   argument. Same law, declared at the call instead of sniffed from
///   the caller's identity.
///
///   THE CEREMONY IS THE HOUSE'S. DE burst generic shard-sparks. A
///   bounce here fires bezier_bits, so the profit it just earned
///   visibly flies to the header counter like every other payout in
///   this game. The sparks stay, as a separate impact flourish.

// ---- identity ----
// x/y are the puck's TOP-LEFT, which is DE's model and not an
// accident: the mask is a spr_pixel_1x1 rectangle (origin 0,0) scaled
// to the diameter, so syst_input's family sweep can hit-test it with
// no special case. The CENTRE is derived - see __cx/__cy.
sprite_index = spr_pixel_1x1;
mask_index   = spr_pixel_1x1;
image_xscale = PUCK_D;
image_yscale = PUCK_D;
image_alpha  = 0;   // drawn by hand; this keeps the mask from painting

// over the visualiser (50), under everything drawn on the glass (the
// per-tap and tps readouts sit at 0) and under header/drawer/overlays.
// Deeper than the blur layer at -500 so it softens with the room.
depth = 9;

d  = PUCK_D;
r  = PUCK_D * .5;
col = c_gold;          // re-rolled on every grab
tint = col;            // the live blend (red stunned, aqua docked)

// ---- THE SOLID (his ask: 3D like the dice, and a hockey puck) ----
// sh_puck raymarches a rounded cylinder, the same construction obj_dice
// uses for its d6. It takes ONE angle instead of an orientation matrix,
// because a puck lying on a table has exactly one degree of freedom -
// see the shader for why that is nine uniforms and nine dot products a
// ray cheaper.
yaw     = random(360);   // where its knurl happens to be pointing
yaw_spd = 0;             // deg per 60hz frame

// black vulcanised rubber, and it stays black: the per-throw colour
// lives in the STAMPED RING on the crown instead. A puck that changes
// body colour stops being a puck; a puck with a coloured stamp is still
// obviously a puck and still tells you which throw you are watching.
rubber = rgb(26, 26, 32);
// ...unless settings say otherwise (his ask, 2026-09-10: "settings to
// change the puck's material"): the dice's roster, one pill of its
// own (g.puck_mat). "random" here means the classic black rubber, not
// a roll - a puck with a random body colour stops being a puck.
mat_id    = "";
mat_metal = .06;
__mat_apply = function() {
	var _t = dice_mat_config();
	var _id = variable_global_exists("puck_mat") ? g.puck_mat : "random";
	var _m = _t[0];
	for (var _i = 0; _i < array_length(_t); _i++)
		if (_t[_i].id == _id) { _m = _t[_i]; break; }
	mat_id = _m.id;
	if (_m.col < 0) { rubber = rgb(26, 26, 32); mat_metal = .06; }
	else            { rubber = _m.col;          mat_metal = _m.metal; }
};
__mat_apply();

u_quad_p  = shader_get_uniform(sh_puck, "u_quad");
u_yaw_p   = shader_get_uniform(sh_puck, "u_yaw");
u_light_p = shader_get_uniform(sh_puck, "u_light");
u_col_p   = shader_get_uniform(sh_puck, "u_col");
u_ring_p  = shader_get_uniform(sh_puck, "u_ring");
u_metal_p = shader_get_uniform(sh_puck, "u_metal");
u_pad_p   = shader_get_uniform(sh_puck, "u_pad");
u_cells_p = shader_get_uniform(sh_puck, "u_cells");
u_mb_p    = shader_get_uniform(sh_puck, "u_mb");
u_mbk_p   = shader_get_uniform(sh_puck, "u_mbk");
// MOTION BLUR bookkeeping (see the Draw): the transform the puck was
// LAST DRAWN at. Seeded to where it is, so the first frame has no sweep.
mb_cx  = x + PUCK_D * .5;
mb_cy  = y + PUCK_D * .5;
mb_yaw = yaw;

// ---- motion (polar: DE's model) ----
spd  = 0;
dir  = 0;
stun = 0;              // frames of impact freeze left
stun0 = 1;             // ...and what it started at, for the ramp
resist  = 0;           // near-frictionless bounces left in this throw
resist0 = 1;
bounces = 0;
peak    = 0;           // fastest this throw got, for the readout

// ---- interaction ----
held    = false;       // the pointer owns it
docked  = false;       // ...and it is locked to one of the six docks
cannon  = false;       // ...specifically the bottom-centre one
cannon_t = 0;          // frames since the cannon armed (the wind-up)
gx = 0; gy = 0;        // the cursor-chasing anchor, in room space
grip_x = 0; grip_y = 0;// where on the puck the pointer is holding it
aim = 0;               // pull distance, px
tier = 0;              // aim power tier, 0..PUCK_TIERS
was_cannon = false;

// ---- the impact voice ----
// DE re-rolls which sound a throw bounces with on every grab and keeps
// it for that throw's whole life. Two throws in a row are then two
// different events for almost nothing. This is RX's roster rather than
// DE's - same idea, sounds that exist here.
snd_pool = [snd_pop, snd_popclick, snd_cointoss, snd_orb, snd_gold,
            snd_gold2, snd_diamond, snd_merge, snd_tierup, snd_apply,
            snd_drum, snd_atlas, snd_afripop2, snd_pickupmod,
            snd_matclick, snd_click];
voice = snd_pool[irandom(array_length(snd_pool) - 1)];

// ---- the impact sparks ----
// A tiny fixed pool rather than instances: a bounce spawns a handful,
// they live about a third of a second, and at no point does the room
// need a second object type to garbage-collect. Structs in an array,
// compacted in the Step.
sparks = [];

/// @func __cx()
/// @desc The puck's centre. x/y are the top-left (see above), and
///       every piece of maths here wants the middle, so it is a
///       function rather than thirty `+ r`s that can disagree.
__cx = function() { return x + r; };
__cy = function() { return y + r; };

/// @func __tray()
/// @desc THE ONE RECTANGLE. Returns {x1,y1,x2,y2} for the puck's
///       TOP-LEFT - already inset by the puck's own size on the far
///       edges, so a position clamped into this rect is fully on
///       screen by construction.
///
///       ⚖️ DE HAD THREE OF THESE and they disagreed: the bounce test
///       used the far edge on two walls and the near edge on the other
///       two, and the clamp afterwards used neither. The puck could sit
///       half off the right and bottom. One rect, read by the test, the
///       clamp and the docks, cannot drift.
__tray = function() {
	var _top = instance_exists(obj_ui_header) ? obj_ui_header.bar_h : 0;   // the bar, not its shadow (his call: flush)
	return {
		x1 : 0,
		y1 : _top,
		x2 : room_width  - d,
		y2 : room_height - d,
	};
};

/// @func __grip()
/// @desc Where on the puck the pointer is holding it, as an offset from
///       the top-left.
///
///       ⚖️ THIS IS THE SLIDING GRIP, and it is DE's least obvious good
///       idea. The puck does NOT hang from its own centre: the
///       horizontal grip slides with where the puck sits across the
///       room, and the vertical grip tracks how high the CURSOR is. So
///       the point you are holding wanders as you move, which is what
///       makes it read as a physical object in a hand rather than a
///       sprite pinned to a pointer. Clamped away from the very edges
///       so the puck can never hang off its own corner.
__grip = function() {
	var _t = __tray();
	var _w = max(1, _t.x2 - _t.x1);
	var _h = max(1, room_height);
	grip_x = d * clamp((x - _t.x1) / _w, .05, .95);
	grip_y = d * clamp(mousey / _h, .05, .95);
};

/// @func __docks()
/// @desc The magnet points, as {x, y, cannon, snd} in puck TOP-LEFT
///       coordinates, plus the radius each catches from.
///
/// ⚖️ THERE IS EXACTLY ONE NOW, AND IT IS THE CANNON (his report,
/// 2026-09-09: "im accidentally putting it in a corner snap when i try
/// to throw it"). He is describing a real bug, not a preference. Every
/// NON-cannon dock silently ate the throw: releasing while docked hit
/// the `!docked` gate below, so you pulled back toward a corner, let
/// go, and the puck simply sat there. The corners were only where he
/// met it first - top-centre had the identical failure, and throwing
/// upward is at least as common as throwing into a corner.
///
/// They were vestigial anyway. In DE these docks snapped the game
/// WINDOW to the edges of the desktop, which is a feature of the
/// window-throwing mode this in-room puck does not have. Six magnets
/// were ported because they were there; only one of them ever did
/// anything, and it is the one that turns the puck into a cannon.
///
/// If a parking dock is ever wanted back, the fix is not a smaller
/// radius - it is letting a release throw FROM a dock, so a dock parks
/// you when you let go without pulling and throws you when you pull.
/// A radius small enough not to catch a throw is a radius too small to
/// catch a park.
__docks = function() {
	var _t = __tray();
	return [
		{ x : (room_width - d) * .5, y : _t.y2,
		  r : max(room_width, room_height) * .12,
		  cannon : true, snd : snd_autostart },
	];
};

/// @func __burst(n, spread, [spd])
/// @desc n impact sparks from the puck's rim, thrown across `spread`
///       degrees around `dir`. Pure data - the Draw paints them.
__burst = function(_n, _spread, _sp = 2.4) {
	if (array_length(sparks) > 64) return;   // a flood is never worth it
	for (var _i = 0; _i < _n; _i++) {
		var _a = dir + random_range(-_spread, _spread) * .5;
		array_push(sparks, {
			x : __cx() + lengthdir_x(r * .8, _a),
			y : __cy() + lengthdir_y(r * .8, _a),
			d : _a,
			s : _sp * random_range(.5, 1.6),
			l : random_range(9, 20),
			l0 : 20,
			c : tint,
		});
	}
};

/// @func __roll_voice()
/// @desc A new colour and a new bounce sound for the throw about to
///       happen. DE re-rolls both on grab; keeping them for the whole
///       throw is what makes each one an event.
__roll_voice = function() {
	col   = vis_tier_color(irandom(9));
	voice = snd_pool[irandom(array_length(snd_pool) - 1)];
};

// (the baked half-width disc table is gone with the flat draw - the
// silhouette comes from the SDF now, and the shader's cell quantizer
// keeps it just as hard-edged as the pixel spans were)

// seed on the tray floor, centred, so a fresh room never starts it
// half off an edge
var _t0 = __tray();
x = clamp(x, _t0.x1, _t0.x2);
y = clamp(y, _t0.y1, _t0.y2);
gx = x; gy = y;
__roll_voice();
