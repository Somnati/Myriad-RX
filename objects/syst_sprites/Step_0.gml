sprites_init();
sprites_tick();

// a body for every sprite while the money room is up - and ONE proxy
// over all of them (depth -70) for their cards and bubbles, so a card
// never sits behind a neighbour's body
if (in_room(rm_clicker)) {
	if (!variable_instance_exists(id, "over_px") || !instance_exists(over_px)) {
		over_px = create_obj(0, 0, obj_draw_proxy);
		over_px.owner = id;
		over_px.depth = -70;
		over_px.fn    = function() { with (obj_blob) if (!tile_room) __draw_over(); };
	}
	// ...and one over the tile panel for the crew that lives in it
	if (!variable_instance_exists(id, "over_px2") || !instance_exists(over_px2)) {
		over_px2 = create_obj(0, 0, obj_draw_proxy);
		over_px2.owner = id;
		over_px2.depth = -513;   // (with the crew: under the menu's blur and drawer)
		over_px2.fn    = function() { with (obj_blob) if (tile_room) __draw_over(); };
	}
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
