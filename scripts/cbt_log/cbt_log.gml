/// @description cbt_log(fight, txt) - a line into the fight's rolling log
/// (the combat window reads the last; twelve are kept). Headless: the
/// tech demo's combat_log wrote to syst_combat - here the fight IS the
/// place, so a fight resolved offline logs exactly like one watched.
function cbt_log(_f, _txt) {
	array_push(_f.log, _txt);
	if (array_length(_f.log) > 12) array_delete(_f.log, 0, array_length(_f.log) - 12);
}
