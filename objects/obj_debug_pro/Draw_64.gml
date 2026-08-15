if (!enabled) exit;

draw_set_font(fnt);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

// ---- panel ----
draw_set_alpha(0.78);
draw_set_color(c_black);
draw_rectangle(0, 0, panel_w, gui_h, false);
draw_set_alpha(1);
draw_set_color(c_white);

// ---- header, always visible regardless of page ----
draw_text(pad, pad, "fps " + string(fps) + " | " + room_get_name(room));
draw_line(0, header_h, panel_w, header_h);
draw_line(sidebar_w, header_h, sidebar_w, gui_h);

// ---- sidebar buttons ----
for (var i = 0; i < array_length(pages); i++) {
    var _by = header_h + pad + i * (line_h + 4);
    if (i == page_index) {
        // active page: white fill, black text
        draw_rectangle(pad - 1, _by - 1, sidebar_w - pad, _by + line_h - 1, false);
        draw_set_color(c_black);
        draw_text(pad + 1, _by, pages[i].name);
        draw_set_color(c_white);
    } else {
        draw_text(pad + 1, _by, pages[i].name);
    }
}

// ---- LOG stick-to-bottom, resolved before the page draws ----
if (pages[page_index].name == "LOG" && stick_bottom
&&  variable_global_exists("__dbgpro_log")) {
    var _total = array_length(global.__dbgpro_log) + 1;  // +1 header row
    __set_scroll(max(0, _total - __vis_rows()));
}

// ---- content ----
click_rects = [];
__rows = 0;
pages[page_index].draw();

// ---- record this page's max scroll for the Step event,
// and clamp in case content shrank (collapsed object, etc.) ----
var _max = max(0, __rows - __vis_rows());
variable_struct_set(scroll_max, pages[page_index].name, _max);
if (__get_scroll() > _max) __set_scroll(_max);

// ---- memory cache, refreshed twice a second, SYSTEM page only ----
if (pages[page_index].name == "SYSTEM") {
    mem_timer--;
    if (mem_timer <= 0) {
        mem_cache = debug_event("DumpMemory", true);
        mem_timer = 30;
    }
}

// leave draw state clean for whoever draws next
draw_set_color(c_white);
draw_set_alpha(1);
