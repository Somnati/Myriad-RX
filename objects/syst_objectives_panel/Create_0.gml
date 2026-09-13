/// syst_objectives_panel - THE OBJECTIVES, in full (his spec,
/// 2026-09-13: "a more detailed version of that on the hamb menu
/// page"). Every objective of the chain as a card, in order: the done
/// ones one green line each, the CURRENT one open - its steps behind
/// their boxes, what it unlocks under them - and the ones still ahead
/// dimmed to a name. On the overlay contract every panel shares (oa /
/// closing, ui_overlay lists it, ui_blur_tick softens the room behind,
/// the burger's X and escape close it); the list scrolls in pixels on
/// the house bar (the offline log's frame). Pure view over g.obj -
/// objective_tick is the runner, objective_config the words.

objective_init();
depth   = -510;   // over the room and its drawers, under the menu (-520) and the header (-1000)
oa      = 0;
closing = false;

hh     = instance_exists(obj_ui_header) ? obj_ui_header.bar_h : 16;
land   = (room_width > 300);
list_y = hh + 16;                                   // under the title strip
sbw    = sprite_get_width(spr_scrollbar);
cx     = 4;                                         // the cards' x
cw     = room_width - cx - sbw - 5;                 // ...and width
dim    = rgb(120, 130, 150);
scroll = 0;

RH_ROW  = 14;   // a done / upcoming objective's one line
RH_HDR  = 14;   // the current one's name line
RH_GAP  = 4;    // between cards
RH_NOTE = 10;   // the reward line

// THE HOUSE SCROLLBAR (pixel mode against the cards' stacked height)
sb = create_obj(room_width - sbw - 1, list_y, obj_scrollbar);
sb.i = scrl_objectives;
sb.depth = depth - 1;
sb.ui_layer = ui_layer_popup;
sb.in_menu = true;
sb.wheel_x1 = 0; sb.wheel_x2 = room_width;
sb.image_yscale = (room_height - list_y) / sprite_get_height(spr_scrollbar);
sb.col = c_gold;

/// @func __rows()
/// @desc THE ROW MODEL, rebuilt each frame (a dozen objectives - cheap).
///       kinds: done {o}, cur_hdr {o}, step {o, i, txt, h, done},
///       note {txt}, ahead {o}, gap. Each carries its height, so the
///       draw and the scroll range agree by construction.
__rows = function() {
	var _out = [];
	var _c = objective_config();
	var _ob = g.obj;
	draw_set_font(fnt);
	var _tw = cw - 30;
	for (var _i = 0; _i < array_length(_c); _i++) {
		var _o = _c[_i];
		if (_ob.done[$ _o.key] ?? false) { array_push(_out, { kind : "done", o : _o, h : RH_ROW }); continue; }
		if (_i == _ob.i) {
			array_push(_out, { kind : "cur_hdr", o : _o, h : RH_HDR });
			for (var _j = 0; _j < array_length(_o.steps); _j++) {
				var _t = _o.steps[_j].txt;
				array_push(_out, { kind : "step", o : _o, i : _j, txt : _t,
					h : string_height_ext(_t, 9, _tw) + 3, done : objective_step_done(_o, _j) });
			}
			if (variable_struct_exists(_o, "reward_txt") && _o.reward_txt != "")
				array_push(_out, { kind : "note", txt : "unlocks: " + _o.reward_txt, h : string_height_ext("unlocks: " + _o.reward_txt, 9, _tw) + 4 });
			array_push(_out, { kind : "gap", h : RH_GAP });
			continue;
		}
		array_push(_out, { kind : "ahead", o : _o, h : RH_ROW });
	}
	if (_ob.i >= array_length(_c))
		array_push(_out, { kind : "note", txt : "every objective complete", h : RH_NOTE + 4 });
	return _out;
};

__content_h = function() {
	var _r = __rows();
	var _h = 8;
	for (var _i = 0; _i < array_length(_r); _i++) _h += _r[_i].h;
	return _h;
};
__scroll_max = function() {
	return max(0, __content_h() - (room_height - list_y - 4));
};
