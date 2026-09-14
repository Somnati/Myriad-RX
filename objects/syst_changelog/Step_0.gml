// ---- THE OPEN/CLOSE EASE (the overlay contract) ----
oa = move_to(oa, closing ? 0 : 1, closing ? UI_OUT_SPD : UI_IN_SPD);
if (abs(oa - (closing ? 0 : 1)) < .004) oa = closing ? 0 : 1;
if (closing && oa <= 0) { instance_destroy(); exit; }

// the bar scrolls the column (wheel + touch drag) and writes `scroll`
if (instance_exists(sb)) sb.enabled = (oa >= .999 && !closing);
scroll = clamp(scroll, 0, __scroll_max());

// ---- input: only once the panel has fully arrived, and only while
// nothing sits over it ----
if (oa < .999 || closing) exit;
if (!input_free(ui_layer_overlay)) exit;
if (keyboard_check_pressed(vk_escape)) { changelog_close(); exit; }
if (variable_global_exists("click_owner") && g.click_owner != noone) exit;
if (!mouse_check_button_pressed(mb_left)) exit;
if (mouse_y < list_y || mouse_x < col_x || mouse_x > col_x + col_w) exit;

// ---- the folds: a tap on an era's band or a release's header toggles it ----
var _rows = __rows();
var _y = list_y + 4 - scroll;
for (var _i = 0; _i < array_length(_rows); _i++) {
	var _rw = _rows[_i];
	var _hh = (_rw.kind == "era") ? era_h : head_h;   // the tappable strip: the band, or the header line
	if (mouse_y >= _y && mouse_y < _y + _hh) {
		if (_rw.kind == "era") {
			var _k = _rw.e.era;
			open_era[$ _k] = !(open_era[$ _k] ?? false);
		} else {
			var _k = _rw.r.ver;
			open_rel[$ _k] = !(open_rel[$ _k] ?? false);
		}
		play_sound_ext(snd_softclick, 1, 1.1, .4, 1);
		exit;
	}
	_y += _rw.h + 4;
}
