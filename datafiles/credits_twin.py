"""credits_twin.py - the expedition ECONOMY, simulated.

The house pattern (sprite_twin, exped_twin): model the shipped maths in
Python, state the invariants out loud, print HOLDS or FAILS. Tune here,
port the numbers back - never the other way round.

WHAT IS ASKED (2026-09-16, his pick: "the economy has no twin"): a crew of
n at par is sent on a quest (or to explore) on a world of tier T; the ship
burns fuel, the crew carries a pocket, towns cost (inns, shops, the tavern),
the road pays a little (coins, fight loot), and home pays the trip's floor,
the quest's reward when it is done, and whatever is left of the pocket.
Does a quest trip come out ahead without printing credits? Does an explore
bleed? Does the pocket cover a town? Is a deeper world richer but not
explosively so? Is the worst case bounded by the stake?

THE LAWS, term for term where they are simple (exped_cost, exped_tick_one's
home, exped_fight_loot's coin drop, exped_road_beat's coin, the town plan's
inn / tavern / shop, exped_quest_gen's reward, exped_loot_roll's credits);
the AGENT is not ported - how many towns a trip sees, how many road-hours
it walks and how many fights it has are the model's assumptions, stated
below and easy to argue with. The macros are read from main_macros.gml so
the twin cannot drift from the game's numbers.

Run:  python datafiles/credits_twin.py
"""

import os
import random
import re
import statistics

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
_mac = open(os.path.join(ROOT, "scripts", "main_macros", "main_macros.gml"), encoding="utf-8").read()


def macro(name):
    m = re.search(r"^#macro\s+" + name + r"\s+([-\d.]+)", _mac, re.M)
    if not m:
        raise SystemExit("main_macros has no #macro " + name)
    return float(m.group(1))


EXPED_FUEL      = macro("EXPED_FUEL")
EXPED_POCKET    = macro("EXPED_POCKET")
EXPED_INN       = macro("EXPED_INN")
EXPED_ENC       = macro("EXPED_ENC")
EXPED_ROAD_BEAT = macro("EXPED_ROAD_BEAT")
EXPED_DROP      = macro("EXPED_DROP")

# ---- the model's assumptions (the agent, not ported) ----
TOWNS_QUEST   = (0.3, 1.2)   # towns seen on a quest trip: the landing is inside one 30% (region_gen); + Poisson(1.2) on the way / at the quest
TOWNS_EXPLORE = (0.3, 1.8)   # an explore wanders more
ROAD_HOURS    = (6, 12)      # road-hours walked, uniform
FIGHTS_QUEST  = (2, 4)       # the quest's own fights (a slay of 3 = 2-3 packs; a delve's rooms; a rout's two)
WIN_TRIO      = 0.93         # sprite_twin: a trio at par wins ~93% a fight; a pair ~68%; alone ~35%
WIN_PAIR      = 0.68
WIN_SOLO      = 0.35
QUEST_MULTS   = [3, 3, 4, 4, 4, 3, 3, 4, 4, 3, 3, 2]   # exped_quest_gen's mults over its kinds (slay 3, clear/rout/bounty/rescue/defend 4, escort/fetch/survey/gather 3, scout 2)
P_REST_TOWN   = 0.40         # the town plan: a night at the inn when hurt or late
P_TAVERN      = 0.25         # ...a tavern on a quest trip (45% exploring)
P_TAVERN_X    = 0.45
P_TAVERN_SPEND = 0.35        # ...and 35% of tavern visits cost a credit
P_BUY_MEMBER  = 0.35         # a member finds something better on the shelf (gear_score) - a guess for a low-level crew
P_BOUNTY_DONE = 0.5          # a bounty taken (25% of taverns) is finished half the time


def region_lv(tier):
    return 1 + 2 * (tier - 1)   # the world's level by tier (the first region; +2 / +4 for the others)


def trip(n, tier, explore, rng):
    """one trip -> (net credits, net with the gear bought counted as kept value, pocket ran dry?, routed?)"""
    lv = region_lv(tier)
    fuel = EXPED_FUEL * max(1, tier)
    pocket = EXPED_POCKET * max(1, n)
    cost = fuel + pocket
    win = {1: WIN_SOLO, 2: WIN_PAIR}.get(n, WIN_TRIO)
    credits = pocket
    earned = 0
    gear = 0   # credits turned into gear at the shops (value kept, not lost)
    dry = False
    routed = False
    # the road
    hours = rng.randint(*ROAD_HOURS)
    fights = 0
    for _ in range(hours):
        if rng.random() * 100 < EXPED_ENC:
            fights += 1
        elif rng.random() * 100 < EXPED_ROAD_BEAT and rng.random() < 0.10:   # a coin in the mud: 10% of the beats
            c = 1 + rng.randint(0, 1)
            credits += c; earned += c
    if not explore:
        fights += rng.randint(*FIGHTS_QUEST)
    # the fights: a loss is a rout (everyone down); a win may drop
    for _ in range(fights):
        if rng.random() > win:
            routed = True
            break
        if rng.random() * 100 < EXPED_DROP and rng.random() < 0.55:
            nf = rng.choice([1, 1, 2, 2, 3])
            c = rng.randint(1, 2) * nf + tier - 1
            credits += c; earned += c
    # the towns (before the rout, if any: the plan happens on the way)
    p_town = TOWNS_QUEST if not explore else TOWNS_EXPLORE
    towns = (1 if rng.random() < p_town[0] else 0)
    # Poisson
    L = p_town[1]; k = 0; p = 1.0; e = 2.718281828459045 ** -L
    while True:
        p *= rng.random()
        if p < e: break
        k += 1
    towns += k
    for _ in range(towns):
        # the shop: each member up may buy; price 2 + lv//3 + 2*rar (rar 0-1 in the small places)
        for _m in range(n):
            if rng.random() < P_BUY_MEMBER:
                price = 2 + lv // 3 + 2 * rng.choice([0, 0, 1])
                if credits >= price: credits -= price; gear += price
                else: dry = True
        if rng.random() < (P_TAVERN_X if explore else P_TAVERN):
            if rng.random() < P_TAVERN_SPEND:
                if credits > 0: credits -= 1
            if rng.random() < 0.25 and rng.random() < P_BOUNTY_DONE:
                pay = 3 + 2 * tier
                credits += pay; earned += pay
        if rng.random() < P_REST_TOWN:
            beds = n * EXPED_INN
            if credits >= beds: credits -= beds
            else: dry = True
    # home
    if routed:
        credits = 0   # robbed (exped_rout)
    home = 3 * tier + hours // 4   # the trip's pay: 3 a tier, and one for every four hours on the world (exped_tick_one, 2026-09-16)
    if not explore and not routed:
        mult = rng.choice(QUEST_MULTS)
        home += (2 + lv) * mult   # the reward
    home += credits   # the pocket, unspent
    return home - cost, home - cost + gear, dry, routed


def run(n, tier, explore, trials=20000, seed=1):
    rng = random.Random(seed)
    nets, netg, drys, routs = [], [], 0, 0
    for _ in range(trials):
        net, ng, dry, routed = trip(n, tier, explore, rng)
        nets.append(net); netg.append(ng); drys += dry; routs += routed
    return statistics.mean(nets), min(nets), drys / trials, routs / trials, statistics.mean(netg)


def main():
    print("credits_twin: the expedition economy (macros read from main_macros.gml)")
    print(f"  fuel {EXPED_FUEL:g} x tier, pocket {EXPED_POCKET:g} a member, inn {EXPED_INN:g} a bed, encounter {EXPED_ENC:g}%/h, road beat {EXPED_ROAD_BEAT:g}%/h, drop {EXPED_DROP:g}%")
    print()
    print("  crew  tier  kind      E[net]  +gear   worst   pocket dry   routed")
    table = {}
    for n in (1, 2, 3):
        for tier in (1, 2, 3):
            for explore in (False, True):
                m, lo, dry, rt, mg = run(n, tier, explore)
                table[(n, tier, explore)] = (m, lo, dry, rt, mg)
                print(f"  {n}     {tier}     {'explore' if explore else 'quest  '}   {m:6.1f}  {mg:5.1f}   {lo:5.0f}     {dry*100:4.0f}%       {rt*100:4.0f}%")
    print()
    ok = True
    def law(name, holds, detail):
        nonlocal ok
        print(f"  {'HOLDS' if holds else 'FAILS'}  {name}  ({detail})")
        ok = ok and holds
    q1 = table[(3, 1, False)]; x1 = table[(3, 1, True)]; q3 = table[(3, 3, False)]
    law("a trio's tier-1 quest comes out ahead", q1[0] >= 3, f"E[net] {q1[0]:.1f}")
    law("...but is not a printer (under 30 a trip)", q1[0] <= 30, f"E[net] {q1[0]:.1f}")
    law("a trio's tier-1 explore does not bleed (the gear it bought counted as kept)", x1[4] >= 0 and x1[0] >= -4, f"E[net] {x1[0]:.1f}, with gear {x1[4]:.1f}")
    law("the pocket covers the towns most of the time", q1[2] <= 0.30, f"dry {q1[2]*100:.0f}%")
    law("a deeper world is richer, not explosive (tier 3 pays 1x..4x tier 1)", 1.0 <= q3[0] / max(.1, q1[0]) <= 4.0, f"x{q3[0] / max(.1, q1[0]):.2f}")
    law("the worst case is bounded by the stake", q1[1] >= -(EXPED_FUEL + EXPED_POCKET * 3), f"worst {q1[1]:.0f} vs stake {-(EXPED_FUEL + EXPED_POCKET * 3):.0f}")
    print()
    print("ALL HOLD" if ok else "SOMETHING FAILS - tune here, then port the numbers")


if __name__ == "__main__":
    main()
