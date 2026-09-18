"""Bare identifiers READ inside SCRIPTS before anything in the same script
sets them, that are not locals / params / builtins / resources / macros /
enums / struct keys - i.e. instance variables a script assumes its CALLER
has (the has_m crash, 2026-09-14). Usage: python bughunt_svars.py [name-prefix]"""
import io, re, glob, os, sys, collections
os.chdir(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))   # the project root (datafiles/hunters/x.py)
FN = r"C:\ProgramData\GameMakerStudio2\Cache\runtimes\runtime-2024.14.4.268\fnames"
builtins = set()
for l in io.open(FN, encoding="utf-8", errors="ignore"):
    m = re.match(r"([A-Za-z_][A-Za-z0-9_]*)", l.strip())
    if m: builtins.add(m.group(1))
yyp = io.open("Myriad RX.yyp", encoding="utf-8").read()
resources = set(re.findall(r'"name":"([A-Za-z_][A-Za-z0-9_]*)","path":"', yyp))
def strip(s):
    s = re.sub(r"/\*.*?\*/", " ", s, flags=re.S)
    s = re.sub(r"//[^\n]*", " ", s)
    s = re.sub(r'"(?:\\.|[^"\\])*"', '""', s)
    return s
allgml = {p: strip(io.open(p, encoding="utf-8", errors="ignore").read()) for p in glob.glob("scripts/*/*.gml") + glob.glob("objects/*/*.gml")}
alltext = "\n".join(allgml.values())
macros = set(re.findall(r"#macro\s+([A-Za-z_]\w*)", alltext))
enums = set(re.findall(r"enum\s+([A-Za-z_]\w*)", alltext))
funcs = set(re.findall(r"\bfunction\s+([A-Za-z_]\w*)\s*\(", alltext))
keywords = {"if","else","for","while","repeat","with","switch","case","default","return","exit","break","continue","var","function","static","new","delete","do","until","and","or","not","xor","div","mod","true","false","self","other","all","noone","global","undefined","infinity","pi","enum","try","catch","finally","throw","constructor","g","argument_count","then","begin","end","argument"}
prefix = sys.argv[1] if len(sys.argv) > 1 else ""
out = []
for p, s in allgml.items():
    if not p.startswith("scripts"): continue
    name = os.path.basename(os.path.dirname(p))
    if prefix and not name.startswith(prefix): continue
    locals_ = set()
    for m in re.finditer(r"\b(?:var|static)\s+([^;{}]*)", s):
        for part in m.group(1).split(","):
            mm = re.match(r"\s*([A-Za-z_]\w*)", part)
            if mm: locals_.add(mm.group(1))
    params = set()
    for m in re.finditer(r"function\s*\w*\s*\(([^)]*)\)", s):
        for a in m.group(1).split(","):
            a = a.strip().split("=")[0].strip()
            if a: params.add(a)
    structkeys = set(re.findall(r"(?<![\w.$])([A-Za-z_]\w*)\s*:(?!:)", s))
    bad = collections.Counter()
    seen = set()
    for m in re.finditer(r"(?<![\w.$#])([A-Za-z_]\w*)\b(?!\s*[:(])", s):
        n = m.group(1)
        if n in seen: continue
        seen.add(n)
        if n in keywords or n in builtins or n in resources or n in macros or n in enums or n in funcs: continue
        if n in locals_ or n in params or n in structkeys: continue
        if re.match(r"^(c_|vk_|mb_|fa_|bm_|ev_|ds_type_|os_|pt_|ps_)", n): continue
        # the FIRST occurrence: is it an assignment (a set) or a read?
        rest = s[m.end():]
        before = s[max(0, m.start() - 12):m.start()].rstrip()
        # "x = v" at a statement's start is a set; after if/while/(/&&/== it is legacy GML's comparison
        cmp_ctx = re.search(r"(?:\b(?:if|while|until|return|and|or|not|xor|else|case)|[(,!?<>=+\-*/\[&|])$", before) is not None
        if not cmp_ctx and re.match(r"\s*(?:=[^=]|\+=|-=|\*=|/=|\+\+|--)", rest): continue   # set first: the script owns it
        bad[n] += 1
    for n, c in bad.items(): out.append((name, n, c))
for name, n, c in sorted(out): print("%-28s %-24s" % (name, n))
print(len(out), "suspects")
