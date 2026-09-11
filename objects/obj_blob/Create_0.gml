/// obj_blob - A SPRITE'S BODY (his idea, 2026-09-11: "cute lil debug
/// sprite... blobs with eyes"). One per g.sprites struct while the
/// money room is up (syst_sprites makes it); the struct is the truth,
/// this is its face and its hands.
///
/// DRAWN AS ROOM PIXELS, not a smooth ellipse: the body is stamped row
/// by row with spr_pixel_1x1 (a rasterised ellipse), the eyes are 2x2
/// whites with a 1px pupil that LOOKS AT THE POINTER, so it sits in the
/// house's pixel grammar beside the dice and the puck rather than
/// floating over it as vector art.
///
/// THE LOOP: work (it taps through tap_fire on its own cadence, hopping
/// on each) / idle (it bobs) / wander (it walks somewhere else in the
/// lower third of the room) / nap (after a long absence, until poked).
/// The state durations are weighted so its time working averages the
/// personality's `work` - the same rate sprites_tick pays headless,
/// so watching it changes nothing about what it earns.
///
/// POKE IT: it hops, its eyes go ^ ^, sparks in its colour, a squeak, a
/// line from its personality in a bubble, and its little card (name,
/// temperament, job, taps, what it did while you were away). A press on
/// it is never a tap on the surface (obj_clicker asks).

depth = -60;    // over the visualiser (50) and its passes, under the readouts

s   = undefined;   // the struct, bound by syst_sprites
sid = -1;

r     = 5;         // body radius, room px
st    = 0;         // 0 idle, 1 wander, 2 work, 3 nap
st_t  = 60;        // frames left in the state
tx    = x; ty = y; // the wander target
bob   = random(360);
blink = 0;         // frames of blink left
blink_t = random_range(90, 240);
sq    = 0;         // the squash impulse, 0..1, decays
hop   = 0;         // px of lift from a hop, decays
happy = 0;         // frames of ^ ^ eyes
bub   = "";        // the speech bubble
bub_t = 0;
card  = 0;         // frames the card stays up
tap_t = 0;         // frames to the next tap while working
look_x = 0; look_y = 0;   // the pupils, eased toward the pointer

/// the lower third of the room: where it lives
__bounds = function() {
	return { x1 : 14, x2 : room_width - 14, y1 : room_height * .60, y2 : room_height - 28 };
};

/// pick the next state, weighted so working averages the personality.
/// ⚖️ EVERY SLOT IS THE SAME LENGTH (sprites_twin, 2026-09-11): the
/// first cut gave work slots twice the length of idle ones, so the
/// live sprite spent 7-15% MORE of its time working than the
/// personality said - and than the headless runner paid when you were
/// in another room. With P(work) = work and equal slot lengths the
/// time fraction IS work, and watching it changes nothing it earns. A
/// wander walks to its spot and then stands there for the rest of its
/// slot rather than ending on arrival, for the same reason.
__next_state = function() {
	var _pl = sprite_personalities();
	var _p  = _pl[clamp(s.pers, 0, array_length(_pl) - 1)];
	st_t = random_range(200, 320);
	if (random(1) < _p.work) { st = 2; tap_t = min(tap_t, 30); }
	else if (random(1) < .5) st = 0;
	else {
		st = 1;
		var _b = __bounds();
		tx = random_range(_b.x1, _b.x2);
		ty = random_range(_b.y1, _b.y2);
	}
};

/// the poke
__poke = function() {
	var _pl = sprite_personalities();
	var _p  = _pl[clamp(s.pers, 0, array_length(_pl) - 1)];
	happy = 70;
	sq = 1; hop = 4;
	spark_burst(x, y - r * 2, 8, s.col);
	play_sound_ext(snd_pop, 1.5 + random(.4), 1.9 + random(.3), .45, 1);
	if (s.asleep) {
		s.asleep = false;
		st = 0; st_t = 60;
		bub = "wha? ...oh, hi";
		save_mark_dirty();
	} else bub = _p.lines[irandom(array_length(_p.lines) - 1)];
	bub_t = 110;
	card = (card > 0) ? 0 : 360;
};

/// is this press mine? (obj_clicker asks before it taps the surface)
__hit = function(_mx, _my) {
	return point_distance(_mx, _my, x, y - r) <= r + 4;
};
