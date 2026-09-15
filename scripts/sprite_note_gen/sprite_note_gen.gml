/// @description sprite_note_gen(sprite, beat, [ctx]) -> a note's text ("" = nothing came to mind)
/// What a sprite would write, by beat:
///   "foe"    after a fight, about ctx.foe (a pawn): a true thing read off
///            its shape - quick / armoured / a tank / a caster / armed /
///            a boss - in its own dim words; tagged foe:<kind> by the
///            caller so it counts (SPRITE_NOTE_HIT)
///   "rout"   after a rout, about ctx.foe: a resolution
///   "land" / "rest" / "find" / "home" / "levelup"   the useless kind
/// ctx: { foe, item, planet, partner, lv }. The chance to write at all
/// is the caller's; this only decides what.
function sprite_note_gen(_sp, _beat, _ctx = {}) {
	var _foe  = _ctx[$ "foe"];
	var _kind = is_struct(_foe) ? (_foe[$ "kind"] ?? "it") : "it";
	var _ks   = _kind + "s";
	switch (_beat) {
		case "foe": {
			if (!is_struct(_foe)) return "";
			var _opts = [];
			if (_foe[$ "boss"] ?? false) array_push(_opts, "the " + _foe.name + " exists. avoid.", "met the " + _foe.name + ". it has a title. we do not.");
			if (array_length(_foe[$ "worn"] ?? []) > 0) array_push(_opts, "one of the " + _ks + " had a " + _foe.worn[0].name + ". rude.", _ks + " carry things. they are not for sharing.");
			if (_foe.spd >= 6.5 * (_foe.pts_total / 40)) array_push(_opts, _ks + " are quick. swing early.", _ks + " move before you have decided to.");
			if (_foe.def >= 5.5 * (_foe.pts_total / 40)) array_push(_opts, _ks + " wear things. aim for the gaps.", "hitting a " + _kind + " is like hitting a door.");
			if (_foe.maxhp_real >= 30 * (_foe.pts_total / 40)) array_push(_opts, _ks + " take ages. bring snacks.", "a " + _kind + " does not go down. it goes sideways, slowly.");
			if (_foe[$ "magic"] ?? false) array_push(_opts, _ks + " do the glowy thing. do not stand in it.", "a " + _kind + " hums before it hurts. the hum is the warning.");
			if (_foe.atk >= 6.5 * (_foe.pts_total / 40)) array_push(_opts, _ks + " hit hard. do not be where the hit is.", "a " + _kind + " swings like it means it.");
			if (_foe.hit <= 4.5 * (_foe.pts_total / 40)) array_push(_opts, _ks + " miss a lot. stand still and look confident.");
			array_push(_opts, _kind + ": hits back. noted.", "a " + _kind + " is a " + _kind + ". writing it down anyway.");
			return _opts[irandom(array_length(_opts) - 1)];
		}
		case "rout":
			return choose(_ks + ": no. just no.", "do not go near " + _ks + " again. underline this.", _ks + ". the bad kind.", "lost to a " + _kind + ". the notepad was not helpful.");
		case "land":
			return choose((_ctx[$ "planet"] ?? "this place") + " has a smell.", "the sky here is a colour.", "the ground is mostly down.",
			              "the third rock from the left is nice.", "if lost, keep going.", "landed. wrote that down so it counts.",
			              "gravity here is normal. checked twice.", "there is a hill. it is not important.");
		case "rest":
			return choose("inn beds face north. or south.", "rested. dreamt of a spoon.", "note to self: i am " + _sp.name + ".",
			              "remember to buy eggs.", "left foot first when stepping over roots.", "the last room was a room.",
			              "i think the moon is following us.", "don't trust ladders.", "ask " + (_ctx[$ "partner"] ?? "someone") + " about the thing.");
		case "find":
			return choose("the " + (_ctx[$ "item"] ?? "thing") + " is heavier than it looks.", "found a good stick. lost it.",
			              "the " + (_ctx[$ "item"] ?? "thing") + ". keep? probably.", "things are on the ground here. free.",
			              "goblins count as three geese.", "picked something up. it was there.");
		case "home":
			return choose("home. the notepad survived. barely.", "back. nothing has changed. good.", "to do: nothing. done.",
			              "the ship still smells of last time.", "arrived where we left from. the maths works.");
		case "levelup":
			return choose("level " + string(_ctx[$ "lv"] ?? 2) + ". felt nothing.", "stronger now. same hat.",
			              "level " + string(_ctx[$ "lv"] ?? 2) + ". wrote it bigger than the others.", "got better at it. at what, unclear.");
	}
	return "";
}
