/// @description planet_moons(seed) -> the world's moons, four rolled: [{ dist, size, ang, spd, incl, col }]
/// THE ONE SOURCE of a world's moons (the tech demo's scr_planet_moons,
/// ported 2026-09-15): dist in world radii, size in world radii, ang the
/// seed-time phase, spd deg a step (x60 x wall seconds for the universal
/// clock - moon_pos), incl each moon's own orbital plane off the world's
/// tilt, col a muted rock of its own. planet_props says how many of the
/// four a world has. A seeded section of its own (rng_release).
function planet_moons(_seed) {
	var _old = random_get_seed();
	random_set_seed((_seed ^ $5a5a) & $7fffffff);
	var _mn = [];
	for (var _i = 0; _i < 4; _i++) {
		array_push(_mn, {
			dist : 1.75 + _i * .5 + random(.25),
			size : random_range(.07, .13),
			ang  : random(360),
			spd  : random_range(.25, .5) * choose(1, -1) / (1 + _i * .5),
			incl : random_range(5, 28) * choose(1, -1),
			col  : merge_colour(make_colour_hsv(irandom(255), irandom_range(40, 130), irandom_range(105, 205)), rgb(152, 150, 156), .35),
		});
	}
	rng_release(_old);
	return _mn;
}
