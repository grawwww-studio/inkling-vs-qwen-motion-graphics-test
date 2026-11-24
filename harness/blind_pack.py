#!/usr/bin/env python3 -I
"""Blind pack for the EP12 duel. Usage: blind_pack.py   (run in the duel dir after duel.sh ends)
Makes blind/<id>.png (6 evenly spaced frames + the hold frame) for every attempt that rendered, ids shuffled (seed 12),
mapping in SEALED-mapping.json (do not open until verdicts are written to blind_verdicts.json)."""
import glob, json, os, random, subprocess
D = os.path.dirname(os.path.abspath(__file__)); os.makedirs(f"{D}/blind", exist_ok=True)
items = []
for lg in sorted(glob.glob(f"{D}/renders/*/*/log.json")):
    L = json.load(open(lg)); d = os.path.dirname(lg); mp4 = f"{d}/{L['brief']}.mp4"
    if L.get("render_ok") and os.path.exists(mp4): items.append((L["model"], L["seed"], L["brief"], mp4))
random.Random(12).shuffle(items); mapping = {}
for i, (m, s, b, mp4) in enumerate(items):
    aid = f"X{i+1:02d}"; mapping[aid] = {"model": m, "seed": s, "brief": b, "mp4": mp4}
    dur = float(subprocess.check_output(["ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0", mp4]))
    N = round(dur * 24)
    fr = sorted({round(N * k / 9) for k in range(1, 9)} | {N - 3})
    vf = "select='" + "+".join(f"eq(n,{n})" for n in fr) + "',scale=640:-1,tile=3x3:padding=4:margin=4"
    subprocess.run(["ffmpeg", "-v", "error", "-y", "-i", mp4, "-vf", vf, "-vsync", "vfr", "-frames:v", "1", f"{D}/blind/{aid}.png"])
    open(f"{D}/blind/{aid}.dur", "w").write(f"{dur:.2f}\n")
    # the brief goes with the id so the grader reads the rubric text; the model never appears
    open(f"{D}/blind/{aid}.brief", "w").write(b + "\n")
json.dump(mapping, open(f"{D}/SEALED-mapping.json", "w"), indent=1)
print(len(items), "attempts packed")
