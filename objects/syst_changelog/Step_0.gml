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
