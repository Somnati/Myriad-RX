"""identifiers read as plain names in a set of GML files that are never assigned / declared in the owner's code
   usage: undef_scan.py <project root> <glob> [<glob> ...]   (globs relative to the root; the whole set is the owner's code)"""
import io, os, re, glob, sys
R = sys.argv[1]
os.chdir(R)
files = []
for g in sys.argv[2:]: files += glob.glob(g)
code = {p: io.open(p, encoding="utf-8").read() for p in files}
def strip(s):
    s = re.sub(r"//[^\n]*", "", s)
    s = re.sub(r"/\*.*?\*/", "", s, flags=re.S)
    s = re.sub(r'"(?:\\.|[^"\\])*"', '""', s)
    return s
allc = "\n".join(strip(s) for s in code.values())
assigned = set(re.findall(r"\b([A-Za-z_][A-Za-z0-9_]*)\s*(?:=(?!=)|\+=|-=|\*=|/=|\+\+|--|\?\?=)", allc))
declared = set(re.findall(r"\bvar\s+([A-Za-z_][A-Za-z0-9_]*)", allc))
declared |= set(re.findall(r"\bfunction\s+[A-Za-z_][A-Za-z0-9_]*\s*\(([^)]*)\)", allc) and
                [a.strip().split("=")[0].strip() for m in re.findall(r"\bfunction\s*[A-Za-z0-9_]*\s*\(([^)]*)\)", allc) for a in m.split(",") if a.strip()])
res = set()
for d in ("scripts", "objects", "sprites", "sounds", "rooms", "shaders", "fonts", "tilesets", "paths", "timelines", "sequences", "animcurves"):
    if os.path.isdir(d): res |= set(os.listdir(d))
alls = "\n".join(io.open(p, encoding="utf-8").read() for p in glob.glob("scripts/*/*.gml"))
mac = set(re.findall(r"#macro\s+([A-Za-z_][A-Za-z0-9_]*)", alls))
enums = set(re.findall(r"\benum\s+([A-Za-z_][A-Za-z0-9_]*)", alls))
# every GLOBAL assignment across the project (g.x = / global.x =) is not a plain identifier, skip
kw = set("if else for while do until repeat switch case default break continue return exit var static function new delete with and or not xor mod div true false undefined self other all noone global argument enum constructor try catch finally throw begin end then".split())
used = {}
for p, s in code.items():
    t = strip(s)
    for m in re.finditer(r"(?<![.\w$])([A-Za-z_][A-Za-z0-9_]*)\b(?!\s*[:(])", t):
        n = m.group(1)
        used.setdefault(n, set()).add(p)
# gml builtins: a list of the ones this project uses a lot, plus prefixes
builtin_exact = set("""x y id depth visible room delta_time current_time room_width room_height mouse_x mouse_y fps fps_real pi infinity NaN
image_index image_speed image_xscale image_yscale image_alpha image_blend image_angle sprite_index sprite_width sprite_height mask_index
bbox_left bbox_right bbox_top bbox_bottom object_index persistent solid alarm xstart ystart xprevious yprevious layer
fa_left fa_right fa_center fa_top fa_middle fa_bottom bm_normal bm_add bm_max bm_subtract bm_one bm_zero bm_src_alpha bm_inv_src_alpha bm_dest_alpha bm_inv_dest_alpha bm_src_colour bm_inv_src_colour bm_dest_colour bm_inv_dest_colour bm_src_alpha_sat
c_white c_black c_red c_green c_blue c_yellow c_gray c_grey c_ltgray c_dkgray c_orange c_purple c_aqua c_fuchsia c_lime c_maroon c_navy c_olive c_silver c_teal
mb_left mb_right mb_middle mb_none mb_any vk_left vk_right vk_up vk_down vk_space vk_enter vk_escape vk_shift vk_control vk_alt vk_backspace vk_tab vk_delete vk_f1 vk_f2 vk_f3 vk_f4 vk_f5 vk_f6 vk_f7 vk_f8 vk_f9 vk_f10 vk_f11 vk_f12 vk_home vk_end vk_pageup vk_pagedown vk_anykey vk_nokey
pr_pointlist pr_linelist pr_linestrip pr_trianglelist pr_trianglestrip pr_trianglefan
surface_rgba8unorm surface_rgba16float surface_rgba32float surface_r8unorm surface_rg8unorm surface_r16float surface_r32float
buffer_fixed buffer_grow buffer_wrap buffer_fast buffer_u8 buffer_s8 buffer_u16 buffer_s16 buffer_u32 buffer_s32 buffer_f16 buffer_f32 buffer_f64 buffer_bool buffer_string buffer_text buffer_u64 buffer_seek_start buffer_seek_relative buffer_seek_end
tf_point tf_linear tf_anisotropic mip_off mip_on mip_markedonly cull_noculling cull_clockwise cull_counterclockwise cmpfunc_always cmpfunc_never cmpfunc_less cmpfunc_equal cmpfunc_lessequal cmpfunc_greater cmpfunc_notequal cmpfunc_greaterequal
ev_create ev_destroy ev_step ev_draw ev_alarm ev_keyboard ev_mouse ev_collision ev_other ev_draw_begin ev_draw_end ev_gui ev_gui_begin ev_gui_end ev_step_begin ev_step_end ev_room_start ev_room_end ev_game_start ev_game_end ev_user0
os_windows os_android os_ios os_macosx os_linux os_type os_browser browser_not_a_browser
gamepad_axislh gamepad_axislv gamepad_axisrh gamepad_axisrv gp_face1 gp_face2 gp_face3 gp_face4 gp_shoulderl gp_shoulderr gp_shoulderlb gp_shoulderrb gp_select gp_start gp_stickl gp_stickr gp_padu gp_padd gp_padl gp_padr gp_axislh gp_axislv gp_axisrh gp_axisrv
cr_default cr_none cr_arrow cr_cross cr_beam cr_size_nesw cr_size_ns cr_size_nwse cr_size_we cr_uparrow cr_hourglass cr_drag cr_appstart cr_handpoint cr_size_all
matrix_view matrix_projection matrix_world argument_count keyboard_string keyboard_lastkey keyboard_key async_load event_data
display_aa gamepad_button_count instance_count instance_id path_index path_position program_directory working_directory temp_directory game_save_id
audio_falloff_none audio_falloff_linear_distance audio_falloff_exponent_distance ty_real ty_string
undefined true false noone all self other global""".split())
builtin_prefix = tuple(x for x in ("draw_", "string_", "array_", "surface_", "gpu_", "shader_", "buffer_", "mouse_", "keyboard_", "instance_", "point_", "room_", "sprite_", "audio_", "variable_", "struct_", "is_", "ds_", "colour_", "color_", "merge_", "make_", "layer_", "texture_", "vertex_", "matrix_", "date_", "get_", "window_", "display_", "os_", "game_", "event_", "show_", "font_", "image_", "view_", "camera_", "gamepad_", "device_", "json_", "file_", "ini_", "directory_", "url_", "http_", "asset_", "object_", "tag_", "collision_", "position_", "distance_", "motion_", "move_", "place_", "action_", "background_", "tile_", "part_", "network_", "screen_", "application_", "gc_", "load_", "parameter_", "handle_", "call_", "exception_", "int64", "nameof", "flexpanel", "method_", "weak_", "path_", "timeline_", "sequence_", "animcurve_", "effect_", "extension_", "steam_", "achievement_", "clipboard_", "cursor_", "physics_", "lengthdir_", "dot_", "angle_", "arc", "sha1_", "md5_", "base64_", "zip_", "highscore_", "score", "lives", "health", "keyboard_", "clickable_", "rollback_", "debug_", "fx_", "typeof", "real", "ord", "chr", "random", "irandom", "choose", "clamp", "lerp", "abs", "floor", "ceil", "round", "sign", "min", "max", "sqrt", "sqr", "power", "exp", "ln", "log2", "log10", "logn", "sin", "cos", "tan", "dsin", "dcos", "dtan", "darc", "frac", "mean", "median", "bool", "ptr", "int", "string", "array", "struct", "ptr", "matrix", "sleep", "alarm_", "layer", "yyc_", "gml_", "scheduler_", "environment_", "ptr_", "font", "tilemap_", "physics", "ads_", "iap_", "cloud_", "video_", "wallpaper_", "rc_", "uwp_", "xboxone_", "ps4_", "switch_", "steam_", "gamepad", "skeleton_", "sprite", "surface", "shader", "date", "room", "keyboard", "mouse", "audio", "vertex", "buffer", "draw", "texture", "layer", "camera", "view", "display", "window", "os", "game", "event", "instance", "object", "show", "file", "ini", "json", "http", "url", "network", "asset", "tag", "variable", "struct", "method", "is", "ds", "array", "string", "colour", "color", "merge", "make", "point", "distance", "position", "place", "move", "motion", "collision", "action", "background", "tile", "part", "screen", "application", "gc", "load", "parameter", "handle", "call", "exception", "flex", "weak", "path", "timeline", "sequence", "animcurve", "effect", "extension", "achievement", "clipboard", "cursor", "lengthdir", "dot", "angle", "sha1", "md5", "base64", "zip", "highscore", "clickable", "rollback", "debug", "fx") if x.endswith("_") or x in ("typeof","real","ord","chr","random","irandom","choose","clamp","lerp","abs","floor","ceil","round","sign","min","max","sqrt","sqr","power","exp","ln","log2","log10","logn","sin","cos","tan","dsin","dcos","dtan","darc","frac","mean","median","bool","int64","nameof","arc","sleep","string","array","struct","method","layer","font","real"))
unk = {}
for n, ps in used.items():
    if n in assigned or n in declared or n in res or n in mac or n in enums or n in kw or n in builtin_exact: continue
    if n.startswith("_") or n.startswith("argument"): continue
    if any(n.startswith(p) for p in builtin_prefix): continue
    unk[n] = ps
print("files", len(code), "used", len(used), "assigned", len(assigned), "unknown", len(unk))
for n in sorted(unk):
    print(n, sorted(os.path.basename(os.path.dirname(p)) + "/" + os.path.basename(p) for p in unk[n])[:4])
