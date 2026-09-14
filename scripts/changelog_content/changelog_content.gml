/// @description changelog_content() -> THE ERAS, newest first - the one
/// file the in-game changelog reads (his ask, 2026-09-14: "DE did
/// something like this but it was a hassle to work with").
///
/// THE SHAPE. Development runs in ERAS (DE's had names - Himadasha,
/// Delmarde) and each era holds its releases, newest first:
///   { era : "name", note : "one line on what the era was about",
///     releases : [ { ver, date, name, notes : [ { kind, txt }, ... ] }, ... ] }
///   kind is one of "added" / "changed" / "fixed" / "balance" / "buff" /
///   "nerf" / "note" - it picks the tag chip's colour (syst_changelog's
///   __kind_col). txt wraps.
///
/// >>> TO ADD A RELEASE: push one struct at the FRONT of the newest
/// >>> era's releases. TO START AN ERA: push a new era struct at the front
/// >>> of the array. Nothing else changes - the panel builds itself from
/// >>> this, opens the newest era and its newest release, folds the rest,
/// >>> and the settings row pips "new" against the newest ver here.
///
/// ⚖️ THE FIRST ERA HAS NO NAME YET (his note: "i dont yet have a name for
/// the pre-release era but i can find one") - rename it here when he does.
/// The releases below are SAMPLES written to feel the panel out before the
/// game ships; replace them with the real first release's notes.
function changelog_content() {
	static _e = [
		{ era : "the first era", note : "from the first build on the store - the name comes later",
		  releases : [
			{ ver : "1.0.2", date : "2026-10-02", name : "the quiet one",
			  notes : [
				{ kind : "fixed",   txt : "loading a save from an older build no longer adopts the other profile's coin, cheat rows or ability deck" },
				{ kind : "fixed",   txt : "the visualiser drew the units of a lower field inside a completed square (the green corners)" },
				{ kind : "fixed",   txt : "a fullscreen window that came back from a display refresh at the boot size is re-asserted" },
				{ kind : "changed", txt : "the objective card stays open on every new objective until you tap it" },
				{ kind : "nerf",    txt : "the time bank: capacity 10 min +10 a level, the rate ceiling 20 (was 45)" },
				{ kind : "buff",    txt : "time bank upgrades are cheaper: 6+5n / 5+4n banked minutes (were 20+15n / 15+10n)" },
				{ kind : "buff",    txt : "dial milestones past level 100: 250 speed x2, 500 profit x5, 1000 profit x10, 2000 speed x2, 5000 and 10000 profit x100" },
			  ] },
			{ ver : "1.0.1", date : "2026-09-25", name : "the settings pass",
			  notes : [
				{ kind : "added",   txt : "an interface tab in settings: the menu, the screen and the title backdrop live there now" },
				{ kind : "added",   txt : "hold a visualiser knob in the money room and the settings screen fades to the knob so you see the change live" },
				{ kind : "added",   txt : "the dial autobuy is one master row with a target (strongest / cheapest / lowest / robin) and a filter of dial chips" },
				{ kind : "changed", txt : "every timer track snaps to four price stops - 30, 20, 10 and 5 seconds for 1 to 4 sticks" },
				{ kind : "changed", txt : "the swappable sounds were normalised: every option plays at one loudness" },
				{ kind : "nerf",    txt : "the credit core: the well costs 500 credits to open, then levels start at 200 and climb" },
				{ kind : "balance", txt : "the cheat shop has no free points; Cheat Points I-III and Cheat Ceiling I-II on the ability deck are the only extras" },
				{ kind : "fixed",   txt : "sliders no longer drag behind an open dropdown" },
				{ kind : "fixed",   txt : "the tap and dial volume faders auditioned on every frame of a drag" },
			  ] },
			{ ver : "1.0.0", date : "2026-09-18", name : "release",
			  notes : [
				{ kind : "note",    txt : "the first build on the store. everything below is what shipped." },
				{ kind : "added",   txt : "the money room, thirteen dials, the tap, the overcharger, critical taps" },
				{ kind : "added",   txt : "the upgrade table, the credit dropper and the credit core" },
				{ kind : "added",   txt : "the tile table with the fabricator, the automerger and the shard upgrades" },
				{ kind : "added",   txt : "rebirth, the milestone scale, the cheat shop and the ability deck" },
				{ kind : "added",   txt : "automation with RAM, overclock notches and modes; the battery for the time away; the time bank" },
				{ kind : "added",   txt : "expeditions with the sprites, the daily gift, the offline log, statistics with favourites" },
				{ kind : "added",   txt : "the objectives chain that teaches all of it, the dice, the coin and the puck" },
			  ] },
		  ] },
	];
	return _e;
}
