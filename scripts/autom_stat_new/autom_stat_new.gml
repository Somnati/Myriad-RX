/// @description autom_stat_new() -> a fresh session tally (see autom_log)
function autom_stat_new() {
	return { dial_n : 0, dial_spent : 0, tile_n : 0, tile_spent : 0,
	         upg_n : 0, upg_spent : 0, reb_n : 0, reb_spent : 0, since : current_time };
}
