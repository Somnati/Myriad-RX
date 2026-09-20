/// @description star_light(skind, [seed], [period]) -> { lum, tint : [r, g, b], pulse } - THE STAR'S LIGHT by its kind (q253): lum = its luminosity against a sun's (the skies' flux law reads it); tint = the colour and strength of its DAY on its worlds (sh_planet's u_sunl - white is a sun's); pulse = a cepheid's breath NOW (1 for the rest) - irregular, never a metronome
/// A red giant's worlds bask orange; a white dwarf's are lit blue-white and a little dim; a pulsar's cold and blue; a
/// brown dwarf's live in a red dusk; a chromatic star's day is white with a fringe; a swelling star's day brightens as it fills; a
/// protostar's is orange and dim; a black hole's disc lights blue-white, faintly
function star_light(_skind, _seed = 0, _period = 2400) {
	var _pulse = 1;
	if (_skind == "swell") _pulse = star_swell(_seed).s;   // (the swelling star's day brightens as it fills - q267)
	switch (_skind) {
		case "giant":   return { lum : 3,    tint : [1.00, 0.86, 0.66], pulse : 1 };
		case "dwarf":   return { lum : .15,  tint : [0.84, 0.90, 1.00], pulse : 1 };
		case "pulsar":  return { lum : .15,  tint : [0.62, 0.70, 0.90], pulse : 1 };
		case "hole":    return { lum : .4,   tint : [0.55, 0.62, 0.80], pulse : 1 };
		case "brown":   return { lum : .03,  tint : [0.52, 0.30, 0.28], pulse : 1 };
		case "chroma":  return { lum : 1.6,  tint : [1.02, 1.00, 1.04], pulse : 1 };
		case "swell":   return { lum : 2.2 * _pulse, tint : [1.00, 0.82 + .10 * (_pulse - 1), 0.62], pulse : _pulse };
		case "proto":   return { lum : .5,   tint : [0.85, 0.62, 0.46], pulse : 1 };
	}
	return { lum : 1, tint : [1, 1, 1], pulse : 1 };
}
