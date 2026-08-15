//draw_surface_stretched(application_surface, 0, 0, window_get_width(), window_get_height());

// the fps readout (settings > display > show fps): syst_display is
// persistent, so this one drawer covers every room. gui space = room
// coords, bottom-left, out of everything's way
if (variable_global_exists("show_fps") && g.show_fps) {
	draw_set_font(fnt);
	draw_set_halign(fa_left);
	draw_set_color(c_white);
	draw_set_alpha(.55);
	draw_text(3, display_get_gui_height() - 10, string(fps) + " fps");
	draw_set_alpha(1);
}
