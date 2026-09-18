enabled = false;

// ---- layout constants (GUI space, 480x270) ----
line_h    = 9;     // 7px glyphs + 2px breathing room
pad       = 3;
header_h  = 13;    // always-visible fps / room bar
sidebar_w = 58;
panel_w   = 300;   // leaves the right side of the game visible
gui_h     = 270;
content_x = sidebar_w + pad * 2;
content_y = header_h + pad;

// ---- state ----
scroll       = {};    // per-page scroll offsets, keyed by page name
scroll_max   = {};    // per-page max offsets, recorded each draw
stick_bottom = true;  // LOG follows newest entries until you scroll up
click_rects  = [];    // clickable row regions, rebuilt every draw
edit_index   = -1;    // GLOBALS row currently being edited, -1 = none
edit_text    = "";
expanded_obj = -1;    // OBJECTS row currently expanded, -1 = none
mem_cache    = undefined;
mem_timer    = 0;

inspect_index = 0;   // which instance of the expanded object we're viewing

// gameplay code can check this to ignore keys while you're typing
input_blocked = false;

// ---- internal draw cursor ----
__rows = 0;
// ---- THE PHASE TIMER's book (q222): { avg (an ease over ~30 frames), max (the worst of the last sixty), maxw (the window's running worst), n } a phase
prof = { frame : { avg : 0, max : 0, maxw : 0, n : 0 }, step : { avg : 0, max : 0, maxw : 0, n : 0 }, draw : { avg : 0, max : 0, maxw : 0, n : 0 }, gui : { avg : 0, max : 0, maxw : 0, n : 0 } };
__prof_take = function(_k, _us) {
	var _p = prof[$ _k];
	_p.avg = lerp(_p.avg, _us, .05);
	_p.maxw = max(_p.maxw, _us);
	_p.n += 1;
	if (_p.n >= 60) { _p.max = _p.maxw; _p.maxw = 0; _p.n = 0; }
};

// ------------------------------------------------------------
// internal helpers, all methods on this object.
// nothing here depends on any outside script
// ------------------------------------------------------------

/// pretty-prints any value for display
__valstr = function(_v) {
    if (is_undefined(_v)) return "undefined";
    if (is_string(_v))    return "\"" + _v + "\"";
    return string(_v);
};

/// strips an optional "global." prefix
__strip = function(_name) {
    if (string_copy(_name, 1, 7) == "global.") return string_delete(_name, 1, 7);
    if (string_copy(_name, 1, 2) == "g.")      return string_delete(_name, 1, 2);
    return _name;
};

/// walks a dotted path like "g.rarity_rate" or "syst_display.border"
/// down to the struct that holds the final key.
/// holder == undefined means it's a plain global like "player_speed"
__resolve = function(_name) {
    var _n = __strip(_name);
    var _parts = string_split(_n, ".");
    var _count = array_length(_parts);

    if (_count == 1) return { ok: true, holder: undefined, key: _n };

    if (!variable_global_exists(_parts[0])) return { ok: false, holder: undefined, key: _n };
    var _cur = variable_global_get(_parts[0]);

    // walk intermediate structs for deeper paths like "g.audio.volume"
    for (var i = 1; i < _count - 1; i++) {
        if (!is_struct(_cur) || !variable_struct_exists(_cur, _parts[i])) {
            return { ok: false, holder: undefined, key: _n };
        }
        _cur = variable_struct_get(_cur, _parts[i]);
    }

    if (!is_struct(_cur)) return { ok: false, holder: undefined, key: _n };
    return { ok: true, holder: _cur, key: _parts[_count - 1] };
};

__get_global = function(_name) {
    var _r = __resolve(_name);
    if (!_r.ok) return undefined;
    if (is_undefined(_r.holder)) {
        if (!variable_global_exists(_r.key)) return undefined;
        return variable_global_get(_r.key);
    }
    if (!variable_struct_exists(_r.holder, _r.key)) return undefined;
    return variable_struct_get(_r.holder, _r.key);
};

__set_global = function(_name, _valstr) {
    var _val = _valstr;
    if (_valstr == "true")       _val = true;
    else if (_valstr == "false") _val = false;
    else {
        try { _val = real(_valstr); } catch (_e) { _val = _valstr; }
    }
    var _r = __resolve(_name);
    if (!_r.ok) return;
    if (is_undefined(_r.holder)) variable_global_set(_r.key, _val);
    else variable_struct_set(_r.holder, _r.key, _val);
};

// ------------------------------------------------------------
// scroll helpers
// ------------------------------------------------------------

__get_scroll = function() {
    var _n = pages[page_index].name;
    if (variable_struct_exists(scroll, _n)) return variable_struct_get(scroll, _n);
    return 0;
};

__set_scroll = function(_v) {
    variable_struct_set(scroll, pages[page_index].name, _v);
};

/// max scroll for the current page, as recorded by the last draw.
/// before the first draw of a page there's nothing recorded yet,
/// so 0 (no scrolling until we know the content size, one frame)
__get_scroll_max = function() {
    var _n = pages[page_index].name;
    if (variable_struct_exists(scroll_max, _n)) return variable_struct_get(scroll_max, _n);
    return 0;
};

__vis_rows = function() {
    return floor((gui_h - content_y - pad) / line_h);
};

// ------------------------------------------------------------
// row helpers. every page draws through these, which gives
// scrolling and clipping for free
// ------------------------------------------------------------

/// plain text row
row_text = function(_s) {
    var _yy = content_y + (__rows - __get_scroll()) * line_h;
    if (_yy >= content_y && _yy < gui_h - line_h) draw_text(content_x, _yy, _s);
    __rows++;
};

/// clickable row. registers a hit region consumed by the Step event
row_clickable = function(_s, _kind, _idx) {
    var _yy = content_y + (__rows - __get_scroll()) * line_h;
    if (_yy >= content_y && _yy < gui_h - line_h) {
        draw_text(content_x, _yy, _s);
        array_push(click_rects, {
            x1: content_x, y1: _yy,
            x2: panel_w - pad, y2: _yy + line_h,
            kind: _kind, index: _idx
        });
    }
    __rows++;
};

// ------------------------------------------------------------
// pages. to add a page later: write a __page_* method,
// push { name, draw } onto the array below. that's it.
// ------------------------------------------------------------

__page_system = function() {
    row_text("// SYSTEM");
    row_text("room = " + room_get_name(room));

    var _t = current_time div 1000;
    var _s = string(_t mod 60);
    if (string_length(_s) < 2) _s = "0" + _s;
    row_text("up_time = " + string(_t div 60) + ":" + _s);

    row_text("fps = " + string(fps));
    row_text("fps_real = " + string(floor(fps_real)));
    row_text("delta = " + string_format(delta_time / 1000, 1, 3) + "ms");
    row_text("instances = " + string(instance_count));
    // THE PHASES (q222): avg / worst-of-60 in ms - where a frame goes, and where a hitch was
    row_text("// PHASES  avg / worst (ms)");
    row_text("frame = " + string_format(prof.frame.avg / 1000, 1, 2) + " / " + string_format(prof.frame.max / 1000, 1, 2));
    row_text("step  = " + string_format(prof.step.avg / 1000, 1, 2) + " / " + string_format(prof.step.max / 1000, 1, 2));
    row_text("draw  = " + string_format(prof.draw.avg / 1000, 1, 2) + " / " + string_format(prof.draw.max / 1000, 1, 2));
    row_text("gui   = " + string_format(prof.gui.avg / 1000, 1, 2) + " / " + string_format(prof.gui.max / 1000, 1, 2));

    // memory, cached in the Draw GUI event twice a second.
    // DumpMemory isn't free, so it doesn't run every frame
    if (!is_undefined(mem_cache)) {
        var _mb = 1024 * 1024;
        row_text("mem_used = " + string_format(variable_struct_get(mem_cache, "totalUsed") / _mb, 1, 2) + "MB");
        row_text("mem_free = " + string_format(variable_struct_get(mem_cache, "free") / _mb, 1, 2) + "MB");
        row_text("mem_peak = " + string_format(variable_struct_get(mem_cache, "peakUsage") / _mb, 1, 2) + "MB");
    }
};

__page_display = function() {
    row_text("// DISPLAY  (w x h)");
    row_text("app_surf = " + string(surface_get_width(application_surface))
        + " x " + string(surface_get_height(application_surface)));
    row_text("window = " + string(window_get_width())
        + " x " + string(window_get_height()));
    row_text("display = " + string(display_get_width())
        + " x " + string(display_get_height()));
    row_text("fullscreen = " + string(window_get_fullscreen()));
    row_text("");
    row_text("// yours:");
    // add your own display globals here, e.g.
    // row_text("g.screen_size = " + string(g.screen_size));
    // row_text("border = " + string(syst_display.border));
};

__page_globals = function() {
    row_text("// GLOBALS  (click to edit, enter = save, esc = cancel)");
    if (!variable_global_exists("__dbgpro_watch")
    ||  array_length(global.__dbgpro_watch) == 0) {
        row_text("(nothing registered)");
        row_text("call debug_pro_watch() at game start");
        return;
    }
    var _w = global.__dbgpro_watch;
    for (var i = 0; i < array_length(_w); i++) {
        var _e = _w[i];
        if (i == edit_index) {
            // inline editor: inverted row with a blinking caret
            var _yy = content_y + (__rows - __get_scroll()) * line_h;
            if (_yy >= content_y && _yy < gui_h - line_h) {
                draw_set_color(c_white);
                draw_rectangle(content_x - 2, _yy - 1, panel_w - pad, _yy + line_h - 2, false);
                draw_set_color(c_black);
                var _caret = ((current_time div 400) % 2 == 0) ? "_" : "";
                draw_text(content_x, _yy, _e.label + " = " + edit_text + _caret);
                draw_set_color(c_white);
            }
            __rows++;
        } else {
            row_clickable(_e.label + " = " + __valstr(__get_global(_e.name)), "global", i);
        }
    }
};

__page_log = function() {
    row_text("// LOG  (wheel to scroll)");
    if (!variable_global_exists("__dbgpro_log")
    ||  array_length(global.__dbgpro_log) == 0) {
        row_text("(empty)");
        return;
    }
    var _log = global.__dbgpro_log;
    for (var i = 0; i < array_length(_log); i++) {
        var _e = _log[i];
        var _s = string(_e.t mod 60);
        if (string_length(_s) < 2) _s = "0" + _s;
        row_text("[" + string(_e.t div 60) + ":" + _s + "] " + _e.msg);
    }
};

__page_objects = function() {
    row_text("// OBJECTS  (click to expand)");
    for (var i = 0; i < 3000; i++) {
        if (!object_exists(i)) continue;
        var _n = instance_number(i);
        if (_n <= 0) continue;

        var _mark = (i == expanded_obj) ? "- " : "+ ";
        row_clickable(_mark + object_get_name(i) + "  x" + string(_n), "object", i);

        if (i == expanded_obj) {
            // instances can die between frames, keep the index legal
            inspect_index = clamp(inspect_index, 0, _n - 1);
            var _inst = instance_find(i, inspect_index);

            if (instance_exists(_inst)) {
                // cycle row: click to step to the next instance
                if (_n > 1) {
                    row_clickable("   > inst " + string(inspect_index + 1)
                        + "/" + string(_n) + "  (id " + string(_inst) + ")", "cycle", i);
                } else {
                    row_text("   inst 1/1  (id " + string(_inst) + ")");
                }

                var _names = variable_instance_get_names(_inst);
                var _total = array_length(_names);
                var _cap = min(_total, 24);
                for (var k = 0; k < _cap; k++) {
                    var _vn = _names[k];
                    row_text("   " + _vn + " = "
                        + __valstr(variable_instance_get(_inst, _vn)));
                }
                if (_total > _cap) row_text("   ...(" + string(_total - _cap) + " more)");
            }
        }
    }
};

pages = [
    { name: "SYSTEM",  draw: __page_system  },
    { name: "DISPLAY", draw: __page_display },
    { name: "GLOBALS", draw: __page_globals },
    { name: "LOG",     draw: __page_log     },
    { name: "OBJECTS", draw: __page_objects }
];
page_index = 0;



