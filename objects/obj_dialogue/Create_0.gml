/// ============================================================
/// DIALOGUE SYSTEM :: flavored choices upgrade
/// ============================================================
/// what changed:
///  - the tag parser is now its own method (__parse_text), so
///    ANYTHING can be tagged text. say lines use it, and now
///    choice labels do too: color, shake, wave all work in menus.
///  - [/color] is now a real closing tag. it returns color to
///    default without touching speed, so you no longer need
///    [reset] after every colored word. [reset] still works and
///    still resets both.
///  - moment tags (pause/speed/sound) inside choice labels are
///    parsed but dropped. a menu label has no timeline.
///
/// paste plan (Step event is UNCHANGED, leave it alone):
///   SECTION A -> replace the whole Create event
///   SECTION B -> replace the whole Draw GUI event
///   SECTION C -> replace scr_dt_example
///
/// your customizations preserved: box size, snd_matclick2,
/// full color palette, choice_keep_text.


/// ============================================================
/// SECTION A :: obj_dialogue CREATE EVENT  (full replacement)
/// ============================================================

// ------------------------------------------------------------
// CONFIGURATION, everything tweakable lives here
// ------------------------------------------------------------

// ---- box geometry (GUI space, 480x270) ----
box_w      = 400;
box_h      = 70;
box_margin = 8;
pad     = 8;      // inner padding
line_h  = 10;     // 7px glyphs + 3px leading

// ---- name plate ----
name_h  = 13;     // sits this tall, directly above the box

// ---- portrait ----
use_portrait    = false;   // toggle the left-side slot
portrait_size   = 54;      // square, fits inside box height
portrait_sprite = -1;      // set a sprite index, -1 draws an empty frame

// ---- keys ----
key_confirm = vk_enter;    // advance / instant-reveal / select
key_up      = vk_up;
key_down    = vk_down;

// ---- typewriter ----
base_cps = 30;             // characters per second, [speed=n] overrides,
                           // [reset] returns here

// ---- voice blips ----
blip_sound = snd_matclick2;  // set to a sound asset, -1 = off.
                             // swap per speaker before dialogue_start
           // play on every Nth revealed character
blip_min = 2;
blip_max = 4;
blip_counter = round(random_range(blip_min,blip_max)); 

// mouse hover only takes over when the mouse actually moves,
// so it can't fight the keyboard for the cursor
mouse_last_x = -1;
mouse_last_y = -1;

// ---- input feel ----
advance_delay = 250;    // ms the confirm input is ignored after
                        // each panel transition. absorbs double
                        // clicks and held keys
advance_lock  = 0;      // live countdown, leave at 0

// ---- text ----
text_color_default = c_white;

// ---- wave / shake feel ----

wave_speed = 0.5;          // bigger = faster ripple
wave_phase = 28;           // degrees between adjacent characters
wave_amp_base  = 2;
shake_amp_base = .7;

// choices: keep the previous line visible above the options (true)
// or clear the box and show only the options (false)
choice_keep_text = true;

// ---- box theme ----
box_col_fill    = c_black;   // box and name plate interior
box_col_border  = c_white;   // both border layers, portrait frame
box_col_accent  = c_white;   // cursor square + advance arrow
box_alpha_fill  = 1;         // interior opacity, 1 = solid

// named colors the [color] tag understands.
// values are your macros, so retuning the palette
// automatically retunes every dialogue line using it
col_names = {
    sgreen:     c_sgreen,      hred:      c_hred,
    gold:       c_gold,        horange:   c_horange,
    hpurple:    c_hpurple,     lavender:  c_lavender,
    pink:       c_pink,        sblue:     c_sblue,
    salmon:     c_salmon,      seagreen:  c_seagreen,
    steelblue:  c_steelblue,   dkblue:    c_dkblue,

    rarity_basic:     c_rarity_basic,
    rarity_common:    c_rarity_common,
    rarity_uncommon:  c_rarity_uncommon,
    rarity_rare:      c_rarity_rare,
    rarity_epic:      c_rarity_epic,
    rarity_elite:     c_rarity_elite,
    rarity_master:    c_rarity_master,
    rarity_exotic:    c_rarity_exotic,
    rarity_legendary: c_rarity_legendary,
    rarity_ancient:   c_rarity_ancient,
    rarity_cosmic:    c_rarity_cosmic,
    rarity_mythic:    c_rarity_mythic,
    rarity_divine:    c_rarity_divine,
    rarity_ultimate:  c_rarity_ultimate,

    // stock GM colors, keep whichever you'll use
    red: c_red,  blue: c_blue,  green: c_green,
    yellow: c_yellow,  gray: c_gray,  white: c_white
};

// ------------------------------------------------------------
// STATE, don't touch below here from outside
// ------------------------------------------------------------

dialogue_active = false;   // other objects read this to block input
state      = DSTATE.IDLE;
queue_pos  = 0;

// current line
chars      = [];    // per-char structs: {ch, x, line, w, wave, shake, col}
actions    = [];    // timed triggers: {at, kind, val}
action_pos = 0;
reveal     = 0;     // float, floor(reveal) = visible char count
total      = 0;
last_shown = 0;     // for blip detection
blip_count = 0;
cps        = base_cps;
pause_timer = 0;    // ms remaining in a [pause]
cur_speaker = "";

// choices
choice_options = [];
choice_index   = 0;

// ------------------------------------------------------------
// PUBLIC: start a dialogue tree
// ------------------------------------------------------------

// ---- PASSIVE mode (round 19, the bean boss barks - his call) ----
// the box runs with NO input coupling: syst_input never raises its
// block (it checks this flag), clicks/keys are ignored, a finished
// panel lingers passive_hold ms then auto-advances, and the queue
// running out closes the box like always. the spawner sets passive
// + box_w/box_h + passive_x/y BEFORE dialogue_start; __close puts
// every default back so the MODAL users (saves, city) are untouched
passive = false;
passive_hold = 1500;  // ms a finished panel lingers
passive_t = 0;
passive_x = 0;        // box top-left while passive (gui coords)
passive_y = 0;
box_w_def = box_w;
box_h_def = box_h;
border_def = box_col_border;

dialogue_start = function(_tree) {
    g.__ds_queue = [];
    _tree();                    // the tree script fills the queue
    queue_pos = 0;
    dialogue_active = true;
	advance_lock = advance_delay;
    __advance();
};

// ------------------------------------------------------------
// INTERNAL: queue playback
// ------------------------------------------------------------

/// walks the queue until it hits something that needs the screen.
/// the rule: say and choice RETURN (they need the player),
/// event BREAKS (silent, keep walking)
__advance = function() {
    while (true) {
        if (queue_pos >= array_length(g.__ds_queue)) { __close(); return; }
        var _e = g.__ds_queue[queue_pos++];
        switch (_e.type) {
            case "say":
                __start_line(_e.speaker, _e.text);
                return;
            case "choice":
                choice_options = _e.options;
                // parse every label so choices carry the tag system too.
                // moment tags in a label are meaningless, only chars kept
                for (var i = 0; i < array_length(choice_options); i++) {
                    var _p = __parse_text(choice_options[i].label);
                    choice_options[i].parsed = __layout_label(_p.chars);
                }
                choice_index = 0;
                if (!choice_keep_text) {
                    // wipe the previous line so the box belongs to the menu
                    chars = [];
                    reveal = 0;
                    cur_speaker = "";
                }
                state = DSTATE.CHOOSING;
                return;
            case "event":
                _e.fn();        // fire and keep walking
            break;
            case "end":
                __close();
                return;
        }
    }
};

__close = function() {
    dialogue_active = false;
    state = DSTATE.IDLE;
    chars = [];
    actions = [];
    choice_options = [];
    // a passive bark leaves no fingerprints on the modal system
    if (passive) {
        passive = false;
        box_w = box_w_def;
        box_h = box_h_def;
        box_col_border = border_def;
    }
};

// ------------------------------------------------------------
// INTERNAL: tag parser
// ------------------------------------------------------------
// turns raw tagged text into:
//   chars[]   - one struct per visible character, carrying its
//               own style (wave/shake/color)
//   actions[] - things that HAPPEN at a reveal index
//               (pause, speed change, sound cue)
// tags are consumed here and never reach the screen.
//
// this is now a standalone method so anything can be tagged
// text: say lines, choice labels, whatever comes later.
//
// ADDING A NEW TAG: one branch in the switch below.
// style tags set parser state, moment tags push an action.

__parse_text = function(_raw) {
    var _chars   = [];
    var _actions = [];

    // parser state
    var _wave  = 0;   // counters, so nesting the same tag can't break it
    var _shake = 0;
    var _col   = text_color_default;

    var _len = string_length(_raw);
    var _i = 1;
    while (_i <= _len) {
        var _c = string_char_at(_raw, _i);

        if (_c == "[") {
            var _close = string_pos_ext("]", _raw, _i);
            if (_close > 0) {
                var _tag = string_lower(string_copy(_raw, _i + 1, _close - _i - 1));

                // split "name=value" if present
                var _eq   = string_pos("=", _tag);
                var _name = (_eq > 0) ? string_copy(_tag, 1, _eq - 1) : _tag;
                var _val  = (_eq > 0) ? string_copy(_tag, _eq + 1, string_length(_tag) - _eq) : "";
                var _at   = array_length(_chars);   // reveal index this tag sits at

                switch (_name) {
                    // ---- style tags: change parser state ----
                    case "wave":    _wave++;  break;
                    case "/wave":   _wave = max(0, _wave - 1);  break;
                    case "shake":   _shake++; break;
                    case "/shake":  _shake = max(0, _shake - 1); break;
                    case "color":   _col = __parse_col(_val); break;
                    case "/color":  _col = text_color_default; break;  // closes color
                                                                       // without touching speed
					case "reset":
					_col = text_color_default;
					array_push(_actions, { at: _at, kind: "speed",    val: base_cps });
					array_push(_actions, { at: _at, kind: "waveamp",  val: wave_amp_base });
					array_push(_actions, { at: _at, kind: "shakeamp", val: shake_amp_base });
					break;
                    // ---- moment tags: push a timed action ----
                    case "pause":
                        array_push(_actions, { at: _at, kind: "pause", val: real(_val) });
                    break;
                    case "speed":
                        array_push(_actions, { at: _at, kind: "speed", val: max(1, real(_val)) });
                    break;
					case "waveamp":
						 array_push(_actions, { at: _at, kind: "waveamp", val: real(_val) });
					break;
					case "shakeamp":
						array_push(_actions, { at: _at, kind: "shakeamp", val: real(_val) });
					break;
                    case "sound":
                        array_push(_actions, { at: _at, kind: "sound", val: _val });
                    break;
                    // unknown tags are swallowed silently so a typo
                    // never prints brackets at the player
                }
                _i = _close + 1;
                continue;
            }
            // unclosed "[" falls through and prints literally
        }

        array_push(_chars, {
            ch: _c, x: 0, line: 0, w: 0,
            wave: (_wave > 0), shake: (_shake > 0), col: _col
        });
        _i++;
    }

    return { chars: _chars, actions: _actions };
};

/// prepares one say line for playback
__start_line = function(_speaker, _raw) {
    cur_speaker = _speaker;

    var _p  = __parse_text(_raw);
    chars   = _p.chars;
    actions = _p.actions;

    action_pos = 0;
    reveal     = 0;
    last_shown = 0;
    blip_count = 0;
    cps        = base_cps;
	wave_amp  = wave_amp_base;
	shake_amp = shake_amp_base;

    __wrap();
    total = array_length(chars);
    state = DSTATE.TYPING;
};

/// lays out a single-line char array (choice labels):
/// x offsets only, no wrapping. a label that outgrows the box
/// is an authoring problem, keep them short
__layout_label = function(_chars) {
    draw_set_font(fnt);
    var _x = 0;
    for (var i = 0; i < array_length(_chars); i++) {
        _chars[i].w = string_width(_chars[i].ch);
        _chars[i].x = _x;
        _x += _chars[i].w;
    }
    return _chars;
};

/// word wrap. assigns x and line to every char, breaking on
/// spaces, respecting explicit \n, hard-breaking words longer
/// than a whole line
__wrap = function() {
    draw_set_font(fnt);   // metrics need the font active
    var _max = box_w - pad * 2 - (use_portrait ? portrait_size + pad : 0);

    var _x = 0, _line = 0;
    var _wstart = 0;      // index where the current word began
    var _wx = 0;          // x where the current word began
    var _n = array_length(chars);

    for (var i = 0; i < _n; i++) {
        var _c = chars[i];
        _c.w = string_width(_c.ch);

        if (_c.ch == "\n") {
            _c.line = _line;
            _line++; _x = 0; _wstart = i + 1; _wx = 0;
            continue;
        }

        if (_c.ch == " ") {
            _c.x = _x; _c.line = _line;
            _x += _c.w;
            _wstart = i + 1; _wx = _x;
            continue;
        }

        if (_x + _c.w > _max) {
            if (_wx > 0) {
                // carry the whole current word down to a fresh line
                _line++;
                var _nx = 0;
                for (var k = _wstart; k <= i; k++) {
                    chars[k].x = _nx;
                    chars[k].line = _line;
                    _nx += chars[k].w;
                }
                _x = _nx; _wx = 0;
                continue;
            } else {
                // single word longer than the line: hard break
                _line++; _x = 0; _wstart = i; _wx = 0;
            }
        }

        _c.x = _x; _c.line = _line;
        _x += _c.w;
    }
};

/// named color from the palette, or "rrggbb" hex. white on garbage
__parse_col = function(_v) {
    // allow the c_ prefix so tags can match your macro names exactly
    if (string_copy(_v, 1, 2) == "c_") _v = string_delete(_v, 1, 2);

    if (variable_struct_exists(col_names, _v)) {
        return variable_struct_get(col_names, _v);
    }

    // hex fallback
    if (string_length(_v) != 6) return c_white;
    var _c = 0;
    for (var i = 1; i <= 6; i++) {
        var _d = string_pos(string_char_at(_v, i), "0123456789abcdef") - 1;
        if (_d < 0) return c_white;
        _c = _c * 16 + _d;
    }
    return make_color_rgb((_c >> 16) & 255, (_c >> 8) & 255, _c & 255);
};

/// reveal everything instantly. remaining pauses and sound cues
/// are skipped, style is already baked per-char so it survives
__instant_reveal = function() {
    reveal = total;
    action_pos = array_length(actions);
    pause_timer = 0;
    state = DSTATE.WAITING;
};

/// one stretched pixel: the atom everything else is built from
__px = function(_x, _y, _w, _h, _col, _alpha = 1) {
    draw_sprite_ext(spr_pixel_1x1, 0, _x, _y, _w, _h, 0, _col, _alpha);
};

/// hollow frame built from four pixel strips
__px_frame = function(_x, _y, _w, _h, _t, _col) {
    __px(_x,            _y,            _w, _t, _col);   // top
    __px(_x,            _y + _h - _t,  _w, _t, _col);   // bottom
    __px(_x,            _y,            _t, _h, _col);   // left
    __px(_x + _w - _t,  _y,            _t, _h, _col);   // right
};
