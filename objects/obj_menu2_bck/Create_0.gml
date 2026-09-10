/// the dark backing under the menu AND under every overlay (see the
/// Draw): sits at -450, BEHIND the menu_blur layer (-500 blurs
/// everything deeper), so the gaussian smooths its banding while the
/// panel above stays sharp. ui_blur_tick keeps one alive while anything
/// is up; it self-destructs when nothing is.

depth = -450;
