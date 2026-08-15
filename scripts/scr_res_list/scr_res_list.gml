/// @description scr_res_list() - THE windowed-resolution table.
/// the old system hardcoded five 16:9 sizes and offered all of them no
/// matter the monitor; this builds the list live from the display:
///  - the display's NATIVE size always leads the list (flagged native)
///  - then the standard 16:9 ladder, keeping only sizes that FIT
///  - widths are unique (native wins a collision) because g.screen_size
///    keys on WIDTH alone - the save format stays untouched
/// consumed by scr_display1 (the swap lookup + saved-size validation)
/// and by settings_content (the resolution radio group). one source,
/// so the picker can never offer a size the swap can't apply.
function scr_res_list() {

	var _dw = display_get_width();
	var _dh = display_get_height();
	var _out = [];

	array_push(_out, { w : _dw, h : _dh, native : true,
		label : string(_dw) + " x " + string(_dh) });

	var _cand = [
		[3840, 2160], [2560, 1440], [1920, 1080],
		[1600, 900],  [1366, 768],  [1280, 720], [1024, 576],
	];
	for (var _i = 0; _i < array_length(_cand); _i++) {
		var _w = _cand[_i][0];
		var _h = _cand[_i][1];
		if (_w > _dw || _h > _dh) continue; // doesn't fit this display
		if (_w == _dw) continue;            // width collision: native won
		array_push(_out, { w : _w, h : _h, native : false,
			label : string(_w) + " x " + string(_h) });
	}

	return _out;
}
