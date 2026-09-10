/// syst_newgame - rm_newgame's controller: THE NEW-GAME FLOW (his spec,
/// 2026-09-10): after a profile is picked in the saves screen, a black
/// screen. A list, centred: easy / standard / hard / critical / custom,
/// colour coded - the difficulty (stored, nothing reads custom yet).
/// Then three personality questions, one screen each. Then the trigger
/// (newgame_start), which lands in the money room VEILED - black, the
/// word "tap", and the first tap fades the room in (syst_unfold). "This
/// is the first step to unfolding mechanics" - DE did it more
/// incrementally; this is the door.
///
/// The screen is a stage machine: 0 the difficulty list, 1..3 the
/// questions. Every stage is a centred list drawn and hit from the same
/// __rows() geometry (region law), fading between stages on `t`.

g.persona = [-1, -1, -1];
prof = variable_global_exists("ng_prof") ? g.ng_prof : 0;
diff = 1;

stage = 0;       // 0 difficulty, 1..3 questions
t     = 0;       // the stage's fade-in, 0..1
leaving = -1;    // >= 0: fading out toward that stage (or 99 = start)
hov   = -1;      // hovered row

// ---- the difficulty list (his five, colour coded) ----
diffs = [
	{ name : "easy",     sub : "a gentler pace",     col : c_sblue },
	{ name : "standard", sub : "the intended run",   col : rgb(195, 205, 235) },
	{ name : "hard",     sub : "numbers bite back",  col : c_horange },
	{ name : "critical", sub : "no promises",        col : c_hred },
	{ name : "custom",   sub : "your own rules, later", col : c_hpurple },
];

// ---- the three questions ----
// ⚖️ CREATIVE, NOT DIAGNOSTIC (his word: personality). Nothing reads
// the answers yet - they are stored on the save (g.persona) for
// whatever unfolds later. Each is a small choice a person makes about
// an idle game without knowing they are making it: what they do with a
// growing number, what they do with a running machine, what they would
// build. The answers wear the house colours so the screen stays in the
// difficulty list's language.
quests = [
	{
		q : "a number is climbing on its own. you...",
		a : [
			{ name : "watch it",            col : c_sblue },
			{ name : "spend it",            col : c_gold },
			{ name : "push it harder",      col : c_horange },
			{ name : "give it a name",      col : c_hpurple },
		],
	},
	{
		q : "the machine hums at 3am.",
		a : [
			{ name : "let it run",          col : c_sblue },
			{ name : "check the numbers",   col : rgb(195, 205, 235) },
			{ name : "add another",         col : c_horange },
			{ name : "unplug it and sleep", col : c_hred },
		],
	},
	{
		q : "infinite money. the first thing you build is...",
		a : [
			{ name : "a bigger counter",    col : c_gold },
			{ name : "a quieter room",      col : c_sblue },
			{ name : "a second machine",    col : c_horange },
			{ name : "a way to give it away", col : c_sgreen },
		],
	},
];

// ---- geometry: one list, centred, shared by Draw and Step ----
row_w = 200;
row_h = 22;
row_gap = 4;

/// @func __rows()
/// @desc the current stage's rows: [{ name, sub, col, x, y, w, h }]
__rows = function() {
	var _src = (stage == 0) ? diffs : quests[stage - 1].a;
	var _n = array_length(_src);
	var _tot = _n * row_h + (_n - 1) * row_gap;
	var _y0 = (room_height - _tot) * .5 + 14;   // a little under centre: the title sits above
	var _out = [];
	for (var _i = 0; _i < _n; _i++) {
		var _e = _src[_i];
		array_push(_out, {
			name : _e.name, sub : _e[$ "sub"] ?? "", col : _e.col,
			x : (room_width - row_w) * .5, y : _y0 + _i * (row_h + row_gap),
			w : row_w, h : row_h,
		});
	}
	return _out;
};

__title = function() {
	if (stage == 0) return "how hard?";
	return quests[stage - 1].q;
};
