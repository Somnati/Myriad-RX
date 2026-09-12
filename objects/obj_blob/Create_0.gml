/// obj_blob - A SPRITE'S BODY (his idea, 2026-09-11: "cute lil debug
/// sprite... blobs with eyes"). One per g.sprites struct while the
/// money room is up (syst_sprites makes it); the struct is the truth,
/// this is its face and its hands.
///
/// THE BODY IS A RAYCAST SPHERE (sh_blob, 2026-09-11 - his ask for
/// materials): one ray per room-pixel cell, so it sits in the house's
/// pixel grammar beside the dice and the puck, lit by the same light,
/// in one of four materials (matte / glass / metal / jelly - the glass
/// is his inspiration, a bubble with a lit rim). The eyes are pixel
/// stamps over it in one of seven styles (sprite_looks); the pupils
/// LOOK AT THE POINTER where the style has them.
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
	if (s.asleep) {
		s.asleep = false;
		st = 0; st_t = 60;
		bub = "wha? ...oh, hi";
		sprite_voice(s, "wake");
		save_mark_dirty();
	} else {
		bub = _p.lines[irandom(array_length(_p.lines) - 1)];
		sprite_voice(s, "poke");
	}
	bub_t = 110;
	card = (card > 0) ? 0 : 360;
};

// the shader's handles, once
u_quad_b  = shader_get_uniform(sh_blob, "u_quad");
u_cells_b = shader_get_uniform(sh_blob, "u_cells");
u_col_b   = shader_get_uniform(sh_blob, "u_col");
u_col2_b  = shader_get_uniform(sh_blob, "u_col2");
u_mat_b   = shader_get_uniform(sh_blob, "u_mat");
u_light_b = shader_get_uniform(sh_blob, "u_light");
u_sq_b    = shader_get_uniform(sh_blob, "u_sq");
u_time_b  = shader_get_uniform(sh_blob, "u_time");
// the room's light (syst_scene_light / scene_light_bind)
s_scene_b   = shader_get_sampler_index(sh_blob, "u_scene");
s_scene_bw  = shader_get_sampler_index(sh_blob, "u_scene2");
u_sceneuv_b = shader_get_uniform(sh_blob, "u_scene_uv");
u_sceneam_b = shader_get_uniform(sh_blob, "u_scene_amt");
spk = [];   // the glass ones' orbiting specks: { a, r, ph }
repeat (3) array_push(spk, { a : random(360), r : random_range(4, 8), ph : random(360) });

/// is this press mine? (obj_clicker asks before it taps the surface)
__hit = function(_mx, _my) {
	return point_distance(_mx, _my, x, y - r) <= r + 4;
};
