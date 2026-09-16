/// @description hp_bar_col() -> the colour every hp bar wears: the house red, or c_sgreen (settings > visuals - his ask, 2026-09-16)
function hp_bar_col() {
	return (variable_global_exists("hp_bar_col") && g.hp_bar_col == "green") ? c_sgreen : c_hred;
}
