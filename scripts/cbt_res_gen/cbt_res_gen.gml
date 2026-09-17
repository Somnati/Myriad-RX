/// @description cbt_res_gen(seed, [elem]) -> { fire, water, nature } - a
/// pawn's resistance table at birth (his rule, 2026-09-17: "+20% in 1
/// element and -20% in another"). Signed: minus takes more, plus takes
/// less, 0 normal. A kind WITH an element gets it off the triangle - a
/// fire kind is soft to water and shrugs nature; anything else rolls its
/// pair off the seed (a hash, so the same sprite always has the same
/// table and nothing is saved).
function cbt_res_gen(_seed, _elem = "") {
	var _b = cbt_balance();
	var _r = { fire : 0, water : 0, nature : 0 };
	if (_elem == "fire" || _elem == "water" || _elem == "nature") {
		var _ei = cbt_elem_info(_elem);
		_r[$ _ei.weak]  = -_b.res_step;
		_r[$ _ei.beats] =  _b.res_step;
		return _r;
	}
	var _els = ["fire", "water", "nature"];
	var _h = hash_mix(floor(_seed) & $7fffffff, 4242);
	var _w = _h mod 3;
	var _s = (_w + 1 + ((_h div 3) mod 2)) mod 3;
	_r[$ _els[_w]] = -_b.res_step;
	_r[$ _els[_s]] =  _b.res_step;
	return _r;
}
