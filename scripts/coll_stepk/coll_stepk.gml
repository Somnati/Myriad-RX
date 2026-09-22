/// @description coll_stepk(c) -> the tier cost steps' factor this run: COLL_RESIDUE^crunches (30 at most) - the crunch's residue, the one thing that carries growth across runs
function coll_stepk(_c) {
	return power(COLL_RESIDUE, min(_c.crunches, 30));
}
