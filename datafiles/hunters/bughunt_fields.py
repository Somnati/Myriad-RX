"""Dot-reads of g.<struct>.<field> vs the fields ever ASSIGNED to that
struct anywhere (init literal keys, later g.x.f = ..., [$ "f"] = ...).
A field read via `.` that is never assigned is a runtime error in GM
2024 ("variable not set")."""
import io, re, glob, os, collections
os.chdir(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))   # the project root (datafiles/hunters/x.py)
def strip(s):
    s = re.sub(r"/\*.*?\*/", " ", s, flags=re.S)
    s = re.sub(r"//[^\n]*", " ", s)
    s = re.sub(r'"(?:\\.|[^"\\])*"', '""', s)
    return s
text = {p: strip(io.open(p, encoding="utf-8", errors="ignore").read()) for p in glob.glob("scripts/*/*.gml") + glob.glob("objects/*/*.gml")}
alls = "\n".join(text.values())
STRUCTS = ["rebirth", "tiles", "cheat", "tickets", "coin", "timebank", "autom", "unf", "obj", "battery", "ccore", "upg", "gift", "exped", "away", "credits_meta", "offline_report", "stats_hist", "power", "craft", "ngu"]
for st in STRUCTS:
    # fields assigned: g.st.f = / g.st.f += / g.st[$ "f"] = ; plus keys in the init literal(s): find `g.st = {` ... `}` blocks (nesting-aware, shallow)
    assigned = set(re.findall(r"\bg\." + st + r"\.([A-Za-z_]\w*)\s*(?:=[^=]|\+=|-=|\*=|/=|\+\+|--)", alls))
    assigned |= set(re.findall(r"\bg\." + st + r"\[\$\s*\"?([A-Za-z_]\w*)\"?\s*\]\s*=[^=]", alls))
    # locals aliasing: var _x = g.st; _x.f = ...
    aliases = set(re.findall(r"\bvar\s+(_\w+)\s*=\s*g\." + st + r"\s*;", alls))
    for a in aliases:
        assigned |= set(re.findall(r"\b" + a + r"\.([A-Za-z_]\w*)\s*(?:=[^=]|\+=|-=|\*=|/=|\+\+|--)", alls))
    for m in re.finditer(r"\bg\." + st + r"\s*=\s*\{", alls):
        i = m.end(); depth = 1; j = i
        while j < len(alls) and depth > 0:
            if alls[j] == "{": depth += 1
            elif alls[j] == "}": depth -= 1
            j += 1
        body = alls[i:j-1]
        # top-level keys only: strip nested braces
        flat = ""; d = 0
        for ch in body:
            if ch == "{": d += 1
            elif ch == "}": d -= 1
            elif d == 0: flat += ch
        assigned |= set(re.findall(r"(?:^|[,{\s])([A-Za-z_]\w*)\s*:", flat))
    reads = collections.defaultdict(set)
    for p, s in text.items():
        for m in re.finditer(r"\bg\." + st + r"\.([A-Za-z_]\w*)", s):
            reads[m.group(1)].add(p)
    if not assigned and not reads: continue
    bad = sorted(f for f in reads if f not in assigned)
    if bad:
        print("g.%s: %d assigned fields; NEVER-ASSIGNED reads:" % (st, len(assigned)))
        for f in bad:
            print("   .%-16s %s" % (f, ", ".join(sorted(x.replace("\\", "/") for x in reads[f]))[:110]))
print("done")
