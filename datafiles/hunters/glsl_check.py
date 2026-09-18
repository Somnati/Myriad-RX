"""compile every GM shader (vsh + fsh) through a real GL context (moderngl / the NVIDIA driver) as GLSL ES 1.00 with
   GameMaker's preamble - the closest thing to the runner's own compile we can run without the game.
   usage: glsl_check.py <project root> [shader name ...]"""
import io, os, re, sys, glob
try:
    import moderngl
except ImportError:
    print("moderngl missing - python -m pip install moderngl (a real GL context is what compiles the shaders)")
    sys.exit(2)
R = sys.argv[1] if len(sys.argv) > 1 else os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
names = sys.argv[2:] or sorted(os.listdir(os.path.join(R, "shaders")))
PRE_V = """#version 100
#define MATRIX_VIEW 0
#define MATRIX_PROJECTION 1
#define MATRIX_WORLD 2
#define MATRIX_WORLD_VIEW 3
#define MATRIX_WORLD_VIEW_PROJECTION 4
#define MATRICES_MAX 5
uniform mat4 gm_Matrices[MATRICES_MAX];
uniform float gm_LightingEnabled;
uniform vec4 gm_AmbientColour;
uniform bool gm_VS_FogEnabled;
uniform float gm_FogStart;
uniform float gm_RcpFogRange;
#define MAX_VS_LIGHTS 8
uniform vec4 gm_Lights_Direction[MAX_VS_LIGHTS];
uniform vec4 gm_Lights_PosRange[MAX_VS_LIGHTS];
uniform vec4 gm_Lights_Colour[MAX_VS_LIGHTS];
"""
PRE_F = """#version 100
#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif
uniform sampler2D gm_BaseTexture;
uniform bool gm_PS_FogEnabled;
uniform vec4 gm_FogColour;
uniform bool gm_AlphaTestEnabled;
uniform float gm_AlphaRefValue;
#define MATRIX_VIEW 0
#define MATRIX_PROJECTION 1
#define MATRIX_WORLD 2
#define MATRIX_WORLD_VIEW 3
#define MATRIX_WORLD_VIEW_PROJECTION 4
#define MATRICES_MAX 5
uniform mat4 gm_Matrices[MATRICES_MAX];
"""
ctx = moderngl.create_standalone_context()
bad = 0
for n in names:
    d = os.path.join(R, "shaders", n)
    try:
        vs = io.open(os.path.join(d, n + ".vsh"), encoding="utf-8").read()
        fs = io.open(os.path.join(d, n + ".fsh"), encoding="utf-8").read()
    except FileNotFoundError as e:
        print(n, "missing", e); continue
    # GM strips a leading precision line of its own? no - keep the file as is; a file's own 'precision' after ours is legal
    try:
        prog = ctx.program(vertex_shader=PRE_V + vs, fragment_shader=PRE_F + fs)
        # varyings must match: moderngl links them, so a mismatch is a link error above
        print("ok   ", n)
        prog.release()
    except Exception as e:
        bad += 1
        msg = str(e)
        # the driver's line numbers count our preamble: shift them back for the fragment shader
        print("FAIL ", n)
        print("   " + msg.replace("\n", "\n   ")[:3000])
print("bad", bad, "of", len(names))
sys.exit(1 if bad else 0)
