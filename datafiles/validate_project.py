"""validate_project.py - pre-flight the GameMaker project WITHOUT the IDE.

Claude cannot compile GML, so every hand-authored .yy / .yyp edit is a
guess until Somnati opens the project. This script is the substitute:
it reproduces the checks the IDE performs at LOAD time, so a broken
edit is caught here instead of costing him a round trip.

It exists because three separate load failures shipped in a row, each
a different class, each individually obvious in hindsight:
  1. wrong per-record version   ($GMObject must be "", not "v1")
  2. wrong field spelling       (room instances use isDnd, events isDnD)
  3. dangling folder path       (assets ported from Myriad DE still
                                 pointed at DE's folder tree)
All three parsed as valid JSON. "It parses" proves nothing.

Run from the project root:   python datafiles/validate_project.py
"""
import json, re, os, glob, sys, collections

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.chdir(ROOT)
YYP = glob.glob("*.yyp")[0]

fails, warns = [], []


def load(path):
    """GM's .yy dialect is JSON with trailing commas."""
    raw = open(path, encoding="utf-8-sig").read()
    return json.loads(re.sub(r",(\s*[}\]])", r"\1", raw))


def check(name, ok, detail=""):
    print(f"  {'PASS' if ok else 'FAIL'}  {name}" + (f"  {detail}" if detail and not ok else ""))
    if not ok:
        fails.append(name)


print(f"\nvalidating {YYP}\n" + "-" * 60)

# ---------------------------------------------------------- 1. parsing
allyy = glob.glob("*/*/*.yy") + [YYP]
bad = []
for p in allyy:
    try:
        load(p)
    except Exception as e:
        bad.append(f"{p}: {str(e)[:60]}")
check("every .yy/.yyp parses", not bad, "; ".join(bad[:3]))
if bad:
    print("\nparse errors block every other check - fix these first")
    sys.exit(1)

# ------------------------------------------------------------- 2. BOM
boms = [p for p in allyy + glob.glob("*/*/*.gml")
        if open(p, "rb").read(3) == b"\xef\xbb\xbf"]
check("no UTF-8 BOM (GM's parser chokes on it)", not boms, str(boms[:3]))

proj = load(YYP)
reg = {r["id"]["name"]: r["id"]["path"].replace("\\", "/") for r in proj["resources"]}

# ------------------------------------------------- 3. registration <-> disk
missing = [n for n, p in reg.items() if not os.path.exists(p)]
check("every registered resource exists on disk", not missing, str(missing[:5]))

KINDS = ["scripts", "objects", "sprites", "sounds", "rooms", "shaders", "extensions"]
on_disk = {n for k in KINDS if os.path.isdir(k) for n in os.listdir(k)}
unreg = sorted(on_disk - set(reg))
check("every asset on disk is registered", not unreg, str(unreg[:5]))

# ------------------------------------------------------ 4. folder paths
folders = {f["folderPath"] for f in proj["Folders"]}
danglers = collections.defaultdict(list)
for p in glob.glob("*/*/*.yy"):
    par = load(p).get("parent", {}).get("path")
    if par and par not in folders:
        danglers[par].append(os.path.basename(p))
check("every asset's parent folder is declared", not danglers,
      "; ".join(f"{k} <- {v[:3]}" for k, v in list(danglers.items())[:2]))

# --------------------------------------------------- 5. record versions
vers = collections.defaultdict(set)
for p in allyy:
    d = load(p)
    for k, v in d.items():
        if k.startswith("$GM"):
            vers[k].add(v)
mixed = {k: sorted(v) for k, v in vers.items() if len(v) > 1}
check("each $GM record type uses ONE version", not mixed, str(mixed))

# ------------------------------------------- 6. structural shape by type
def shape(d):
    return tuple(sorted(d.keys()))

groups = collections.defaultdict(list)
for p in glob.glob("*/*/*.yy"):
    d = load(p)
    rt = d.get("resourceType")
    if rt:
        groups[rt].append((p, d))
odd = []
for rt, items in groups.items():
    counts = collections.Counter(shape(d) for _, d in items)
    if len(counts) > 1:
        majority = counts.most_common(1)[0][0]
        for p, d in items:
            if shape(d) != majority:
                miss = set(majority) - set(d)
                extra = set(d) - set(majority)
                odd.append(f"{p} (missing {sorted(miss)} extra {sorted(extra)})")
check("every resource matches its type's field shape", not odd, "; ".join(odd[:3]))

# nested records: object events and room instances
ev_shapes, inst_shapes = collections.Counter(), collections.Counter()
for p, d in groups.get("GMObject", []):
    for e in d.get("eventList", []):
        ev_shapes[shape(e)] += 1
for p, d in groups.get("GMRoom", []):
    for L in d.get("layers", []):
        for i in L.get("instances", []):
            inst_shapes[shape(i)] += 1
check("all object event records share one shape", len(ev_shapes) <= 1, str(list(ev_shapes)))
check("all room instance records share one shape", len(inst_shapes) <= 1, str(list(inst_shapes)))

# ------------------------------------------- 7. event files exist on disk
EV = {0: "Create", 3: "Step", 8: "Draw", 12: "CleanUp", 4: "Collision",
      6: "Other", 7: "Other", 2: "Alarm", 9: "KeyPress", 10: "KeyRelease"}
lost = []
for p, d in groups.get("GMObject", []):
    folder = os.path.dirname(p)
    for e in d.get("eventList", []):
        stem = f"{EV.get(e['eventType'], 'Other')}_{e['eventNum']}.gml"
        if not os.path.exists(os.path.join(folder, stem)):
            lost.append(f"{d['name']}:{stem}")
check("every declared object event has its .gml", not lost, str(lost[:5]))

# -------------------------------------- 8. room instances name real objects
ghosts = []
for p, d in groups.get("GMRoom", []):
    for L in d.get("layers", []):
        for i in L.get("instances", []):
            o = i.get("objectId", {}).get("name")
            if o and o not in reg:
                ghosts.append(f"{d['name']}:{o}")
check("room instances reference registered objects", not ghosts, str(ghosts[:5]))

# ---------------------------------- 9. creation order <-> instance names
mismatched = []
for p, d in groups.get("GMRoom", []):
    named = {i["name"] for L in d.get("layers", []) for i in L.get("instances", [])}
    ordered = {c["name"] for c in d.get("instanceCreationOrder", [])}
    if named != ordered:
        mismatched.append(f"{d['name']}: {sorted(named ^ ordered)[:4]}")
check("room creation order matches its instances", not mismatched, str(mismatched[:3]))

# ------------------------------------------- 10. rooms in RoomOrderNodes
ro = {r["roomId"]["name"] for r in proj["RoomOrderNodes"]}
rooms = {n for n, p in reg.items() if p.startswith("rooms/")}
check("every room appears in RoomOrderNodes", ro == rooms, str(ro ^ rooms))

print("-" * 60)
if fails:
    print(f"{len(fails)} CHECK(S) FAILED: {', '.join(fails)}\n")
    sys.exit(1)
print("ALL CHECKS PASSED - the project should load\n")
