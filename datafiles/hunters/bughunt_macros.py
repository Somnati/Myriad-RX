"""bughunt_macros.py - a struct FIELD or member named like a house MACRO (q264, after `lost.g` became `lost.global`).
#macro substitution is textual and blind to dots: `_m.lost.g` expands to `_m.lost.global` (GM1031 in Feather, and a
field the runtime never finds), `{ g : 1 }` the same. Flags every `.NAME` member access and every `NAME :` struct key
whose NAME is a #macro of the project. A macro whose body is a plain identifier renames the field the same on write and read (harmless); a keyword, a call or a path breaks it.
   usage: bughunt_macros.py   (run from the project root)"""
import io, re, glob

files = glob.glob("scripts/*/*.gml") + glob.glob("objects/*/*.gml")
code = {p: io.open(p, encoding="utf-8").read() for p in files}
alls = "\n".join(code.values())
# a macro whose body is a plain identifier (key -> keyboard_check) renames the field CONSISTENTLY on write and read - harmless;
# one whose body is a keyword (g -> global), a call (pair -> event_inherited()) or a path (delta -> system.syst_delta) breaks
bad = set()
for m in re.finditer(r"^\s*#macro\s+([A-Za-z_][A-Za-z0-9_]*)\s+(.*?)\s*(?://.*)?$", alls, flags=re.M):
    name, body = m.group(1), m.group(2).strip()
    if not re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", body) or body in ("global", "self", "other", "all", "noone", "undefined", "true", "false"):
        bad.add(name)

def strip(s):
    s = re.sub(r"//[^\n]*", "", s)
    s = re.sub(r"/\*.*?\*/", "", s, flags=re.S)
    s = re.sub(r'"(?:\\.|[^"\\])*"', '""', s)
    return s

n = 0
for p, s in code.items():
    t = strip(s)
    for ln, line in enumerate(t.split("\n"), 1):
        hits = set()
        for m in re.finditer(r"\.([A-Za-z_][A-Za-z0-9_]*)\b", line):
            if m.group(1) in bad: hits.add("." + m.group(1))
        for m in re.finditer(r"(?:[{,]\s*)([A-Za-z_][A-Za-z0-9_]*)\s*:(?!:)", line):
            if m.group(1) in bad: hits.add(m.group(1) + " :")
        if hits:
            print("macro-field  %-52s %5d  %s" % (p, ln, " ".join(sorted(hits))))
            n += 1
print("%d suspects" % n)
