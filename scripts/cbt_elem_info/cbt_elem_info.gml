/// @description cbt_elem_info(key) -> { key, name, col, beats, weak, burn, shrug }
/// THE THREE and the two schools (his design, 2026-09-17). The triangle:
/// water douses fire, fire burns the grove, nature drinks the water (and
/// lightning runs through it) - water > fire > nature > water. It decides
/// how a pawn's resistance table is GENERATED (cbt_res_gen) and nothing
/// else; the table is the one multiplier. Light and dark are schools of
/// EFFECT (buffs and healing against nerfs and leeching), flat damage,
/// no table. `burn` / `shrug` are the log's words for a weak / resisted hit.
function cbt_elem_info(_e) {
	switch (_e) {
		case "fire":   return { key : "fire",   name : "fire",   col : c_horange, beats : "nature", weak : "water",
		                        burn : choose("it burns", "it scorches", "it catches"), shrug : choose("it barely singes", "it smoulders and goes out") };
		case "water":  return { key : "water",  name : "water",  col : c_sblue,   beats : "fire",   weak : "nature",
		                        burn : choose("it soaks through", "it chills to the bone"), shrug : choose("it runs off", "it beads and drips") };
		case "nature": return { key : "nature", name : "nature", col : c_sgreen,  beats : "water",  weak : "fire",
		                        burn : choose("it stings", "it takes root", "it crackles through"), shrug : choose("it barely pricks", "it glances off the hide") };
		case "light":  return { key : "light",  name : "light",  col : c_gold,    beats : "", weak : "", burn : "", shrug : "" };
		case "dark":   return { key : "dark",   name : "dark",   col : c_hpurple, beats : "", weak : "", burn : "", shrug : "" };
	}
	return { key : "", name : "", col : c_white, beats : "", weak : "", burn : "", shrug : "" };
}
