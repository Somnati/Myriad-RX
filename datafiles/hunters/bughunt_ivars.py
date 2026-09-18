"""Instance variables read in an object's events but never assigned in that
object (nor set on it from outside via `.name =`, nor a local var, nor a
builtin / script / macro / resource / global)."""
import io, re, glob, os, collections
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
funcs = set(re.findall(r"\bfunction\s+([A-Za-z_]\w*)\s*\(", alltext))
enums = set(re.findall(r"enum\s+([A-Za-z_]\w*)", alltext))
ext_set = set(re.findall(r"\.([A-Za-z_]\w*)\s*(?:=[^=]|\+=|-=)", alltext))   # set on some instance/struct from outside
keywords = {"if","else","for","while","repeat","with","switch","case","default","return","exit","break","continue","var","function","static","new","delete","do","until","and","or","not","xor","div","mod","true","false","self","other","all","noone","global","undefined","infinity","pi","enum","try","catch","finally","throw","constructor","g","argument_count","then","begin","end"}
objs = collections.defaultdict(dict)
for p in glob.glob("objects/*/*.gml"):
    o = p.split(os.sep)[1] if os.sep in p else p.split("/")[1]
    objs[o][p] = allgml[p]
# scripts run in the caller's scope: instance vars they set count for every object (crudely) - collect names assigned at top level of scripts
script_sets = set(re.findall(r"(?m)^\s*([A-Za-z_]\w*)\s*(?:=[^=]|\+=|-=|\+\+|--)", "\n".join(v for k, v in allgml.items() if k.startswith("scripts"))))
report = []
for o, files in objs.items():
    own = "\n".join(files.values())
    assigned = set(re.findall(r"(?<![\w.$])([A-Za-z_]\w*)\s*(?:=[^=]|\+=|-=|\*=|/=|\+\+|--)", own))
    assigned |= set(re.findall(r"(?<![\w.$])([A-Za-z_]\w*)\s*\[[^\]]*\]\s*(?:=[^=]|\+=|-=)", own))
    for p, s in files.items():
        locals_ = set(re.findall(r"\bvar\s+([A-Za-z_]\w*)", s)) | set(re.findall(r",\s*([A-Za-z_]\w*)\s*=", s))
        # function params
        for m in re.finditer(r"function\s*\(([^)]*)\)", s):
            for a in m.group(1).split(","):
                a = a.strip().split("=")[0].strip()
                if a: locals_.add(a)
        for m in re.finditer(r"(?<![\w.$])([A-Za-z_]\w*)\b(?!\s*\()", s):
            n = m.group(1)
            if n in keywords or n in builtins or n in resources or n in macros or n in funcs or n in enums: continue
            if n in locals_ or n in assigned or n in ext_set or n in script_sets: continue
            if n.startswith("_") or n.startswith("argument"): continue
            report.append((o, p, n))
seen = collections.Counter(report)
for (o, p, n), c in sorted(seen.items()):
    print("%-26s %-40s %s x%d" % (o, p.replace("\\", "/").split("/")[-1], n, c))
print(len(seen), "suspects")
