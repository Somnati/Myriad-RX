/// @description exped_world_col(dest) -> the world's own colour (seeded), for wherever its name is drawn
/// His ask (2026-09-15): "each world should have a seeded primary color
/// for when its name is drawn". A hue off the seed, bright and light.
function exped_world_col(_d) {
	return c_hsv(hash_mix(_d.seed, 77) mod 256, 120, 255);
}
