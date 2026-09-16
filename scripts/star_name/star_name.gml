/// @description star_name(id) -> the star's name, rolled lazily from its seed (the tech demo's scr_star_get_name)
/// NO ROMAN NUMERAL (his call, 2026-09-16): gen_name_planet hangs one on a
/// name in twenty, and a star's planets wear their own - "Titorastra VI II"
/// was the home. The rolls stand (the seed's stream is the same); a
/// trailing numeral is simply cut off the star's copy.
function star_name(_id) {
	var _sm = starmap_get();
	if (_id < 0 || _id >= _sm.count) return "";
	var _st = _sm.stars[_id];
	if (_st.props.name == "") {
		var _rs = random_get_seed();
		random_set_seed(_st.seed);
		var _nm = gen_name_planet();
		rng_release(_rs);
		var _sp = string_last_pos(" ", _nm);
		if (_sp > 1) {
			var _tail = string_upper(string_copy(_nm, _sp + 1, string_length(_nm) - _sp));
			if (_tail == "I" || _tail == "II" || _tail == "III" || _tail == "IV" || _tail == "V" || _tail == "VI" || _tail == "VII") _nm = string_copy(_nm, 1, _sp - 1);
		}
		_st.props.name = _nm;
	}
	return _st.props.name;
}
