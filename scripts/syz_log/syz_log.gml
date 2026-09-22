/// @description syz_log(s, txt) - a line on the ledger (the last eight kept)
function syz_log(_s, _txt) {
	array_push(_s.log, _txt);
	if (array_length(_s.log) > 8) array_delete(_s.log, 0, 1);
}
