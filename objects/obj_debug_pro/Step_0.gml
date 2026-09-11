// ---- the switch: system.debug, THE one flag ----
// ⚖️ (his report, 2026-09-11: "the debug mode option doesn't do
// anything"). F1 used to toggle two flags at once - system.debug in
// system's Step and this object's own `enabled` here - which worked
// only because both heard the same key. The settings toggle flips
// system.debug alone, so this object was created with enabled false
// and drew nothing. Now `enabled` simply FOLLOWS system.debug; F1
// lives in system's Step and nowhere else.
if (enabled != system.debug) {
    enabled = system.debug;
    edit_index = -1;
}

input_blocked = enabled && (edit_index >= 0);
if (!enabled) exit;

var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);

// ---- inline edit session (GLOBALS page) ----
if (edit_index >= 0) {
    // keyboard_string handles backspace on its own, we just cap it
    keyboard_string = string_copy(keyboard_string, 1, 40);
    edit_text = keyboard_string;

    if (keyboard_check_pressed(vk_enter)) {
        var _e = global.__dbgpro_watch[edit_index];
        __set_global(_e.name, edit_text);
        edit_index = -1;
    }
    if (keyboard_check_pressed(vk_escape)) edit_index = -1;
}

// ---- mouse wheel scrolling, only while over the panel ----
// clamped here against last frame's recorded max, so the scroll
// value can never overshoot into a blank frame
var _wheel = mouse_wheel_down() - mouse_wheel_up();
if (_wheel != 0 && _mx < panel_w) {
    var _new = clamp(__get_scroll() + _wheel * 3, 0, __get_scroll_max());
    __set_scroll(_new);
    if (pages[page_index].name == "LOG") {
        // scrolling up detaches the log from the bottom,
        // hitting the bottom again re-latches it
        if (_wheel < 0) stick_bottom = false;
        else if (_new >= __get_scroll_max()) stick_bottom = true;
    }
}

// ---- clicks ----
if (mouse_check_button_pressed(mb_left)) {

    // sidebar page buttons
    for (var i = 0; i < array_length(pages); i++) {
        var _by = header_h + pad + i * (line_h + 4);
        if (_mx >= pad && _mx <= sidebar_w - pad
        &&  _my >= _by - 1 && _my <= _by + line_h) {
            page_index = i;
            edit_index = -1;
        }
    }

    // content rows. hit regions were captured during the last draw,
    // which means clicks land one frame late. for a debug tool,
    // nobody will ever feel it
    for (var i = 0; i < array_length(click_rects); i++) {
        var _r = click_rects[i];
        if (_mx >= _r.x1 && _mx <= _r.x2 && _my >= _r.y1 && _my <= _r.y2) {
            switch (_r.kind) {
                case "global":
                    edit_index = _r.index;
                    keyboard_string = "";   // fresh edit session
                    edit_text = "";
                break;
				case "object":
					expanded_obj = (expanded_obj == _r.index) ? -1 : _r.index;
					inspect_index = 0;
				break;
				case "cycle":
					inspect_index = (inspect_index + 1) mod instance_number(_r.index);
				break;

            }
            break;
        }
    }
}

