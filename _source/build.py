"""Build the published Toyota Heritage PH page.

_source/toyota-philippines.html is the authoring source for the page. This script produces
index.html: the same document with every font and photograph pointed at the local copies in
assets/, so the site runs as a single self-contained file.
"""
import json
import re
import urllib.parse
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "_source" / "toyota-philippines.html"
OUT = ROOT / "index.html"

html = SRC.read_text(encoding="utf-8-sig")
img_map = json.loads((ROOT / "_source" / "image-map.json").read_text(encoding="utf-8-sig"))
local = {row["source"]: row["local"] for row in img_map}

# 1. Self-hosted fonts instead of the Google Fonts CDN
html = html.replace(
    '<link rel="preconnect" href="https://fonts.googleapis.com" />\n'
    '<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />\n'
    '<link href="https://fonts.googleapis.com/css2?family=Fraunces:ital,opsz,wght@0,9..144,400;0,9..144,500;0,9..144,600;0,9..144,700;0,9..144,900;1,9..144,400;1,9..144,500;1,9..144,700&family=Manrope:wght@300;400;500;600;700;800&family=JetBrains+Mono:wght@400;500;600&family=Petit+Formal+Script&display=swap" rel="stylesheet" />',
    '<link rel="stylesheet" href="assets/fonts.css" />',
)

# 2. Local favicon
html = html.replace(
    "<title>Toyota Heritage PH — A Legacy Built for the Road Ahead</title>",
    '<title>Toyota Heritage PH — A Legacy Built for the Road Ahead</title>\n'
    '<link rel="icon" href="assets/img/logo.png" />',
)

# 3. Inline <img src="...Special:FilePath/..."> -> local files
def swap_src(match: re.Match) -> str:
    raw = urllib.parse.unquote(match.group(1)).replace("_", " ")
    return 'src="%s"' % local.get(raw, match.group(0)[5:-1])

html = re.sub(r'src="https://commons\.wikimedia\.org/wiki/Special:FilePath/([^"]+)"', swap_src, html)

# 4. WM() helper resolves through the local manifest, CDN kept as fallback
old_wm = "const WM = f => `https://commons.wikimedia.org/wiki/Special:FilePath/${encodeURIComponent(f.replace(/ /g,'_'))}`;"
assert old_wm in html, "WM helper not found"
js_map = json.dumps(local, ensure_ascii=False, indent=2)
new_wm = (
    "/* Local asset manifest — every Wikimedia file used by this page, downloaded to assets/img. */\n"
    "const LOCAL_IMG = " + js_map + ";\n"
    "const WM = f => LOCAL_IMG[f] || `https://commons.wikimedia.org/wiki/Special:FilePath/${encodeURIComponent(f.replace(/ /g,'_'))}`;"
)
html = html.replace(old_wm, new_wm)

# 5. Drop the empty src on the lightbox image (avoid a stray request to the page URL)
html = html.replace('<img id="lbImg" src="" alt="" />', '<img id="lbImg" alt="" />')

# 6. Header comment (invisible to visitors)
html = html.replace(
    "<!DOCTYPE html>",
    "<!DOCTYPE html>\n<!--\n"
    "  Toyota Heritage PH — A Legacy Built for the Road Ahead\n"
    "  Designed & Developed by EJ Christian Medilo.\n"
    "  Assets: images in assets/img, fonts in assets/fonts.\n"
    "-->",
    1,
)

OUT.write_text(html, encoding="utf-8")

# Report any asset path in the HTML that is missing on disk
missing = [p for p in re.findall(r'(?:src|href)="(assets/[^"]+)"', html) if not (ROOT / p).exists()]
print(f"index.html written: {OUT.stat().st_size/1024:.1f} KB")
print("missing assets:", missing or "none")
