/// @description upgrade_slots();
/// How many slots are live right now: the base plus every "another
/// slot" grant bought. Derived, like everything else - the grant
/// increments a COUNT, and this turns the count into the answer, so
/// there is no second place that could disagree about how many slots
/// exist.
function upgrade_slots() {
	upgrade_init();
	return clamp(UPG_SLOT_BASE + g.upg.bought, 1, UPG_SLOT_MAX);
}
