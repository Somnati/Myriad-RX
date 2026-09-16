/// @description bestiary_lore(kind) -> the natural history in a line ("hunts in threes; will not cross running water"), fixed for the kind
/// Two habits off pools the kind qualifies for by its roster entry - the
/// quick (spd 9+), the big (hp 7+), the arcane (magic), the dead (crypt
/// among its lands), the swarming (a high counter, or the small kinds),
/// the wet (marsh / coast / isle) - and the general pool for everyone;
/// picked by a hash of the name, so a lupus is always the same lupus.
function bestiary_lore(_kind) {
	var _ros = foe_roster(), _r = undefined;
	for (var _i = 0; _i < array_length(_ros); _i++) if (_ros[_i].name == _kind) { _r = _ros[_i]; break; }
	if (is_undefined(_r)) return "";
	var _pool = ["will not cross running water", "hunts by smell, badly", "can be bargained with, once", "a delicacy in the coast towns", "fears fire more than it should",
	             "hoards anything that shines", "seen only at dusk", "sleeps through the heat of the day", "never far from the last one you saw", "leaves its dead where they fall",
	             "takes the road when it can", "goes quiet before rain", "keeps to the same paths for years", "will follow a crew a day out of spite"];
	if (_r.shape.spd >= 9)  { array_push(_pool, "faster than a horse over the first hundred paces"); array_push(_pool, "cannot be outrun; can be outwaited"); array_push(_pool, "tires in a long fight"); array_push(_pool, "strikes and is gone"); }
	if (_r.shape.hp >= 7)   { array_push(_pool, "shakes the ground a little"); array_push(_pool, "slow to anger and slower to stop"); array_push(_pool, "its hide turns a poor blade"); array_push(_pool, "eats a sheep a day, given the chance"); }
	if (_r.magic)           { array_push(_pool, "the air goes cold around it"); array_push(_pool, "crossed by iron"); array_push(_pool, "hums when it is about to strike"); array_push(_pool, "its light is not warm"); }
	if (array_contains(_r.lands, "crypt")) { array_push(_pool, "does not bleed"); array_push(_pool, "will not pass a threshold with salt on it"); array_push(_pool, "remembers a name, sometimes its own"); array_push(_pool, "falls apart and gets up"); }
	if (_r.cnt >= 8 || _r.shape.hp <= 3)  { array_push(_pool, "one is nothing; twenty is a problem"); array_push(_pool, "found where it is fed"); array_push(_pool, "the noise comes first"); array_push(_pool, "kill the nest, or you kill nothing"); }
	if (array_contains(_r.lands, "marsh") || array_contains(_r.lands, "coast") || array_contains(_r.lands, "isle")) { array_push(_pool, "at home in the wet"); array_push(_pool, "drowns nothing; it waits"); array_push(_pool, "leaves a slick behind it"); }
	// the hash of the name
	var _h = 0;
	for (var _i = 1; _i <= string_length(_kind); _i++) _h = (_h * 31 + ord(string_char_at(_kind, _i))) & $7fffffff;
	var _n = array_length(_pool);
	var _a = hash_mix(_h, 1) mod _n, _b = hash_mix(_h, 2) mod _n;
	if (_b == _a) _b = (_a + 1 + (hash_mix(_h, 3) mod (_n - 1))) mod _n;
	return _pool[_a] + "; " + _pool[_b];
}
