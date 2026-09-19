/// @description mood_init(sprite) -> the sprite's mood struct { v, a, e, why, why_t, lost, pokes, pday }, made at rest on first ask (q261)
function mood_init(_sp) {
	if (is_struct(_sp[$ "mood"])) return _sp.mood;
	var _b = mood_base(_sp);
	_sp.mood = { v : _b.v, a : _b.a, e : 1, why : "", why_t : 0, lost : undefined, pokes : 0, pday : -1 };
	return _sp.mood;
}
