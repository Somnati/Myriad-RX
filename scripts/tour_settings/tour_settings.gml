/// tour_settings - THE SETTINGS SCREEN  (engine/settings)
/// A TOUR SCRIPT: comments only, nothing runs.

// ========================== THE IDEA ================================
// The screen owns NO state. Every row binds to the real global
// through two closures - get() reads it, set(v) writes it - so a
// toggle can never disagree with the setting it shows (a load, a
// reset, anything else flipping the global: the knob just follows).
// Rows are DECLARED in settings_content as calls; syst_settings draws
// them, spawns the widgets, scrolls, saves on change.

// ========================== THE FILES ===============================
//   settings_content   EDIT HERE. The header carries the full how-to.
//                      settings_section("display", col) starts a tab;
//                      settings_toggle / settings_pill / settings_
//                      slider / settings_info / settings_action add a
//                      row under it. Runs EVERY step in the
//                      controller's scope, so rows can appear
//                      conditionally (desktop-only, mobile-only).
//   settings_defaults  the "reset settings" action: every default.
//   handle_settings    (engine/save) the ini line per setting.
//   syst_settings      the controller. LEFT RAIL of tabs, content for
//                      the active tab only, widgets pooled by key and
//                      CHAPERONED (placed when their row is on screen,
//                      parked at -1000 when not), the keep/revert
//                      __confirm popup for risky display changes
//                      (10 s auto-revert), a dirty debounce that
//                      writes settings.ini after knob drags settle.
//   settings_section / _toggle / _pill / _slider / _info / _action
//                      the row builders (push into the controller).
//   obj_set_toggle / obj_set_slider / obj_set_radio   the live
//                      widgets, children of par_toggle / par_slider /
//                      par_toggle_single with bind_get / bind_set.
//   par_toggle, par_toggle_single, par_slider   the base widgets any
//                      screen may reuse (obj_set_slider IS the house
//                      slider - reuse it, don't draw a new one).
//   obj_pillbox + do_pillbox / pillbox_init / set_pill   the house
//                      DROPDOWN: the owner calls pillbox_init(), then
//                      set_pill(name, {val, col}) per option, then
//                      do_pillbox(x, y); the pick lands owner-side in
//                      _pselid + pill_kind. Used by settings_pill.
//   spr_ui_toggle, spr_ui_dragger, spr_toggle_single   widget art.
//   rm_settings        the room: header + obj_set_landscape +
//                      syst_settings. Nothing else.

// ================== ADDING A SETTING WITH A NEW GLOBAL ==============
//   1. its boot default in system's Create (the SETTINGS block)
//   2. its row in settings_content
//   3. its reset line in settings_defaults
//   4. its handle() line in handle_settings
// Four touchpoints, and the widget, layout, scrolling and saving are
// automatic.

// ========================= HOW DE DID IT ============================
// One object per option (obj_options_toggle_darktheme, _sound,
// _vibrations, ...) placed in the options panel, each drawing and
// saving itself. RX: one line per option.

// ============================ TRAPS =================================
//   - GML function literals DON'T capture locals. Bake a per-option
//     value with method({ v : 0 }, function() { ... v ... }).
//   - Drawing stacks by DEPTH: rows in the controller's Draw_0,
//     widgets at depth-1, the title strip via obj_draw_proxy at -2,
//     the menu at -520 over all of it. Draw End paints over the open
//     menu; Draw Begin is painted over by the room background. Only
//     the help/confirm popups use Draw End, hidden under the menu.
