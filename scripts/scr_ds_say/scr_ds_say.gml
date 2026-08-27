/// these only PUSH entries onto a queue. nothing plays until
/// obj_dialogue walks the queue. that's what lets a tree script
/// read top-to-bottom like a screenplay.

// ---- scr_ds_say ----------------------------------------------

// dialogue state machine. enum lives here so every script and
// the object can see it
enum DSTATE {
    IDLE,       // no dialogue running
    TYPING,     // typewriter revealing characters
    WAITING,    // line fully shown, waiting for confirm
    CHOOSING,   // choice menu up
    PAUSED      // mid-line [pause=n] in effect
}

/// queue one line of dialogue. speaker "" hides the name plate.
function ds_say(_speaker, _text) {
    if (!variable_global_exists("__ds_queue")) g.__ds_queue = [];
    array_push(g.__ds_queue, { type: "say", speaker: _speaker, text: _text });
}

// ---- scr_ds_choice -------------------------------------------

/// queue a choice menu. takes a flat array of pairs:
/// ds_choice(["Buy", dt_shop_buy, "Leave", dt_shop_exit]);
/// picking an option abandons the rest of the current queue
/// and runs the chosen tree
function ds_choice(_arr) {
    if (!variable_global_exists("__ds_queue")) g.__ds_queue = [];
    var _opts = [];
    for (var i = 0; i + 1 < array_length(_arr); i += 2) {
        array_push(_opts, { label: _arr[i], tree: _arr[i + 1] });
    }
    array_push(g.__ds_queue, { type: "choice", options: _opts });
}

// ---- scr_ds_event --------------------------------------------

/// queue a function to execute mid-conversation, between lines.
/// runs silently, dialogue flows straight through it
function ds_event(_fn) {
    if (!variable_global_exists("__ds_queue")) g.__ds_queue = [];
    array_push(g.__ds_queue, { type: "event", fn: _fn });
}

// ---- scr_ds_end ----------------------------------------------

/// queue an explicit end point. running off the end of the
/// queue also ends dialogue, this just makes trees read clearly
function ds_end() {
    if (!variable_global_exists("__ds_queue")) g.__ds_queue = [];
    array_push(g.__ds_queue, { type: "end" });
}

