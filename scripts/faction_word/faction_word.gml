/// @description faction_word(str) -> { txt, col } the strength in words for a card (q283): all but gone / thin on the ground / weakened / recovering / at strength
function faction_word(_s) {
	if (_s < .2)  return { txt : "all but gone",      col : c_seagreen };
	if (_s < .4)  return { txt : "thin on the ground", col : c_seagreen };
	if (_s < .7)  return { txt : "weakened",           col : c_gold };
	if (_s < .95) return { txt : "recovering",         col : c_horange };
	return { txt : "at strength", col : c_hred };
}
