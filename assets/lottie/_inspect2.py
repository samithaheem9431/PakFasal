import json
from pathlib import Path

def summarize(path):
    d = json.loads(Path(path).read_text(encoding="utf-8"))
    assets = d.get("assets") or []
    print("FILE", path)
    print(" nm", d.get("nm"), "fr", d.get("fr"), "op", d.get("op"))
    for a in assets:
        keys = {k: a.get(k) for k in ("id","w","h","p","u","e") if k in a}
        p = str(a.get("p",""))
        if p.startswith("data:"):
            keys["p"] = "data:...len="+str(len(p))
        elif len(p) > 40:
            keys["p"] = p[:40]+"..."
        has_layers = "layers" in a
        print(" asset", keys, "precomp" if has_layers else "image")
    print()

for name in ["avalonia.json","avalonia2.json","sih.json","agro1.json"]:
    summarize(rf"d:\pakfasal_app\assets\lottie\_candidates\{name}")
