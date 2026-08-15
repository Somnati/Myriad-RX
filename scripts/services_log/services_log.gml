/// @description services_log(msg) - one line into the services debug
/// log: shows in rm_services' panel AND the output console. every
/// services_* script and (later) every async callback reports here,
/// so the bench room is a live tail of what the SDKs are doing.
function services_log(_msg) {
	if (!variable_global_exists("services")) services_init();
	array_push(g.services.log, string(_msg));
	while (array_length(g.services.log) > 30) array_delete(g.services.log, 0, 1);
	show("[services] " + string(_msg));
}
