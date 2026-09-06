/// @description  goto_room(room);
/// @param room
/// the circle-wipe room switch (persistent syst_roomtrans) - AND the
/// nav HISTORY (2026-07-07, his ask: back buttons return to wherever
/// you actually came from). every forward hop pushes the room it
/// left; back_room() pops instead of pushing (the skip flag), so
/// back-chains unwind cleanly instead of ping-ponging.
function goto_room() {

	if syst_roomtrans.switch_rooms = false{
			syst_roomtrans.reached_dest = false;
			syst_roomtrans.switch_rooms = true;

			if argument_count = 1 {
				// ORIENTATION (2026-09-06): every destination resolves to
				// the SHAPE being played. Code names the portrait room -
				// goto_room(rm_clicker) - and lands in the landscape twin
				// when that is the mode. One seam, so the menu, the save
				// menu, the titlescreen and back_room all obey it without
				// knowing the framework exists. See room_pairs.
				var _dest = room_variant(argument[0]);

				// nav history
				if (!variable_global_exists("room_hist")) g.room_hist = [];
				if (!variable_global_exists("room_hist_skip")) g.room_hist_skip = false;
				if (!g.room_hist_skip && _dest != room
					&& room != rm_gameload)
					array_push(g.room_hist, room);
				if (array_length(g.room_hist) > 32)
					array_delete(g.room_hist, 0, 1);
				g.room_hist_skip = false;

				// save-on-mutation law (2026-07-12): leaving a room
				// FLUSHES dirty state to the main save - silent (no
				// banner, no slot rotation), so "buy, hop rooms, crash"
				// can't lose the buy. the dirty flag is the debounce:
				// clean transitions write nothing.
				if (variable_global_exists("save_dirty") && g.save_dirty
				&& instance_exists(syst_handle_save)
				&& room != rm_gameload) {
					with (syst_handle_save) {
						action = sv_save;
						handle_save();
						action = -1;
					}
					g.save_dirty = false;
				}

				syst_roomtrans.des_room = room_get_name(_dest);
				syst_roomtrans.des_room_id = _dest
				syst_roomtrans.r = 0;
				syst_roomtrans.alpha = 0;
				// transition kind LATCH (round 7): capture the setting
				// at launch - a mid-flight settings change can't mix the
				// slice and the circle - and arm the slice clock
				syst_roomtrans.trans_active_kind =
					variable_global_exists("trans_kind") ? g.trans_kind : 1;
				syst_roomtrans.slice_t = 0;
				syst_roomtrans.slice_phase =
					(syst_roomtrans.trans_active_kind == 1) ? 1 : 0;
				}

	}

}
