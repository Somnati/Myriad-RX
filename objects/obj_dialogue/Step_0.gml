/// ============================================================
/// obj_dialogue :: STEP EVENT  (full replacement)
/// ============================================================
/// changes from your paste:
///  - CHOOSING now uses a keyboard-only confirm. a mouse click
///    can only select by landing on a row (_clicked). clicking
///    anywhere else in the world does nothing to a menu.
///  - selecting a choice arms the advance lock, same protection
///    every other transition already has.
///  - the blip countdown block is tidied into its final form
///    (the instructional comments from my snippet were still
///    living inside your loop).
///
/// CREATE EVENT must have these, check they all exist:
///   advance_delay = 250;    advance_lock = 0;
///   mouse_last_x = -1;      mouse_last_y = -1;
///   blip_counter = 0;       blip_min = 2;      blip_max = 4;
/// and dialogue_start arms the lock:
///   advance_lock = advance_delay;   // before __advance()

if (!dialogue_active) exit;

// confirm accepts keyboard or mouse, but only once the lock expires.
// this gate governs ADVANCING text. choice selection has its own rules
if (advance_lock > 0) advance_lock -= delta_time / 1000;

var _confirm_raw = keyboard_check_pressed(key_confirm)
                || mouse_check_button_pressed(mb_left);
// passive barks take NO input - time advances them (see WAITING)
var _confirm = _confirm_raw && (advance_lock <= 0) && !passive;

switch (state) {

    // --------------------------------------------------------
    case DSTATE.TYPING: {
        if (_confirm) { __instant_reveal(); advance_lock = advance_delay; break; }

        // budgeted reveal: spend this frame's time in slices so
        // actions fire at EXACTLY their character index, even if
        // the speed would otherwise overshoot them in one frame
        var _budget = delta_time / 1000000;   // seconds this frame

        while (_budget > 0 && state == DSTATE.TYPING) {

            // fire any actions due at the current position
            if (action_pos < array_length(actions)
            &&  actions[action_pos].at <= floor(reveal)) {
                var _a = actions[action_pos++];
                switch (_a.kind) {
                    case "speed":    cps       = _a.val; break;
                    case "waveamp":  wave_amp  = _a.val; break;
                    case "shakeamp": shake_amp = _a.val; break;
                    case "sound":
                        var _s = asset_get_index(_a.val);
                        if (_s >= 0) audio_play_sound(_s, 10, false);
                    break;
                    case "pause":
                        pause_timer = _a.val;
                        state = DSTATE.PAUSED;
                    break;
                }
                continue;
            }

            // reveal toward the next stop (next action or line end)
            var _next = (action_pos < array_length(actions))
                      ? actions[action_pos].at : total;
            var _need = _next - reveal;
            var _can  = _budget * cps;

            if (_can >= _need) {
                reveal += _need;
                _budget -= _need / cps;
            } else {
                reveal += _can;
                _budget = 0;
            }

            if (reveal >= total && action_pos >= array_length(actions)) {
                reveal = total;
                state = DSTATE.WAITING;
                if (passive) passive_t = passive_hold; // linger clock
            }
        }

        // voice blips: countdown re-rolled on every fire, so the
        // cadence stutters organically instead of ticking
        var _now = floor(reveal);
        for (var k = last_shown; k < _now; k++) {
            var _ch = chars[k].ch;
            if (_ch != " " && _ch != "\n") {
                blip_counter--;
                if (blip_sound != -1 && blip_counter <= 0) {
                    play_sound_ext(blip_sound, .9, 1.3, .8, 0);
                    blip_counter = max(1, round(random_range(blip_min, blip_max)));
                }
            }
        }
        last_shown = _now;
    } break;

    // --------------------------------------------------------
    case DSTATE.PAUSED: {
        if (_confirm) { __instant_reveal(); advance_lock = advance_delay; break; }
        pause_timer -= delta_time / 1000;     // microseconds -> ms
        if (pause_timer <= 0) state = DSTATE.TYPING;
    } break;

    // --------------------------------------------------------
    case DSTATE.WAITING: {
        if (passive) {
            passive_t -= delta_time / 1000;
            if (passive_t <= 0) { advance_lock = advance_delay; __advance(); }
            break;
        }
        if (_confirm) { advance_lock = advance_delay; __advance(); }
    } break;

    // --------------------------------------------------------
    case DSTATE.CHOOSING: {
        if (passive) { __close(); break; } // barks never ask questions
        var _n = array_length(choice_options);

        // ---- keyboard: navigate + confirm the highlight ----
        if (keyboard_check_pressed(key_up))   choice_index = (choice_index - 1 + _n) mod _n;
        if (keyboard_check_pressed(key_down)) choice_index = (choice_index + 1) mod _n;

        // keyboard-only confirm. the global _confirm includes mouse,
        // which would let a click ANYWHERE select the highlighted
        // option. in a menu, the mouse only speaks by pointing
        var _confirm_kb = keyboard_check_pressed(key_confirm) && (advance_lock <= 0);

        // ---- mouse: hover highlights, click-on-row selects ----
        var _mx = device_mouse_x_to_gui(0);
        var _my = device_mouse_y_to_gui(0);
        var _moved = (_mx != mouse_last_x || _my != mouse_last_y);
        mouse_last_x = _mx;
        mouse_last_y = _my;

        // same geometry the Draw GUI uses, recomputed here
        var _tx = box_x + pad + (use_portrait ? portrait_size + pad : 0);
        var _ty = box_y + pad;
		var _tw = box_w - pad * 2 - (use_portrait ? portrait_size + pad : 0);
        var _oy_base = box_y + box_h - pad - _n * line_h;
        _oy_base = max(_oy_base, _ty);

        var _clicked = false;
for (var i = 0; i < _n; i++) {
    var _y1 = _oy_base + i * line_h;

    // this option's actual pixel width, from its parsed label
    var _lc = choice_options[i].parsed;
    var _lw = 0;
    if (array_length(_lc) > 0) {
        var _end = _lc[array_length(_lc) - 1];
        _lw = _end.x + _end.w;
    }

    // hit zone hugs the label: cursor gutter, the text itself,
    // and 2px of grace so edge pixels don't feel unfair
    var _x1 = _tx + 2;              // includes the cursor square
    var _x2 = _tx + 12 + _lw + 2;   // 12 = label indent

    var _over = (_mx >= _x1 && _mx <= _x2
              && _my >= _y1 && _my <  _y1 + line_h);
    if (_over) {
        if (_moved) choice_index = i;
        if (mouse_check_button_pressed(mb_left) && advance_lock <= 0) {
            choice_index = i;
            _clicked = true;
        }
    }
}

        // ---- selection: keyboard highlight or direct click ----
        if ((_confirm_kb || _clicked) && _n > 0) {
            var _opt = choice_options[choice_index];
            choice_options = [];
            advance_lock = advance_delay;   // the selecting input doesn't
                                            // bleed into the next panel
            if (is_undefined(_opt.tree)) { __close(); break; }
            g.__ds_queue = [];
            _opt.tree();
            queue_pos = 0;
            __advance();
        }
    } break;
}
