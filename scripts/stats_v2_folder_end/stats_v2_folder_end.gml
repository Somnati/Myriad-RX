/// @description stats_v2_folder_end() - closes the current folder
/// scope (always call it, open or closed - it pairs with the
/// stats_v2_folder call, not with the folder being open).
function stats_v2_folder_end() {
	_fdepth = max(0, _fdepth - 1);
	if (array_length(_fstack) > 0) {
		var _was_open = array_pop(_fstack);
		if (!_was_open) _fhid = max(0, _fhid - 1);
	}
	var _cut = string_last_pos("/", _fpath);
	_fpath = (_cut > 0) ? string_copy(_fpath, 1, _cut - 1) : "";
}
