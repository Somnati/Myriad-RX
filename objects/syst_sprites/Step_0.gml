sprites_init();
sprites_tick();

// a body for every sprite while the money room is up
if (in_room(rm_clicker)) {
	for (var _i = 0; _i < array_length(g.sprites); _i++) {
		var _s = g.sprites[_i];
		if (variable_struct_exists(_s, "view") && instance_exists(_s.view)
		&& _s.view.sid == _s.id) continue;
		var _b = create_obj(room_width * _s.fx, room_height * _s.fy, obj_blob);
		_b.s   = _s;
		_b.sid = _s.id;
		_s.view = _b;
	}
}
