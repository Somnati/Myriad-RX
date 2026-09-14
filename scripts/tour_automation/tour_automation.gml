/// tour_automation - AUTOMATION  (game/automation)
/// A TOUR SCRIPT: comments only, nothing runs.

// ========================== THE IDEA ================================
// the automation panel is a VIEW. Every preference lives in g.autom and the
// runner is autom_tick on syst_production's heartbeat, so automation
// works in every room whether or not the screen is open. Three pages
// on a left rail: dials, rebirth, upgrades.

// ========================== THE FILES ===============================
//   autom_init          g.autom. Saved preferences and session pacing,
//                       and the split between them is deliberate.
//   autom_tick          ONE pulse a second. The runner.
//   autom_strategy      THE MASTER ROW's pulse (2026-09-14): the filter's
//                       dials in the target's order (autom_order), each
//                       buying max out of the cap share, leftovers down.
//   autom_piece         RETIRED with the per-dial rows (kept for reference).
//   autom_upgrades      the upgrade table: sell, roll, buy, in that
//                       order.
//   upgrade_autosell_wants THE SELL RULE. Two explicit filters, rarity
//                       and kind, either of which is enough.
//   upgrade_keep_rarity a percentage -> a rarity rung, off the LIVE
//                       odds. It is the quick-set behind the auto-sell
//                       slider, not a standing rule.
//   profit_spendable    the reserve's one reader.
//   syst_automation_panel  the screen - an OVERLAY over any room
//                       (2026-09-10; rm_automation retired). The menu
//                       line opens it, the burger's X closes it.

// ======================= THE LAWS THAT MATTER =======================
//
//   ONE PULSE A SECOND, AND THE STEP SIZE IS THE THROTTLE. Myriad's
//   cadence. Never speed the clock up to buy more: a faster pulse
//   spends the same money in smaller, dearer pieces, because every
//   dial curve accelerates. autom_piece's ramp is the thing that
//   scales throughput, and it scales it correctly.
//
//   THE RAMP'S ASYMMETRY IS THE WHOLE TRICK. It grows by one per landed
//   buy (accelerating past 50) and COLLAPSES to q=1, h=-50 the instant
//   one is unaffordable. Symmetric backoff would oscillate between
//   "buy 400" and "buy nothing" forever; the hard collapse plus a slow
//   climb settles instead.
//
//   THE BUDGET IS RE-READ EVERY TIME, off the live balance - never
//   captured once per pulse. Capture it and one pulse spends several
//   times the share the player set, because each purchase lowers the
//   balance the next share should have been measured against. That bug
//   was in the first cut of autom_upgrades' buy loop.
//
//   AUTOREBIRTH GOES THROUGH rebirth_calc AND rebirth_do, the same two
//   scripts the button uses. Not tidiness: it is what makes the
//   timeclamp and the press cooldown bind automation exactly as they
//   bind a person. Conditions are AND-ed because they are rails, not
//   triggers - someone setting "30 minutes" and "5 units" means both.
//
//   THE UPGRADE FILTER IS TWO EXPLICIT LISTS (his call): a keep/sell
//   flag per rarity rung and one per roster id. They are not redundant
//   - rarity asks "how good is this roll", kind asks "do I want this
//   stat at all", and a player finished with credit luck wants every
//   credit-luck roll gone however lucky it was.
//
//   THE PERCENTAGE SURVIVES AS A QUICK-SET, not as a rule. Dragging the
//   auto-sell slider writes the rarity flags from upgrade_keep_rarity,
//   which reads the LIVE odds - so the self-adjusting logic is still
//   there as a one-drag way to configure, while the flags stay the
//   thing the runner reads. A standing percentage would have quietly
//   stopped matching anything the day the distribution moved; a
//   percentage you APPLY cannot.
//
//   THE FILTER SELLS, IT DOES NOT GATE BUYING. Filtering the buy too
//   would mean that with autosell off, autobuy refused to level a
//   common the player had chosen to keep.
//
//   KINDS ARE SAVED BY ID, and only the ones set to SELL are written -
//   so a roster entry added later defaults to keep rather than
//   inheriting a flag from whatever sat at its index.
//
//   THE RESERVE IS A PORTION OF g.profit, NOT A SECOND PILE. See
//   profit_spendable for the full argument. In one line: everything
//   that reads "profit held" - rebirth above all - keeps working
//   untouched, because the reserve never left the number they read.
//
//   ONLINE ONLY. offline_replay neither autobuys nor autorebirths.
//   Buy events inside a bulk replay are a real design fork (what did
//   the wallet look like halfway through?) and the room promises
//   nothing about it.

// ============================ TRAPS =================================
//   - The dials page's row 0 is the RESERVE, so a dial's row index is
//     one more than its dial index. The filter page's row 0 is the
//     rarity chip strip, so a roster row is one more than its config
//     index. __flip and __set_slider account for both; anything new
//     that indexes those pages must too.
//   - Every footer band on this screen is ONE LINE DEEP and the hover
//     help shares it. Each page's note must be an `else if` in that
//     chain - a bare `if` paints straight through the hover line, which
//     is exactly what it did on the upgrades page (his report,
//     2026-09-08).
//   - A row's help string is drawn in the title strip on the dials
//     page and in the footer on the others, because fourteen rows
//     leave the dials page no footer band.
//   - autom_init sizes its dial array from g.dial_total with a
//     fallback, and autom_tick clamps with min() against it. Do not
//     assume the two match.
