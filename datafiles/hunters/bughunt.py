"""Static bug hunt over Myriad RX's GML:
 1. every CALL name(...) must be a GM builtin (fnames), a project script, a
    macro/function defined in a script body, or a method/var (x.y(...) or
    a local/instance var - we allow names assigned anywhere as vars)
 2. every resource-looking identifier (spr_/snd_/obj_/syst_/sh_/rm_/fnt_)
    must exist in the .yyp or as a macro
 3. numeric literals like 1e-4 (GML parse error)
 4. `key` used as a variable (macro clash)"""
import io, os, re, glob
R = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))   # the project root
os.chdir(R)
FN = r"C:\ProgramData\GameMakerStudio2\Cache\runtimes\runtime-2024.14.4.268\fnames"
builtins = set()
for l in io.open(FN, encoding="utf-8", errors="ignore"):
    l = l.strip()
    if not l or l.startswith("//"): continue
    m = re.match(r"([A-Za-z_][A-Za-z0-9_]*)", l)
    if m: builtins.add(m.group(1))
yyp = io.open("Myriad RX.yyp", encoding="utf-8").read()
resources = set(re.findall(r'"name":"([A-Za-z_][A-Za-z0-9_]*)","path":"', yyp))
gml = {}
for p in glob.glob("scripts/*/*.gml") + glob.glob("objects/*/*.gml"):
    gml[p] = io.open(p, encoding="utf-8", errors="ignore").read()
# strip comments and strings
def strip(s):
    s = re.sub(r"/\*.*?\*/", " ", s, flags=re.S)
    s = re.sub(r"//[^\n]*", " ", s)
    s = re.sub(r'"(?:\\.|[^"\\])*"', '""', s)
    s = re.sub(r"'(?:\\.|[^'\\])*'", "''", s)
    return s
code = {p: strip(s) for p, s in gml.items()}
alltext = "\n".join(code.values())
# names defined anywhere: function decls, macros, assignments (vars/methods), enums, 'function name'
defined = set(re.findall(r"\bfunction\s+([A-Za-z_]\w*)\s*\(", alltext))
defined |= set(re.findall(r"#macro\s+([A-Za-z_]\w*)", alltext))
defined |= set(re.findall(r"\b([A-Za-z_]\w*)\s*=\s*function\b", alltext))
defined |= set(re.findall(r"\b([A-Za-z_]\w*)\s*=\s*method\b", alltext))
defined |= set(re.findall(r"\b([A-Za-z_]\w*)\s*:\s*function\b", alltext))
assigned = set(re.findall(r"\b([A-Za-z_]\w*)\s*=[^=]", alltext)) | set(re.findall(r"\bvar\s+([A-Za-z_]\w*)", alltext))
enums = set(re.findall(r"enum\s+([A-Za-z_]\w*)", alltext))
keywords = {"if","else","for","while","repeat","with","switch","case","default","return","exit","break","continue","var","function","static","new","delete","do","until","and","or","not","xor","div","mod","begin","end","then","true","false","self","other","all","noone","global","undefined","infinity","pi","NaN","enum","try","catch","finally","throw","constructor","argument","argument_count","event_inherited","instance_exists","struct_exists"}
problems = []
for p, s in code.items():
    for m in re.finditer(r"(?<![\w.$])([A-Za-z_]\w*)\s*\(", s):
        n = m.group(1)
        if n in keywords or n in builtins or n in resources or n in defined or n in assigned or n in enums: continue
        if n.startswith("argument"): continue
        problems.append(("call", p, n))
    for m in re.finditer(r"(?<![\w.$])((?:spr|snd|obj|syst|sh|rm|fnt|par|bg|scrl)_[A-Za-z0-9_]+)\b", s):
        n = m.group(1)
        if n in resources or n in defined or n in assigned or n in builtins: continue
        problems.append(("res", p, n))
    for m in re.finditer(r"(?<![\w.])\d+(?:\.\d+)?[eE][-+]?\d+", s):
        problems.append(("sci", p, m.group(0)))
    for m in re.finditer(r"\bvar\s+key\b|\bkey\s*=[^=]", s):
        problems.append(("keyvar", p, m.group(0)))
from collections import Counter
seen = Counter()
for kind, p, n in problems:
    seen[(kind, p, n)] += 1
for (kind, p, n), c in sorted(seen.items()):
    print("%-6s %-60s %s x%d" % (kind, p, n, c))
print("builtins", len(builtins), "resources", len(resources), "problems", len(seen))
