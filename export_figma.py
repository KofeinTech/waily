#!/usr/bin/env python3
"""Figma full export for Waily Mobile App — Design page only.

Usage:
    export FIGMA_API_KEY=figd_xxxxx
    python3 export_figma.py

Exports all screens from the Design page to design/ folder.
Respects Figma API rate limits with 5s delay between calls.
"""

import json, os, re, sys, time, urllib.request, urllib.error

FILE_KEY = "fHb7WGklKtujnCbzxnLDdx"
TOKEN = os.environ.get("FIGMA_API_KEY", "")
DESIGN_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "design")
SCREENS_DIR = f"{DESIGN_DIR}/screens"
ASSETS_DIR = f"{DESIGN_DIR}/assets"
IMAGES_DIR = f"{ASSETS_DIR}/images"
RATE_LIMIT_DELAY = 5  # seconds between API calls

os.makedirs(SCREENS_DIR, exist_ok=True)
os.makedirs(ASSETS_DIR, exist_ok=True)
os.makedirs(IMAGES_DIR, exist_ok=True)

api_calls = 0

def api_get(url, retries=2):
    global api_calls
    for attempt in range(retries + 1):
        try:
            req = urllib.request.Request(url, headers={"X-Figma-Token": TOKEN})
            with urllib.request.urlopen(req, timeout=120) as resp:
                api_calls += 1
                data = json.loads(resp.read().decode())
                if data.get("err"):
                    print(f"  API error: {data['err']}")
                    return None
                return data
        except urllib.error.HTTPError as e:
            if e.code == 429:
                retry_after = int(e.headers.get("Retry-After", 30))
                print(f"  Rate limited, waiting {retry_after}s...")
                time.sleep(retry_after)
                continue
            elif e.code in (403, 404):
                print(f"  HTTP {e.code}: {e.reason}")
                return None
            else:
                print(f"  HTTP {e.code}, retrying...")
                time.sleep(5)
        except Exception as ex:
            print(f"  Network error: {ex}, retrying...")
            time.sleep(5)
    return None

def download_file(url, path):
    try:
        req = urllib.request.Request(url)
        with urllib.request.urlopen(req, timeout=60) as resp:
            with open(path, "wb") as f:
                f.write(resp.read())
        return os.path.getsize(path) > 0
    except Exception as ex:
        print(f"  Download failed: {ex}")
        return False

# ── Step 1: Get file structure (depth=2) to find Design page screens ──
print("Step 1: Fetching file structure...")
if not TOKEN:
    print("ERROR: FIGMA_API_KEY environment variable not set.")
    print("  export FIGMA_API_KEY=figd_xxxxx")
    sys.exit(1)

file_data = api_get(f"https://api.figma.com/v1/files/{FILE_KEY}?depth=2")
if not file_data:
    print("Failed to fetch file structure")
    sys.exit(1)

time.sleep(RATE_LIMIT_DELAY)

# Find Design page
design_page = None
for page in file_data["document"]["children"]:
    if "Design" in page["name"]:
        design_page = page
        break

if not design_page:
    print("No Design page found!")
    sys.exit(1)

# Collect screens (skip non-screen frames)
skip_prefixes = ("Tools/", "Components", "label")
screens = []
for child in design_page.get("children", []):
    if child.get("type") == "FRAME" and not any(child["name"].startswith(p) for p in skip_prefixes):
        screens.append({"id": child["id"], "name": child["name"]})

print(f"Found {len(screens)} screens on '{design_page['name']}' page")

# ── Step 2: Fetch full node data in batches of 15 ──
print("\nStep 2: Fetching screen data...")
all_nodes = {}
batch_size = 15
screen_ids = [s["id"] for s in screens]

for i in range(0, len(screen_ids), batch_size):
    batch = screen_ids[i:i+batch_size]
    ids_param = ",".join(batch)
    batch_num = i // batch_size + 1
    total_batches = (len(screen_ids) + batch_size - 1) // batch_size
    print(f"  Batch {batch_num}/{total_batches} ({len(batch)} screens)...")

    data = api_get(f"https://api.figma.com/v1/files/{FILE_KEY}/nodes?ids={ids_param}&geometry=paths")
    if data and "nodes" in data:
        for nid, ndata in data["nodes"].items():
            if ndata and "document" in ndata:
                all_nodes[nid] = ndata["document"]
    time.sleep(RATE_LIMIT_DELAY)

print(f"  Fetched {len(all_nodes)} screen nodes")

# ── Step 3: Fetch published styles ──
print("\nStep 3: Fetching published styles...")
styles_data = api_get(f"https://api.figma.com/v1/files/{FILE_KEY}/styles")
time.sleep(RATE_LIMIT_DELAY)

# ── Helper: convert Figma color to hex ──
def color_to_hex(c):
    if not c:
        return "#000000"
    r = round(c.get("r", 0) * 255)
    g = round(c.get("g", 0) * 255)
    b = round(c.get("b", 0) * 255)
    return f"#{r:02X}{g:02X}{b:02X}"

def enrich_color(c):
    if not c:
        return c
    return {**c, "hex": color_to_hex(c), "opacity": c.get("a", 1)}

def enrich_fill(fill):
    if not fill:
        return fill
    result = dict(fill)
    if "color" in fill:
        result["color"] = enrich_color(fill["color"])
        result["hex"] = color_to_hex(fill["color"])
        result["opacity"] = fill["color"].get("a", 1)
    return result

def enrich_effect(effect):
    if not effect:
        return effect
    result = dict(effect)
    if "color" in effect:
        result["color"] = enrich_color(effect["color"])
    return result

# ── Helper: sanitize filename (Unicode-aware) ──
def sanitize_filename(name):
    s = re.sub(r'(?<=[a-z])(?=[A-Z])', '_', name)
    s = re.sub(r'[^\w]+', '_', s.lower(), flags=re.UNICODE)
    s = s.strip('_')
    s = re.sub(r'_+', '_', s)
    return s if s else None

# ── Helper: check if name is generic ──
GENERIC_NAMES = re.compile(r'^(image|img|pic|photo|rect|rectangle|frame|group|vector|fill|mask|bitmap)[-_]?\d*$', re.IGNORECASE)

def is_generic_name(name):
    return bool(GENERIC_NAMES.match(name.strip()))

# ── Helper: process node tree recursively ──
def process_node(node, screen_name="", image_refs=None, icons=None, depth=0):
    if not isinstance(node, dict):
        return node
    if image_refs is None:
        image_refs = set()
    if icons is None:
        icons = []

    result = {}

    # Copy ALL properties
    for key, value in node.items():
        if key == "children":
            continue
        elif key == "fills" and isinstance(value, list):
            result["fills"] = [enrich_fill(f) for f in value]
        elif key == "strokes" and isinstance(value, list):
            result["strokes"] = [enrich_fill(f) for f in value]
        elif key == "effects" and isinstance(value, list):
            result["effects"] = [enrich_effect(e) for e in value]
        elif key == "backgroundColor" and isinstance(value, dict):
            result["backgroundColor"] = enrich_color(value)
        else:
            result[key] = value

    # Add convenience fields
    bbox = node.get("absoluteBoundingBox")
    if bbox:
        result["size"] = {"width": bbox.get("width", 0), "height": bbox.get("height", 0)}

    pt = node.get("paddingTop")
    if pt is not None:
        result["padding"] = {
            "top": node.get("paddingTop", 0),
            "right": node.get("paddingRight", 0),
            "bottom": node.get("paddingBottom", 0),
            "left": node.get("paddingLeft", 0),
        }

    if node.get("type") == "TEXT":
        style = node.get("style", {})
        if style:
            fs = style.get("fontSize", 16)
            lh = style.get("lineHeightPx", fs)
            result["typography"] = {
                "fontFamily": style.get("fontFamily", ""),
                "fontPostScriptName": style.get("fontPostScriptName", ""),
                "fontSize": fs,
                "fontWeight": style.get("fontWeight", 400),
                "italic": style.get("italic", False),
                "lineHeightPx": lh,
                "lineHeightRatio": round(lh / fs, 4) if fs else 1,
                "lineHeightUnit": style.get("lineHeightUnit", "PIXELS"),
                "letterSpacing": style.get("letterSpacing", 0),
                "textDecoration": style.get("textDecoration", "NONE"),
                "textCase": style.get("textCase", "ORIGINAL"),
            }

    # Track image fills
    for fill in node.get("fills", []):
        if isinstance(fill, dict) and fill.get("type") == "IMAGE":
            ref = fill.get("imageRef")
            if ref:
                image_refs.add(ref)
                result.setdefault("imageContext", {
                    "parent": node.get("name", "unknown"),
                    "imageRef": ref,
                })

    # Track icons — only nodes with "icon" in the name
    ntype = node.get("type", "")
    nname = node.get("name", "")
    if "icon" in nname.lower() and ntype in ("VECTOR", "LINE", "BOOLEAN_OPERATION", "INSTANCE", "COMPONENT", "FRAME"):
        icons.append({
            "id": node.get("id"),
            "name": nname,
            "type": ntype,
            "is_boolean": ntype == "BOOLEAN_OPERATION",
        })

    # Process children
    if "children" in node and isinstance(node["children"], list):
        result["children"] = []
        for child in node["children"]:
            processed = process_node(child, screen_name, image_refs, icons, depth + 1)
            result["children"].append(processed)

    return result

# ── Step 4: Process screens and build JSONs ──
print("\nStep 4: Building screen JSONs...")

all_colors = set()
all_typography = {}
all_spacing = set()
all_radii = set()
all_image_refs = set()
all_icons = []
screen_files = []

for screen in screens:
    sid = screen["id"]
    sname = screen["name"]

    if sid not in all_nodes:
        print(f"  SKIP (no data): {sname}")
        continue

    node = all_nodes[sid]
    image_refs = set()
    icons = []
    processed = process_node(node, sname, image_refs, icons)

    screen_json = {
        "exportedFrom": f"https://www.figma.com/design/{FILE_KEY}/Waily-Mobile-App",
        "exportedAt": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
        "screenName": sname,
        "node": processed,
    }

    fname = sanitize_filename(sname)
    if not fname:
        fname = f"screen_{sid.replace(':', '_')}"
    filepath = f"{SCREENS_DIR}/{fname}.json"

    if os.path.exists(filepath):
        filepath = f"{SCREENS_DIR}/{fname}_{sid.replace(':', '_')}.json"

    with open(filepath, "w", encoding="utf-8") as f:
        json.dump(screen_json, f, indent=2, ensure_ascii=False)

    screen_files.append(filepath)
    all_image_refs.update(image_refs)
    all_icons.extend(icons)

    def walk_tokens(n):
        if not isinstance(n, dict):
            return
        for fill in n.get("fills", []):
            if isinstance(fill, dict) and "hex" in fill:
                all_colors.add(fill["hex"])
        for stroke in n.get("strokes", []):
            if isinstance(stroke, dict) and "hex" in stroke:
                all_colors.add(stroke["hex"])
        typo = n.get("typography")
        if typo:
            key = f"{typo.get('fontFamily','')}-{typo.get('fontSize','')}-{typo.get('fontWeight','')}"
            all_typography[key] = typo
        for sp_key in ("itemSpacing", "counterAxisSpacing"):
            v = n.get(sp_key)
            if v is not None and v > 0:
                all_spacing.add(v)
        pad = n.get("padding")
        if pad:
            for pv in pad.values():
                if pv and pv > 0:
                    all_spacing.add(pv)
        cr = n.get("cornerRadius")
        if cr and cr > 0:
            all_radii.add(cr)
        rcr = n.get("rectangleCornerRadii")
        if rcr:
            for rv in rcr:
                if rv and rv > 0:
                    all_radii.add(rv)
        for child in n.get("children", []):
            walk_tokens(child)

    walk_tokens(processed)

print(f"  Saved {len(screen_files)} screen JSONs")

# ── Step 5: Export icons ──
print(f"\nStep 5: Exporting {len(all_icons)} icons...")

icon_map = {}
for ic in all_icons:
    if ic["id"] not in icon_map:
        icon_map[ic["id"]] = ic

safe_icons = {k: v for k, v in icon_map.items() if not v["is_boolean"]}
risky_icons = {k: v for k, v in icon_map.items() if v["is_boolean"]}

svg_count = 0
png_fallback_count = 0
png_fallback_names = []

if safe_icons:
    safe_ids = list(safe_icons.keys())
    for i in range(0, len(safe_ids), 50):
        batch = safe_ids[i:i+50]
        ids_param = ",".join(batch)
        print(f"  SVG batch {i//50+1} ({len(batch)} icons)...")
        data = api_get(
            f"https://api.figma.com/v1/images/{FILE_KEY}?ids={ids_param}&format=svg"
            f"&svg_simplify_stroke=true&svg_outline_text=true&use_absolute_bounds=true"
        )
        if data and "images" in data:
            for nid, url in data["images"].items():
                if not url:
                    risky_icons[nid] = safe_icons[nid]
                    continue
                ic = safe_icons[nid]
                fname = sanitize_filename(ic["name"]) or f"icon_{nid.replace(':', '_')}"
                fpath = f"{ASSETS_DIR}/{fname}.svg"
                if download_file(url, fpath):
                    with open(fpath, "r", errors="ignore") as svgf:
                        content = svgf.read()
                    has_visible = bool(re.search(r'<(path|circle|rect|polygon|line|ellipse)', content))
                    has_empty_filter = bool(re.search(r'<filter[^>]*>\s*</filter>', content))
                    if not has_visible or has_empty_filter or len(content) < 50:
                        os.remove(fpath)
                        risky_icons[nid] = safe_icons[nid]
                    else:
                        svg_count += 1
        time.sleep(RATE_LIMIT_DELAY)

if risky_icons:
    risky_ids = list(risky_icons.keys())
    for i in range(0, len(risky_ids), 50):
        batch = risky_ids[i:i+50]
        ids_param = ",".join(batch)
        print(f"  PNG fallback batch ({len(batch)} icons)...")
        data = api_get(
            f"https://api.figma.com/v1/images/{FILE_KEY}?ids={ids_param}&format=png&scale=3"
        )
        if data and "images" in data:
            for nid, url in data["images"].items():
                if not url:
                    continue
                ic = risky_icons[nid]
                fname = sanitize_filename(ic["name"]) or f"icon_{nid.replace(':', '_')}"
                fpath = f"{ASSETS_DIR}/{fname}.png"
                if download_file(url, fpath):
                    png_fallback_count += 1
                    png_fallback_names.append(f"{fname}.png")
        time.sleep(RATE_LIMIT_DELAY)

print(f"  SVG: {svg_count}, PNG fallback: {png_fallback_count}")
if png_fallback_names:
    print(f"  PNG fallback files: {', '.join(png_fallback_names[:10])}")

# ── Step 6: Download image fills ──
print(f"\nStep 6: Downloading image fills ({len(all_image_refs)} unique refs)...")

if all_image_refs:
    img_data = api_get(f"https://api.figma.com/v1/files/{FILE_KEY}/images")
    time.sleep(RATE_LIMIT_DELAY)

    if img_data and "meta" in img_data and "images" in img_data["meta"]:
        img_urls = img_data["meta"]["images"]
        downloaded = 0
        for ref in all_image_refs:
            url = img_urls.get(ref)
            if not url:
                continue
            fname = f"image_{ref[:12]}.png"
            fpath = f"{IMAGES_DIR}/{fname}"
            if not os.path.exists(fpath):
                if download_file(url, fpath):
                    downloaded += 1
        print(f"  Downloaded {downloaded} images")
    else:
        print("  No image URLs returned from API")
else:
    print("  No image fills found")

# ── Step 7: Save design tokens ──
print("\nStep 7: Saving design tokens...")

tokens = {
    "colors": sorted(list(all_colors)),
    "typography": list(all_typography.values()),
    "spacing": sorted(list(all_spacing)),
    "borderRadii": sorted(list(all_radii)),
}

tokens_path = f"{DESIGN_DIR}/tokens.json"
if os.path.exists(tokens_path):
    with open(tokens_path, "r") as f:
        existing = json.load(f)
    for key in ("colors", "spacing", "borderRadii"):
        merged = set(existing.get(key, []))
        merged.update(tokens.get(key, []))
        tokens[key] = sorted(list(merged))
    existing_typo = {f"{t.get('fontFamily','')}-{t.get('fontSize','')}-{t.get('fontWeight','')}": t
                     for t in existing.get("typography", [])}
    existing_typo.update(all_typography)
    tokens["typography"] = list(existing_typo.values())

with open(tokens_path, "w", encoding="utf-8") as f:
    json.dump(tokens, f, indent=2, ensure_ascii=False)

style_count = 0
if styles_data and "meta" in styles_data:
    style_count = len(styles_data["meta"].get("styles", []))

print(f"""
FIGMA EXPORT COMPLETE
{'='*40}
Source: https://www.figma.com/design/{FILE_KEY}/Waily-Mobile-App
Page:   {design_page['name']}

Files created:
  design/screens/    {len(screen_files)} screen JSON files
  design/tokens.json ({len(tokens['colors'])} colors, {len(tokens['typography'])} text styles, {len(tokens['spacing'])} spacing values, {len(tokens['borderRadii'])} radii)
  design/assets/     {svg_count} SVG icons, {png_fallback_count} PNG fallback icons
  design/assets/images/ {len(all_image_refs)} image fills

Published styles found: {style_count}
API calls used: {api_calls}
""")
