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
    """A hard gate: anything here stops the IDE loading the project."""
    print(f"  {'PASS' if ok else 'FAIL'}  {name}" + (f"  {detail}" if detail and not ok else ""))
    if not ok:
        fails.append(name)


def warn(name, ok, detail=""):
    """A soft gate: the project still LOADS, but something will not be
    visible. Kept separate because benign cases exist - obj_background
    paints black beneath an already-black layer, which is redundant
    rather than wrong - and a benign case must never block the gate."""
    print(f"  {'ok  ' if ok else 'WARN'}  {name}" + (f"  {detail}" if detail and not ok else ""))
    if not ok:
        warns.append(name)


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

# -------------------------------- 11. drawn BEHIND an opaque background
# LOWER DEPTH DRAWS ON TOP. A room with an opaque background layer at
# depth D hides every instance whose object sets depth > D - the code
# runs, input still works, nothing appears. Cost one round trip.
def create_depth(objname):
    p = f"objects/{objname}/Create_0.gml"
    if not os.path.exists(p):
        return None
    m = re.search(r"^\s*depth\s*=\s*(-?\d+)", open(p, encoding="utf-8-sig").read(), re.M)
    return int(m.group(1)) if m else None


def draws_in_begin(objname):
    p = f"objects/{objname}/{objname}.yy"
    if not os.path.exists(p):
        return False
    return any(e["eventType"] == 8 and e["eventNum"] == 72
               for e in load(p).get("eventList", []))


buried, begun = [], []
for p, d in groups.get("GMRoom", []):
    opaque = [L["depth"] for L in d.get("layers", [])
              if L.get("resourceType") == "GMRBackgroundLayer"
              and L.get("spriteId") is None
              and (L.get("colour", 0) >> 24) & 0xFF == 0xFF]
    if not opaque:
        continue
    top = min(opaque)   # the shallowest opaque fill is what buries things
    for L in d.get("layers", []):
        for i in L.get("instances", []):
            o = i.get("objectId", {}).get("name")
            if not o:
                continue
            dep = create_depth(o)
            if dep is not None and dep > top:
                buried.append(f"{d['name']}:{o} depth {dep} > background {top}")
            if draws_in_begin(o):
                begun.append(f"{d['name']}:{o}")
warn("nothing drawn behind an opaque background layer", not buried,
     "; ".join(buried[:4]))
warn("no Draw Begin under an opaque background (it precedes layers)",
     not begun, "; ".join(begun[:4]))

# ------------------------------------------------- 12. empty folders
# Tree hygiene, not correctness: a folder with no assets and no
# subfolders is a leftover (RX inherited 45 of them from the techdemo's
# stripped game layer). Expected briefly when a folder is declared
# ahead of the system that will fill it.
used_f = collections.Counter()
for n, rp in reg.items():
    par = load(rp).get("parent", {}).get("path")
    if par:
        used_f[par] += 1
allf = [f["folderPath"] for f in proj["Folders"]]
hollow = [f for f in allf
          if used_f[f] == 0 and f.count("/") > 1
          and not any(o != f and o.startswith(f[:-3] + "/") for o in allf)]
warn("no empty folders in the resource tree", not hollow,
     f"{len(hollow)}: " + ", ".join(hollow[:4]))

# ------------------------------------------- 10. rooms in RoomOrderNodes
ro = {r["roomId"]["name"] for r in proj["RoomOrderNodes"]}
rooms = {n for n, p in reg.items() if p.startswith("rooms/")}
check("every room appears in RoomOrderNodes", ro == rooms, str(ro ^ rooms))

# ------------------------------------------- 13. orientation pairs
# The money room exists in two shapes (room_pairs). Two things can rot
# silently once a room has a twin, and neither stops the project
# LOADING, so the IDE will never tell him:
#   - a twin drifts: an instance added to one shape and not the other.
#     A warn, not a gate - a shape may legitimately want an extra
#     instance, and a false gate that blocks a build is worse than a
#     line of output.
#   - a room carries the wrong orientation marker. obj_set_landscape is
#     what re-arms the player's resolution in scr_display1; a landscape
#     room without it parks the window in portrait, and a portrait room
#     with it never parks at all. That one is mechanical - decided by
#     the room's own dimensions - so it IS a gate.
MARKER = "obj_set_landscape"


def room_objects(name):
    d = load(reg[name])
    out = set()
    for lay in d.get("layers", []):
        for inst in lay.get("instances", []):
            out.add(inst["objectId"]["name"])
    return out


def room_effects(name):
    """The FX stack, as name+type pairs. Parameters are deliberately NOT
    compared: a 144x296 room may well want a different glow radius from
    a 480x270 one, but it should not be missing the glow."""
    d = load(reg[name])
    return {(lay.get("name"), lay.get("effectType"))
            for lay in d.get("layers", [])
            if lay.get("effectType")}


pairs_gml = "scripts/room_pairs/room_pairs.gml"
pairs = []
if os.path.exists(os.path.join(ROOT, pairs_gml)):
    src = open(os.path.join(ROOT, pairs_gml), encoding="utf-8").read()
    pairs = re.findall(r"\{\s*p\s*:\s*(\w+)\s*,\s*l\s*:\s*(\w+)\s*\}", src)

bad_pair = [f"{p}/{l}" for p, l in pairs if p not in reg or l not in reg]
check("room_pairs names rooms that exist", not bad_pair, ", ".join(bad_pair))

drift = []
for p, l in pairs:
    if p not in reg or l not in reg:
        continue
    a = room_objects(p) - {MARKER}
    b = room_objects(l) - {MARKER}
    if a != b:
        drift.append(f"{p} vs {l}: " + ", ".join(sorted(a ^ b)))
    fa, fb = room_effects(p), room_effects(l)
    if fa != fb:
        drift.append(f"{p} vs {l} fx: "
                     + ", ".join(sorted(n for n, _ in fa ^ fb)))
warn("orientation twins hold the same instances and fx", not drift,
     "; ".join(drift[:3]))

marker = []
for n, p in reg.items():
    if not p.startswith("rooms/"):
        continue
    rs = load(p).get("roomSettings", {})
    wide = rs.get("Width", 0) > rs.get("Height", 0)
    has = MARKER in room_objects(n)
    if wide and not has:
        marker.append(f"{n} is landscape without {MARKER}")
    if not wide and has:
        marker.append(f"{n} is portrait but places {MARKER}")
check("every landscape room places the orientation marker", not marker,
      "; ".join(marker[:3]))

# ------------------------------------------------- 8. GML syntax traps
# This section exists because 2026-09-07 shipped TWO broken scripts in a
# row, and every check above passed both times. The validator was
# checking the .yy/.yyp skeleton and nothing at all about the code
# inside it - which is most of what actually gets written.
#
# It is not a GML parser and never will be. It catches the specific,
# mechanical traps that have really bitten, each one a pattern a regex
# can see. Add to it whenever a new one costs a round trip.
GML = [p for p in glob.glob("*/*/*.gml") if os.path.isfile(p)]


def strip_gml(src):
    """Comments and string bodies out, so a trap named in a comment (or
    a legitimate colon inside a string) is not reported as code."""
    out, i, n = [], 0, len(src)
    while i < n:
        c = src[i]
        if c == "/" and i + 1 < n and src[i + 1] == "/":
            while i < n and src[i] != "\n":
                i += 1
        elif c == "/" and i + 1 < n and src[i + 1] == "*":
            i += 2
            while i + 1 < n and not (src[i] == "*" and src[i + 1] == "/"):
                i += 1
            i += 2
        elif c == '"':
            out.append(' ')
            i += 1
            while i < n and src[i] != '"':
                i += 2 if src[i] == "\\" else 1
            i += 1
        else:
            out.append(c)
            i += 1
    return "".join(out)


srcs = {p: strip_gml(open(p, encoding="utf-8", errors="replace").read())
        for p in GML}

# --- 8a. scientific literals. `1e9` and `1e-9` are parse errors in GML,
# and the error the IDE reports names the enclosing statement rather
# than the number, which is what makes it expensive to find.
sci = []
for p, s in srcs.items():
    for m in re.finditer(r"(?<![A-Za-z0-9_.])\d+\.?\d*[eE][-+]?\d+", s):
        sci.append(f"{p}: {m.group(0)}")
check("no scientific number literals (1e9 is a GML parse error)",
      not sci, "; ".join(sci[:3]))

# --- 8a1. A STRUCT FIELD NAMED AFTER A GML CONSTANT. `{ pi : x }` and
# `_q.pi = x` are GM1031 ("the name 'pi' is an asset or constant and
# cannot be assigned to") - the dot and the literal key are parsed as the
# constant. The string accessor `[$ "pi"]` is fine, which is how it hid
# (2026-09-16: the quest's card place, three sites). infinity / NaN too.
const_field = []
for p, s in srcs.items():
    for m in re.finditer(r"(?:\.|[{,]\s*)(pi|infinity|NaN)\s*[:=](?!=)", s):
        const_field.append(f"{p}: {m.group(0).strip()}")
check("no struct field named after a GML constant (pi / infinity / NaN)",
      not const_field, "; ".join(const_field[:3]))

# --- 8a2. AN ACCESSOR ON A PARENTHESISED EXPRESSION. GML will not parse
# `(a ?? {})[$ "k"]` - an accessor hangs off a NAME or a CALL
# (`exped_biomes()[i]` is fine and shipped), never off a bare
# parenthesised group, so the struct has to take a `var` first. The IDE
# says "got '[$' expected ')'" plus "malformed assignment statement"
# against the line, which reads like a bracket typo. (2026-09-12:
# tiles_sync and tile_rarity_rate, the flux ladder's `fupg` reads.)
def _group_accessor(src):
    """-> the 1-based line of the first `)[` whose `)` closes a group
    that is not a call, or 0."""
    for m in re.finditer(r"\)\s*\[", src):
        depth, j = 0, m.start()
        while j >= 0:                       # walk back to the matching `(`
            if src[j] == ")": depth += 1
            elif src[j] == "(":
                depth -= 1
                if depth == 0: break
            j -= 1
        if j < 0: continue
        k = j - 1
        while k >= 0 and src[k] in " \t": k -= 1
        if k >= 0 and (src[k].isalnum() or src[k] == "_"):
            continue                        # name( ... )[ - a call, allowed
        return src.count("\n", 0, m.start()) + 1
    return 0

acc = []
for p, s2 in srcs.items():
    ln = _group_accessor(s2)
    if ln: acc.append(f"{p}:{ln}")
check("no accessor chained onto a parenthesised expression ((x ?? {})[$ k] is a GML parse error)",
      not acc, "; ".join(acc[:3]))

# --- 8b. CHAINED TERNARIES. GML will not parse `a ? b : c ? d : e` -
# a ternary's ELSE branch cannot itself be a bare ternary, it has to be
# parenthesised. The IDE reports "got '?' expected ',' or ')'" against
# the enclosing line, which reads like a typo in the argument list
# rather than a precedence rule, so it costs a round trip to find.
# (It cost one on 2026-09-08, in syst_rm_automation's Draw.)
#
# The walk tracks paren depth and, once a ternary's `:` has closed at
# some depth, watches for another `?` at that SAME depth before a comma,
# a semicolon, or the paren closing. Two ternaries side by side in one
# argument list are fine - a comma separates them - and a nested one
# inside parentheses is fine, because it sits deeper. That distinction
# is exactly what the rule is about, so the walk has to model it rather
# than pattern-match.
def _chained_ternary(src):
    """-> the 1-based line of the first chained ternary, or 0."""
    depth = 0
    line = 1
    pend = []        # paren depths with a ternary awaiting its ':'
    inelse = set()   # depths sitting in a ternary's else branch
    i, n = 0, len(src)
    while i < n:
        c = src[i]
        if c == "\n":
            line += 1
            i += 1
            continue
        # skip what is not code: strings, // and /* */
        if c == '"':
            i += 1
            while i < n and src[i] != '"':
                if src[i] == "\\\\":
                    i += 1
                elif src[i] == "\n":
                    line += 1
                i += 1
            i += 1
            continue
        if c == "/" and i + 1 < n and src[i + 1] == "/":
            while i < n and src[i] != "\n":
                i += 1
            continue
        if c == "/" and i + 1 < n and src[i + 1] == "*":
            i += 2
            while i + 1 < n and not (src[i] == "*" and src[i + 1] == "/"):
                if src[i] == "\n":
                    line += 1
                i += 1
            i += 2
            continue
        if c in "([":
            depth += 1
        elif c in ")]":
            for d in [x for x in inelse if x >= depth]:
                inelse.discard(d)
            while pend and pend[-1] >= depth:
                pend.pop()
            depth -= 1
        elif c in ",;":
            inelse.discard(depth)
        elif c == "?":
            if i + 1 < n and src[i + 1] == "?":   # null-coalescing, not a ternary
                i += 2
                continue
            if depth in inelse:
                return line
            pend.append(depth)
        elif c == ":":
            if pend and pend[-1] == depth:
                pend.pop()
                inelse.add(depth)
        i += 1
    return 0

tern = []
for p, s in srcs.items():
    ln = _chained_ternary(s)
    if ln:
        tern.append(p + ":" + str(ln))
check("no chained ternaries (GML needs the nested one in parens)",
      not tern, "; ".join(tern[:3]))

# --- 8c. brace / paren / bracket balance. Cheap, and a stray one turns
# into a wall of errors pointing anywhere but at the real line.
bal = []
for p, s in srcs.items():
    for o, c, what in (("{", "}", "braces"), ("(", ")", "parens"),
                       ("[", "]", "brackets")):
        if s.count(o) != s.count(c):
            bal.append(f"{p}: {what} {s.count(o) - s.count(c):+d}")
# --- 8f. a local named after one of its function's arguments. "cannot
# use argument name for a variable" is a hard compile error (tap_fire's
# `var _fx` shipped on 2026-09-10 behind an argument called _fx). The
# unit is each named function of a script (events have no arguments).
# Re-declaring a `var` twice in one event is LEGAL GML (the IDE's GM2044
# is a warning, and ~170 spots in this project do it) so that is not
# checked here.
_shadow = []
_VAR = re.compile(r"\bvar\s+([^;]+?);")
def _decl_names(_body):
    """the identifiers a `var a = f(x, y), b;` list declares: split on
    depth-0 commas, take the name before each `=`."""
    _out, _d, _part = [], 0, ""
    for _c in _body + ",":
        if _c in "([{": _d += 1
        elif _c in ")]}": _d -= 1
        if _c == "," and _d == 0:
            _m = re.match(r"\s*([A-Za-z_]\w*)", _part)
            if _m: _out.append(_m.group(1))
            _part = ""
        else:
            _part += _c
    return _out
for _p, _s in srcs.items():
    _units = re.split(r"\bfunction\s+\w+\s*\(", _s)
    _heads = re.findall(r"\bfunction\s+\w+\s*\(([^)]*)\)", _s)
    for _ui, _u in enumerate(_units):
        if _ui == 0 or _ui - 1 >= len(_heads):
            continue
        _args = {a.strip().split("=")[0].strip() for a in _heads[_ui - 1].split(",") if a.strip()}
        if not _args:
            continue
        for _m in _VAR.finditer(_u):
            for _nm in _decl_names(_m.group(1)):
                if _nm in _args:
                    _shadow.append(f"{_p}: var {_nm} is an argument")
check("no local named after one of its function's arguments",
      not _shadow, "; ".join(_shadow[:4]))

check("every .gml balances its braces, parens and brackets",
      not bal, "; ".join(bal[:3]))

# --- 8g. every asset NAME the code mentions is a registered resource.
# A sound/sprite/room/shader/object referenced by a prefix name that
# nothing registers is "variable not set before reading it" at the
# first run - snd_vibrate was written into obj_overcharge straight from
# DE on 2026-09-10 without porting the sound. Sources are comment- and
# string-stripped, so a name in a comment does not count. Exempt: every
# #macro (fnt_outline, scrl_faq...), any name the project ASSIGNS
# somewhere (instance/global variables such as obj_float's fnt_use or
# obj_puck's snd_pool) and each file's own `var` lists.
_unres = []
_PFX = re.compile(r"(?<![\w.])((?:snd|spr|rm|sh|obj|fnt|syst|scrl)_[A-Za-z0-9_]+)")
_defined = set()
for _s in srcs.values():
    _defined.update(re.findall(r"#macro\s+(\w+)", _s))
    _defined.update(re.findall(r"(?<![\w.])(\w+)\s*=(?!=)", _s))
for _p, _s in srcs.items():
    _locals = set()
    for _m in _VAR.finditer(_s):
        _locals.update(_decl_names(_m.group(1)))
    for _nm in sorted(set(_PFX.findall(_s))):
        if _nm in reg or _nm in _locals or _nm in _defined:
            continue
        _unres.append(f"{_p}: {_nm}")
check("every asset name the code mentions is registered",
      not _unres, "; ".join(_unres[:4]))

# --- 8h. no variable named after a #macro. A macro is textual: a
# `key = "";` where main_macros says `#macro key keyboard_check`
# compiles as `keyboard_check = ""` and the IDE reports three errors
# that name the macro's expansion, not the line that wrote it
# (syst_scene_light, 2026-09-11). Assignments and `var` declarations of
# any macro name, in any .gml, fail the build.
_macros = set()
for _s in srcs.values():
    _macros.update(re.findall(r"#macro\s+(\w+)", _s))
_mshadow = []
for _p, _s in srcs.items():
    for _m in re.finditer(r"(?<![\w.$])(\w+)\s*(?:=(?!=)|\+=|-=|\*=|/=)", _s):
        _nm = _m.group(1)
        if _nm in _macros and not re.search(r"#macro\s+" + _nm + r"\b", _s):
            _mshadow.append(f"{_p}: {_nm}")
    for _m in _VAR.finditer(_s):
        for _nm in _decl_names(_m.group(1)):
            if _nm in _macros:
                _mshadow.append(f"{_p}: var {_nm}")
check("no variable named after a #macro", not _mshadow, "; ".join(_mshadow[:4]))

# --- 8i. no primitive draw in a file that sets a shader. GM's
# draw_circle / draw_line / draw_rectangle / draw_triangle vertices
# carry no texcoord, and a shader that reads in_TextureCoord cannot
# build an input layout over them ("Could not generate input layout" -
# the battery crank under sh_ui_fade, 2026-09-11). The house draws in
# spr_pixel_1x1 stamps; a primitive in a file that also sets a shader
# (ui_fade_set counts) is flagged.
_prim = re.compile(r"(?<![\w.])(draw_circle|draw_line|draw_line_width|draw_rectangle|draw_triangle|draw_ellipse|draw_roundrect|draw_arrow|draw_primitive_begin)\s*\(")
_prims = []
for _p, _s in srcs.items():
    if "shader_set(" not in _s and "ui_fade_set(" not in _s and "__part(" not in _s:
        continue
    for _m in _prim.finditer(_s):
        _prims.append(f"{_p}: {_m.group(1)}")
check("no primitive draw (no texcoord) in a file that sets a shader", not _prims, "; ".join(_prims[:4]))

# --- 8d. every settings global reachable by handle_settings needs a
# BOOT default, or the very first load reads an unset global and the
# game dies at the splash. settings_defaults() does not count: it only
# runs when the player presses "reset settings". (Cost a round trip on
# 2026-09-07 - see settings_content's four-part checklist.)
hs = "scripts/handle_settings/handle_settings.gml"
if os.path.exists(hs):
    names = sorted(set(re.findall(r"g\.([A-Za-z_0-9]+)\s*=\s*handle\(",
                                  open(hs, encoding="utf-8").read())))
    unseeded = []
    for nme in names:
        pat = re.compile(r"(?:^|[^.\w])g\." + nme + r"\s*=(?!=)")
        seeded = any(pat.search(s) for p, s in srcs.items()
                     if "handle_settings" not in p
                     and "settings_defaults" not in p
                     and "settings_content" not in p)
        if not seeded:
            unseeded.append(nme)
    check("every settings global has a boot default (not just settings_defaults)",
          not unseeded, ", ".join(unseeded[:5]))

# ---------------------------------------------- 9. GLSL declarations
# Claude cannot compile a shader either, and GM reports a shader error
# as a line number in a build log the user has to go and find - so a
# broken shader costs a whole round trip. This catches the one class
# that has actually happened: REDECLARING A NAME IN THE SAME SCOPE.
#
# It cost five rounds on sh_mandel. `vec2 q` was added at the top of
# main() where a `float q` already lived further down; the redeclaration
# failed, `q` stayed a vec2 at the cardioid line, and its `<=` has no
# vector form. Two errors, neither of them at the line that changed, and
# four wrong guesses at the cause before the actual message was read.
#
# The scoping here is real, not approximated: a stack of scopes pushed
# and popped on braces, which is exactly GLSL's rule. `for (int i...)`
# headers are blanked first, because their declarations scope to the
# loop and two sibling loops may both use `i`.
GLSL = glob.glob("shaders/*/*.fsh") + glob.glob("shaders/*/*.vsh")
GTYPE = (r"\b(?:float|int|bool|void|"
         r"[ib]?vec[234]|mat[234]|sampler2D|samplerCube)\s+"
         r"([A-Za-z_]\w*)\s*(?=[=;,)])")


def blank_decl_parens(src):
    """Blank every paren group that DECLARES rather than uses -
    function parameter lists and for-headers. Both scope to their own
    construct, not to the enclosing block: two sibling loops may each
    declare `i`, and two functions may each take an `a`. Leaving them
    in made this check fire on the dd_* helpers, which are perfectly
    legal - and a rule that fails on working code is a wrong rule, not
    a found bug. (Second time today. It is a good tell.)"""
    out = list(src)
    for m in re.finditer(r"\(", src):
        i, depth = m.start(), 0
        while i < len(src):
            if src[i] == "(":
                depth += 1
            elif src[i] == ")":
                depth -= 1
                if depth == 0:
                    break
            i += 1
        # i is the CLOSING paren's index, and the slice must include it:
        # GTYPE's lookahead wants `=;,)` after the name, and a lone
        # `(vec3 p` has nothing after p. Excluding the paren blanked every
        # multi-parameter list (the comma satisfied it) and NO single-
        # parameter one - which is why this fired the first time a shader
        # had two `sd_thing(vec3 p)` helpers at file scope. (Third time a
        # rule was wrong rather than the code. Still a good tell.)
        if not re.search(GTYPE, src[m.start():i + 1]):
            continue          # a call, not a declaration
        for j in range(m.start(), min(i + 1, len(src))):
            out[j] = " "
    return "".join(out)


dup = []
for p in GLSL:
    src = blank_decl_parens(strip_gml(open(p, encoding="utf-8",
                                           errors="replace").read()))
    decls = [(m.start(), m.group(1)) for m in re.finditer(GTYPE, src)]
    scopes, di = [set()], 0
    for i, ch in enumerate(src):
        while di < len(decls) and decls[di][0] < i:
            nm = decls[di][1]
            if nm in scopes[-1]:
                line = src[:decls[di][0]].count(chr(10)) + 1
                dup.append(f"{p}:{line} redeclares '{nm}'")
            scopes[-1].add(nm)
            di += 1
        if ch == "{":
            scopes.append(set())
        elif ch == "}" and len(scopes) > 1:
            scopes.pop()
check("no GLSL name declared twice in one scope", not dup, "; ".join(dup[:3]))

# ==================================================================
# 12. THE .YYP RESOURCE ORDER
# ==================================================================
# The IDE rewrites this list on every save, and a hand-registered
# resource in the wrong slot is the one edit that survives the load and
# then quietly reorders the whole file the next time he opens the
# project - which turns a one-line diff into a four-hundred-line one and
# buries whatever else was in that commit.
#
# ⚖️ THE RULE, derived from the file itself and checked against all 420
# entries it had when this was written: resources are grouped BY TYPE in
# a fixed order, and within a type sorted case-insensitively with ONE
# quirk - '_' sorts BELOW the end of a name, everything else above it.
# That single rule explains both halves of the thing that keeps catching
# us out: `arb_log10` precedes `arb` (the extra part starts with '_'),
# while `snd_gold` precedes `snd_gold2` (it starts with a digit).
def _yyp_key(n):
    return [0 if c == "_" else ord(c) + 2 for c in n.lower()] + [1]


_yyp = load(YYP)
_seen, _segs = None, []
for _e in _yyp.get("resources", []):
    _k = _e["id"]["path"].split("/")[0]
    if _k != _seen:
        _segs.append((_k, []))
        _seen = _k
    _segs[-1][1].append(_e["id"]["name"])
_bad = []
_types = [k for k, _ in _segs]
if len(_types) != len(set(_types)):
    _bad.append("a resource TYPE appears in two blocks: " + ",".join(_types))
for _k, _names in _segs:
    _want = sorted(_names, key=_yyp_key)
    for _i, _n in enumerate(_names):
        if _n != _want[_i]:
            _bad.append(f"{_k}: '{_n}' should be '{_want[_i]}'")
            break
check("the .yyp resource list is in GM's own order", not _bad, "; ".join(_bad[:3]))

# ---- every registered .yy carries its resourceType + resourceVersion ----
# (2026-09-13: two hand-written object .yy files lacked both - the template
# was copied from a grep that had filtered those lines out - and GM refused
# the whole project: "Field resourceType: expected". The IDE never writes
# one without them; nor may we.)
_bad = []
for _e in _yyp.get("resources", []):
    _p = os.path.join(ROOT, _e["id"]["path"])
    if not os.path.exists(_p):
        _bad.append(_e["id"]["path"] + " (missing)")
        continue
    _t = open(_p, encoding="utf-8", errors="replace").read()
    if '"resourceType":' not in _t or '"resourceVersion":' not in _t:
        _bad.append(_e["id"]["path"])
check("every registered .yy has resourceType + resourceVersion", not _bad, "; ".join(_bad[:3]))

print("-" * 60)
if fails:
    print(f"{len(fails)} CHECK(S) FAILED: {', '.join(fails)}\n")
    sys.exit(1)
print("ALL CHECKS PASSED - the project should load\n")
