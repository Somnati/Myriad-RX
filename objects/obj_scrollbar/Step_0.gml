/// NOTE: every input_free here reads through `in_menu` - see the
/// Create. A bar inside the settings overlay or the menu drawer sits
/// ABOVE the block those raise, and a bare check would have it refuse
/// its own clicks the moment its owner went modal.
/// @description SYSTEM
stic -= 1 * delta;
sh = floor(sprite_height);

// disablers
//if instance_exists(obj_devnotes) enabled = false;


/// framework

// input \\
//if i = 1 {mn = instance_number(obj_ability_slot)-3; input = global.ability_page; slot_height = (sprite_get_height(spr_ability_slot)+2);}
/*
if i = 1 {mn = instance_number(obj_ability_slot)-3; input = global.ability_page; slot_height = (sprite_get_height(spr_ability_slot)+2);}
if i = 2 if instance_exists(obj_upgrades_stats){mn = (room_height-obj_upgrades_stats.ystart)+4; input = global.upgrades_stats_page; slot_height = 1; depth = obj_upgrades_stats.depth-1;}
if i = 3 if instance_exists(obj_devnotes) {mn = (room_height-obj_devnotes.ystart)+4; input = global.devnotes_page; slot_height = 1; depth = obj_devnotes.depth-1;}
if i = 4 if not instance_exists(obj_statistics_infodraw) if instance_exists(obj_drag_goals) if g.goalcat != 3{mn = obj_drag_goals.mn[g.goalcat]; input = obj_drag_goals.spg[g.goalcat]; slot_height = 1; depth = obj_goal_title.depth; mx = obj_drag_goals.mx[g.goalcat];};
if i = 4 if instance_exists(obj_statistics_infodraw) {mn = obj_statistics_infodraw.mn-1; input = obj_statistics_infodraw.mp; slot_height = obj_statistics_infodraw.h;}
if i = 5 if instance_exists(obj_refinery_stats){mn = (room_height-obj_refinery_stats.ystart)+4; input = global.refinery_stats_page; slot_height = 1; depth = obj_refinery_stats.depth-1;}
if i = 6 if instance_exists(obj_equipment_stats){mn = ((syst_handle_equipment.y)-obj_equipment_stats.ystart)+4; input = global.equipment_stats_page; slot_height = 1; depth = obj_equipment_stats.depth-1;}
*/
// (MYRIAD RX: engine lanes only - statistics + settings. a rebuilt DE
// room that scrolls adds its lane here + Step_2, same pattern.)

if i = scrl_statistics
if instance_exists(syst_statistics_v2) {
	mn = syst_statistics_v2.full_rows; // rows that FIT - ceil left the last row unreachable
	mx = syst_statistics_v2.mx;
	input = g.stats_page;
	slot_height = syst_statistics_v2.row_h;
	depth = syst_statistics_v2.depth - 1;
}

if i = scrl_settings
if instance_exists(syst_settings) {
	mn = syst_settings.full_rows;
	mx = syst_settings.mx;
	input = g.settings_page;
	slot_height = syst_settings.row_h;
	depth = syst_settings.depth - 3; // above widgets (-1) AND the strip
		// proxy (-2); the settings pillbox rides at -4, menu -520 tops all
}



// THE ABILITY DECK (2026-09-11): the room spawned this bar from day
// one but never gave it a lane, so the list past the thirteenth row
// was unreachable - and now it is twice as long
if i = scrl_abilitydeck
if instance_exists(syst_rm_ability) {
	mn = syst_rm_ability.visible_rows;
	mx = syst_rm_ability.mx;
	input = g.ability_page;
	slot_height = syst_rm_ability.row_h;
	depth = syst_rm_ability.depth - 1;
}

if i = scrl_stats_rail
if instance_exists(syst_statistics_v2) {
	// PIXEL MODE: the rail's tabs, 19px each, against the band under the strip
	mn = room_height - syst_statistics_v2.list_y;
	mx = array_length(syst_statistics_v2.sections) * 19 + 6;
	input = syst_statistics_v2.rail_scroll;
	slot_height = 1;
	depth = syst_statistics_v2.depth - 3;
}

if i = scrl_faq
if instance_exists(syst_faq) {
	// PIXEL MODE: the cards' stacked height against the band
	mn = room_height - syst_faq.list_y - 4;
	mx = syst_faq.__content_h();
	input = syst_faq.scroll;
	slot_height = 1;
	depth = syst_faq.depth - 1;
}

if i = scrl_exped_log
if instance_exists(syst_exped_panel) {
	// PIXEL MODE: the diary's stacked height against its band
	mn = syst_exped_panel.__log_band_h();
	mx = syst_exped_panel.__log_content_h();
	input = syst_exped_panel.log_scroll;
	slot_height = 1;
	depth = syst_exped_panel.depth - 1;
}

if i = scrl_changelog
if instance_exists(syst_changelog) {
	mn = room_height - syst_changelog.list_y - 4;
	mx = syst_changelog.__content_h();
	input = syst_changelog.scroll;
	slot_height = 1;
	depth = syst_changelog.depth - 1;
}

if i = scrl_offlog
if instance_exists(syst_offlog) {
	// PIXEL MODE: the runs' stacked height against the band
	mn = room_height - syst_offlog.list_y - 4;
	mx = syst_offlog.__content_h();
	input = syst_offlog.scroll;
	slot_height = 1;
	depth = syst_offlog.depth - 1;
}

if i = scrl_objectives
if instance_exists(syst_objectives_panel) {
	// PIXEL MODE: the cards' stacked height against the band
	mn = room_height - syst_objectives_panel.list_y - 4;
	mx = syst_objectives_panel.__content_h();
	input = syst_objectives_panel.scroll;
	slot_height = 1;
	depth = syst_objectives_panel.depth - 1;
}

if i = scrl_autom
if instance_exists(syst_automation_panel) {
	// ROW MODE, fractional: the page's rows against the rows that fit
	mn = syst_automation_panel.__rows_fit();
	mx = syst_automation_panel.rows_n;
	input = syst_automation_panel.scroll[syst_automation_panel.tab];
	slot_height = syst_automation_panel.row_p;
	depth = syst_automation_panel.depth - 1;
}

if i = scrl_menu2
if instance_exists(syst_menu2) {
	// PIXEL MODE: slot_height 1, so input/ty are px rather than rows.
	// The drawer scrolls a content height, and it slides - so x has to
	// follow panel_x every frame (syst_menu2's Step does that).
	mn = syst_menu2.scr_band;
	mx = syst_menu2.scr_ch;
	input = syst_menu2.scr;
	slot_height = 1;
	depth = syst_menu2.depth - 1;
}


//if mx < mn mx = mn;// disable to enable fall effect

//bar sprite
if mx > mn bar_height = move_to(bar_height, clamp_min(sh / (1 + (mx - mn)), 25), 5); // bar size
if mx > mn bar_y = clamp_min(move_to(bar_y, (sh - (bar_height)) * (input / (mx - mn)), 5), 0); // bar y pos

if mx > mn
if enabled = true {
	balpha = move_to(balpha, 1, 5);
}
if mx <= mn
or enabled = false
or stic < 0 {
	balpha = move_to(balpha, 0, 5);
}



//dragger
// (mouse_over() is arbitrated, so a NEW grab can't start behind an
// open menu/popup - the input_free drop releases a grab that was
// already held when the blocker came up)
if selected was_sel = true;             // see the Create: the latch
if not touching_screen was_sel = false; // outlives the release frame
if mouse_check_button_released(mb_left) selected = false
if not input_free(in_menu ? ui_layer_menu : 0) selected = false;
if mouse_over()
if mouse_check_button_pressed(mb_left)
selected = true;

//  apply dragged input if SELECTED
if selected {
	input = move_to(input, clamp(((((mousey - y) - (bar_height / 2)) / (sh - bar_height)) * (mx - mn)), 0, mx - mn), 5); // gets module page
	ty = input * slot_height;
	ty_speed_actual = 0;
	ty_speed = 0; // stops movement
	stic = tsec * 3;
}

//  apply touch  movement if NOT SELECTED
if not selected
//if ty_speed != 0
{
	input = ty / slot_height;
}




// output \\
if i = scrl_statistics g.stats_page = clamp_min(input, 0);
if i = scrl_settings g.settings_page = clamp_min(input, 0);
if i = scrl_abilitydeck if instance_exists(syst_rm_ability) g.ability_page = clamp_min(input, 0);
if i = scrl_menu2 if instance_exists(syst_menu2) syst_menu2.scr = clamp_min(input, 0);
if i = scrl_stats_rail if instance_exists(syst_statistics_v2) syst_statistics_v2.rail_scroll = clamp_min(input, 0);
if i = scrl_faq if instance_exists(syst_faq) syst_faq.scroll = clamp_min(input, 0);
if i = scrl_changelog if instance_exists(syst_changelog) syst_changelog.scroll = clamp_min(input, 0);
if i = scrl_exped_log if instance_exists(syst_exped_panel) syst_exped_panel.log_scroll = clamp_min(input, 0);
if i = scrl_offlog if instance_exists(syst_offlog) syst_offlog.scroll = clamp_min(input, 0);
if i = scrl_objectives if instance_exists(syst_objectives_panel) syst_objectives_panel.scroll = clamp_min(input, 0);
if i = scrl_autom if instance_exists(syst_automation_panel) syst_automation_panel.scroll[syst_automation_panel.tab] = clamp_min(input, 0);
//if in_room(rm_modules) global.module_page = clamp_min(input,0);
/*
if i = 4 if instance_exists(obj_statistics_infodraw)  obj_statistics_infodraw.mp = clamp_min(input,0);
if i = 1 global.ability_page = clamp_min(input,0);
if i = 2 global.upgrades_stats_page = clamp_min(input,0);
if i = 3 global.devnotes_page = clamp_min(input,0);
if i = 4 if not instance_exists(obj_statistics_infodraw) if instance_exists(obj_drag_goals) obj_drag_goals.spg[g.goalcat] = clamp_min(input,0);
if i = 5 global.refinery_stats_page = clamp_min(input,0);
if i = 6 g.equipment_stats_page = clamp_min(input,0);
*/












///touchscreen


//enable touch
//never while the bar itself is grabbed: touch_y is start-minus-current
//(positive when dragging UP), so a right-edge bar inside the touch
//region fed BOTH drag paths with opposite signs and the release
//snapped the list to the far end
if touch_scroll                           // owners with their own drag opt out
if input_free(in_menu ? ui_layer_menu : 0) // the list behind an open menu/popup must not scroll
if touching_screen
if selected = false
if was_sel = false                        // and not on the release frame
if check_touch_bounds(touch_x_, touch_y_, sprite_width, y, room_width, ystart + sh)
if touching = false
if mx > mn {
	touching = true;
	ty_ = ty;
}

//disable touch
if not touching_screen or enabled = false or not input_free(in_menu ? ui_layer_menu : 0) {
	touching = false;
}

//set touch vars
if touching = true {
	ty_friction = ty_friction_;
	stic = tsec * 3;
	typrevious = ty;
	ty = ty_ + touch_y;
	if touch_dragdist > 8
	ty_speed_actual = move_to(ty_speed_actual, point_distance(0, typrevious, 0, ty) * (((point_direction(0, typrevious, 0, ty) - 90) / (45)) - 1), 5);

}

//pc scroll
if os_type != os_android
if enabled
if (wheel_x1 < 0 || (mouse_x >= wheel_x1 && mouse_x < wheel_x2))   // the owner's zone, if it set one
if input_free(in_menu ? ui_layer_menu : 0) { // wheel is unowned input: gate it or it scrolls behind menus
	// 2.5 a notch, halved from 5 (his call): one wheel click was moving
	// most of a short list at once
	if mouse_wheel_up() {
		ty_speed_actual -= 2.5;
		ty_friction = ty_mouse_friction;
	}
	if mouse_wheel_down() {
		ty_speed_actual += 2.5;
		ty_friction = ty_mouse_friction;
	}
}

//friction vars
if touching = false {
	ty_speed = ty_speed_actual;
	if ty_speed_actual > (ty_speed_max * delta) ty_speed = ty_speed_max * delta;
	if ty_speed_actual < -(ty_speed_max * delta) ty_speed = -ty_speed_max * delta;
	ty += ty_speed;
	ty_speed_actual = ty_speed_actual * (1 - (ty_friction * delta));
	if ty_speed_actual <= .05 and ty_speed_actual >= -.05 ty_speed_actual = 0;
	if ty_speed != 0 {
		if ty_speed < 0 ty_dir = -1;
		if ty_speed > 0 ty_dir = 1;
	}

	if ty_speed = 0 {
		if ty_dir = 1
		if ty != ceil(ty) ty = move_to(ty, ceil(ty), 10);
		if ty_dir = -1
		if ty != floor(ty) ty = move_to(ty, floor(ty), 10);
	}
}

ty = clamp(ty, 0, (mx - mn) * slot_height); //clamp touch movement

if ty_speed != 0 stic = tsec * 3;

if mx <= mn
ty = 0;