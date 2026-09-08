/// tour_automation - AUTOMATION  (game/automation)
/// A TOUR SCRIPT: comments only, nothing runs.

// ========================== THE IDEA ================================
// rm_automation is a VIEW. Every preference lives in g.autom and the
// runner is autom_tick on syst_production's heartbeat, so automation
// works in every room whether or not the screen is open. Three pages
// on a left rail: dials, rebirth, upgrades.

// ========================== THE FILES ===============================
//   autom_init          g.autom. Saved preferences and session pacing,
//                       and the split between them is deliberate.
//   autom_tick          ONE pulse a second. The runner.
//   autom_piece         one dial's autobuy pulse (Myriad's ramp law).
//   autom_upgrades      the upgrade table: sell, roll, buy, in that
//                       order.
//   upgrade_keep_rarity the sell filter, derived from a percentage.
//   profit_spendable    the reserve's one reader.
//   syst_rm_automation  the screen.

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
//   THE UPGRADE FILTER IS A PERCENTAGE, NOT A RARITY. See
//   upgrade_keep_rarity: a fixed rung rots the moment the distribution
//   moves, and then the automation silently does nothing while the
//   player believes it is filtering. It also applies to SELLING ONLY -
//   filtering the buy too would mean that with autosell off, autobuy
//   refused to level a common the player had chosen to keep.
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
//     one more than its dial index. __flip and __set_slider both
//     account for it; anything new that indexes that page must too.
//   - A row's help string is drawn in the title strip on the dials
//     page and in the footer on the others, because fourteen rows
//     leave the dials page no footer band.
//   - autom_init sizes its dial array from g.dial_total with a
//     fallback, and autom_tick clamps with min() against it. Do not
//     assume the two match.
