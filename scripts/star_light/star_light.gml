/// @description star_light(skind, [seed], [period]) -> { lum, tint : [r, g, b], pulse } - THE STAR'S LIGHT by its kind (q253): lum = its luminosity against a sun's (the skies' flux law reads it); tint = the colour and strength of its DAY on its worlds (sh_planet's u_sunl - white is a sun's); pulse = a cepheid's breath NOW (1 for the rest) - irregular, never a metronome
/// A red giant's worlds bask orange; a white dwarf's are lit blue-white and a little dim; a pulsar's cold and blue; a
/// brown dwarf's live in a red dusk; a Wolf-Rayet's blaze blue-white; a cepheid's day breathes with the star; a
/// protostar's is orange and dim; a black hole's disc lights blue-white, faintly
function star_light(_skind, _seed = 0, _period = 2400) {
	var _pulse = 1;
	if (_skind == "cepheid") _pulse = star_pulse(_seed, _period);
	switch (_skind) {
		case "giant":   return { lum : 3,    tint : [1.00, 0.86, 0.66], pulse : 1 };
		case "dwarf":   return { lum : .15,  tint : [0.84, 0.90, 1.00], pulse : 1 };
		case "pulsar":  return { lum : .15,  tint : [0.62, 0.70, 0.90], pulse : 1 };
		case "hole":    return { lum : .4,   tint : [0.55, 0.62, 0.80], pulse : 1 };
		case "brown":   return { lum : .03,  tint : [0.52, 0.30, 0.28], pulse : 1 };
		case "wolf":    return { lum : 7,    tint : [1.00, 1.04, 1.12], pulse : 1 };
		case "cepheid": return { lum : 2.5 * _pulse, tint : [1.00 * (0.80 + .28 * _pulse), 0.96 * (0.80 + .28 * _pulse), 0.88 * (0.80 + .28 * _pulse)], pulse : _pulse };
		case "proto":   return { lum : .5,   tint : [0.85, 0.62, 0.46], pulse : 1 };
	}
	return { lum : 1, tint : [1, 1, 1], pulse : 1 };
}
