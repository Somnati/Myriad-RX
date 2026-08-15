/// @description pad_tick() - the framework's heartbeat, run by
/// syst_gamepad in BEGIN STEP (like syst_input: action states are
/// settled before any object's step reads them). four jobs in order:
/// rumble countdown -> device scan (every 30 steps, or NOW when the
/// async hotplug event zeroes scan_t) -> rebind capture (swallows the
/// frame so the captured press doesn't also fire its action) ->
/// per-action state update.
///
/// multi-controller model: actions MERGE across every connected
/// device (any pad can drive - couch rule), while g.pad.active tracks
/// the last device that produced input (glyph family + rumble target).
function pad_tick() {
	if (!variable_global_exists("pad")) exit;
	var _p = g.pad;

	// ---- rumble countdown ----
	if (_p.rumble_t > 0) {
		_p.rumble_t--;
		if (_p.rumble_t <= 0 && _p.active >= 0)
			gamepad_set_vibration(_p.active, 0, 0);
	}

	// ---- device scan ----
	if (_p.scan_t <= 0) {
		_p.scan_t = 30;
		var _n = min(gamepad_get_device_count(), 12);
		_p.n_conn = 0;
		for (var _i = 0; _i < 12; _i++) {
			var _d = _p.devs[_i];
			var _c = (_i < _n) && gamepad_is_connected(_i);
			if (_c && !_d.conn) {
				_d.name = gamepad_get_description(_i);
				var _lo = string_lower(_d.name);
				if (string_pos("xbox", _lo) > 0 || string_pos("xinput", _lo) > 0)
					_d.kind = "xbox";
				else if (string_pos("dual", _lo) > 0 || string_pos("sony", _lo) > 0
					|| string_pos("ps4", _lo) > 0 || string_pos("ps5", _lo) > 0
					|| string_pos("wireless controller", _lo) > 0)
					_d.kind = "ps";
				else if (string_pos("switch", _lo) > 0 || string_pos("joy", _lo) > 0
					|| string_pos("pro controller", _lo) > 0)
					_d.kind = "switch";
				else _d.kind = "generic";
				// we own the response curve - GM's built-in deadzone
				// would stack under ours and double-dip the low range
				gamepad_set_axis_deadzone(_i, 0);
				array_push(_p.log, "found " + string(_i) + ": " + _d.name);
				if (_p.active < 0) _p.active = _i;
			} else if (!_c && _d.conn) {
				array_push(_p.log, "lost " + string(_i) + ": " + _d.name);
				if (_p.active == _i) _p.active = -1;
			}
			_d.conn = _c;
			if (_c) _p.n_conn++;
		}
		while (array_length(_p.log) > 30) array_delete(_p.log, 0, 1);
	}
	_p.scan_t--;

	// ---- rebind capture ----
	if (_p.rebind != "") {
		if (_p.rebind_guard > 0) { _p.rebind_guard--; exit; }
		var _hit = undefined;
		for (var _i = 0; _i < 12 && _hit == undefined; _i++) {
			if (!_p.devs[_i].conn) continue;
			for (var _b = 0; _b < array_length(_p.btns); _b++) {
				if (gamepad_button_check_pressed(_i, _p.btns[_b])) {
					// triggers store as "t" (analog read), rest as "b"
					var _isv = (_p.btns[_b] == gp_shoulderlb
						|| _p.btns[_b] == gp_shoulderrb);
					_hit = { k : _isv ? "t" : "b", v : _p.btns[_b] };
					_p.active = _i;
					break;
				}
			}
			if (_hit == undefined)
			for (var _a2 = 0; _a2 < array_length(_p.axes); _a2++) {
				var _av = gamepad_axis_value(_i, _p.axes[_a2]);
				if (abs(_av) > .65) {
					_hit = { k : "a", v : _p.axes[_a2], s : sign(_av) };
					_p.active = _i;
					break;
				}
			}
		}
		if (_hit != undefined) {
			var _a = _p.acts[$ _p.rebind];
			if (_p.rebind_i >= array_length(_a.binds))
				array_push(_a.binds, _hit);
			else
				_a.binds[_p.rebind_i] = _hit;
			array_push(_p.log, _p.rebind + " -> " + pad_glyph(_p.rebind, _p.rebind_i));
			_p.rebind = "";
			pad_binds_save();
		}
		exit; // armed frames never drive actions
	}

	// ---- per-action state ----
	for (var _i = 0; _i < array_length(_p.act_names); _i++) {
		var _nm = _p.act_names[_i];
		var _a = _p.acts[$ _nm];
		var _s = _p.state[$ _nm];
		_s.prev = _s.down;

		if (_a.kind == "s") {
			// stick: strongest connected stick wins, radial deadzone
			var _hx = (_a.src == "l") ? gp_axislh : gp_axisrh;
			var _hy = (_a.src == "l") ? gp_axislv : gp_axisrv;
			var _bx = 0, _by = 0, _bl = 0;
			for (var _di = 0; _di < 12; _di++) {
				if (!_p.devs[_di].conn) continue;
				var _x = gamepad_axis_value(_di, _hx);
				var _y = gamepad_axis_value(_di, _hy);
				var _l = sqrt(_x * _x + _y * _y);
				if (_l > _bl) {
					_bl = _l; _bx = _x; _by = _y;
					if (_l > _p.dz) _p.active = _di;
				}
			}
			if (_bl <= _p.dz) {
				_s.x = 0; _s.y = 0; _s.val = 0; _s.down = false;
			} else {
				var _t = min((_bl - _p.dz) / max(_p.dz_hi - _p.dz, .01), 1);
				_s.x = _bx / _bl * _t;
				_s.y = _by / _bl * _t;
				_s.val = _t;
				_s.down = (_t > .5);
			}
			continue;
		}

		// digital / value: any bind on any connected device
		var _dn = false, _vv = 0;
		for (var _di = 0; _di < 12; _di++) {
			if (!_p.devs[_di].conn) continue;
			for (var _bi = 0; _bi < array_length(_a.binds); _bi++) {
				var _b = _a.binds[_bi];
				if (_b.k == "b") {
					if (gamepad_button_check(_di, _b.v)) {
						_dn = true;
						_vv = max(_vv, gamepad_button_value(_di, _b.v));
						if (!_s.prev) _p.active = _di;
					}
				} else if (_b.k == "t") {
					var _tv = gamepad_button_value(_di, _b.v);
					_vv = max(_vv, _tv);
					if (_tv > _p.digi_thr) {
						_dn = true;
						if (!_s.prev) _p.active = _di;
					}
				} else { // "a": an axis half
					var _av = gamepad_axis_value(_di, _b.v) * _b.s;
					_vv = max(_vv, max(_av, 0));
					if (_av > _p.digi_thr) {
						_dn = true;
						if (!_s.prev) _p.active = _di;
					}
				}
			}
		}
		_s.down = _dn;
		_s.val = _vv;
	}
}
