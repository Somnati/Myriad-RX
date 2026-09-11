/// @description ram_cap() - the sticks the player holds: the base plus
/// RAM_REB per rebirth banked - the long-run player stops thinking
/// about the budget, which is the intent. (A profit-priced capacity
/// ladder existed for an hour on 2026-09-11 and was cut on his call.)
function ram_cap() {
	var _reb = variable_global_exists("rebirth") ? g.rebirth.total : 0;
	return RAM_BASE + _reb * RAM_REB;
}
