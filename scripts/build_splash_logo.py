#!/usr/bin/env python3
"""Bake the splash logo + tagline into a single PNG.

Source logo:   assets/splash/logo_original.png
Output:        assets/splash/logo.png  (consumed by flutter_native_splash)

flutter_native_splash treats the source PNG as the xxxhdpi (@4x) baseline,
so the on-screen size in dp/pt equals source_px / 4. This script renders
everything in @4x pixel units to keep the dp-level layout readable.
"""

from PIL import Image, ImageDraw, ImageFont

SCALE = 4  # @4x — flutter_native_splash treats source as xxxhdpi.

LOGO_SOURCE = "assets/splash/logo_original.png"
OUTPUT = "assets/splash/logo.png"
ANDROID_LOGO_OUTPUT = "assets/splash/logo_android.png"
ANDROID12_ICON_OUTPUT = "assets/splash/logo_android12.png"
GRADIENT_OUTPUT = "assets/splash/bg_gradient.png"
TRANSPARENT_OUTPUT = "assets/splash/transparent.png"
FONT_PATH = "assets/fonts/helvetica_neue/HelveticaNeue-Roman.otf"

# Gradient stops from Figma `Bg Gradient` (top → bottom).
GRADIENT_TOP = (0x1D, 0x25, 0x34, 255)  # Blue/800 #1D2534
GRADIENT_BOTTOM = (0x02, 0x08, 0x15, 255)  # Blue/900 #020815
GRADIENT_W = 1080
GRADIENT_H = 2400

LOGO_TARGET_WIDTH_DP = 280
GAP_DP = 18
TAGLINE_FONT_DP = 14
TAGLINE_LINE_HEIGHT_DP = 20
TAGLINE_MAX_WIDTH_DP = 320
TAGLINE_COLOR = (158, 163, 174, 255)  # AppColors.textSecondary (#9EA3AE)
TAGLINE_TEXT = (
    "Performance nutrition optimizer built to support better "
    "performance and recovery."
)


def wrap_text(text: str, font: ImageFont.FreeTypeFont, max_width_px: int) -> list[str]:
    """Greedy word-wrap into lines whose rendered width fits max_width_px."""
    words = text.split()
    lines: list[str] = []
    current = ""
    for word in words:
        candidate = f"{current} {word}".strip()
        bbox = font.getbbox(candidate)
        if bbox[2] - bbox[0] <= max_width_px:
            current = candidate
        else:
            if current:
                lines.append(current)
            current = word
    if current:
        lines.append(current)
    return lines


def build_gradient() -> None:
    """Vertical linear gradient from GRADIENT_TOP to GRADIENT_BOTTOM."""
    canvas = Image.new("RGBA", (GRADIENT_W, GRADIENT_H))
    pixels = canvas.load()
    for y in range(GRADIENT_H):
        t = y / (GRADIENT_H - 1)
        r = round(GRADIENT_TOP[0] + (GRADIENT_BOTTOM[0] - GRADIENT_TOP[0]) * t)
        g = round(GRADIENT_TOP[1] + (GRADIENT_BOTTOM[1] - GRADIENT_TOP[1]) * t)
        b = round(GRADIENT_TOP[2] + (GRADIENT_BOTTOM[2] - GRADIENT_TOP[2]) * t)
        for x in range(GRADIENT_W):
            pixels[x, y] = (r, g, b, 255)
    canvas.save(GRADIENT_OUTPUT, "PNG")
    print(f"Wrote {GRADIENT_OUTPUT}  {GRADIENT_W}x{GRADIENT_H}px")


def build_transparent() -> None:
    """Transparent 768×768 placeholder for Android 12+ animated icon."""
    canvas = Image.new("RGBA", (768, 768), (0, 0, 0, 0))
    canvas.save(TRANSPARENT_OUTPUT, "PNG")
    print(f"Wrote {TRANSPARENT_OUTPUT}  768x768px")


def build_android_logo() -> None:
    """Wide WAILY wordmark only — used for Android post-system-splash
    `launch_background.xml` (no tagline on Android per design)."""
    src = Image.open(LOGO_SOURCE).convert("RGBA")
    target_w = 280 * SCALE
    target_h = round(src.height * (target_w / src.width))
    src = src.resize((target_w, target_h), Image.LANCZOS)
    src.save(ANDROID_LOGO_OUTPUT, "PNG")
    print(f"Wrote {ANDROID_LOGO_OUTPUT}  {target_w}x{target_h}px  ({target_w//SCALE}x{target_h//SCALE}dp)")


def build_android12_icon() -> None:
    """Square WAILY icon for Android 12+ animated splash icon.

    Android 12+ clips the icon to a circle of ~240dp visible inside a
    288dp container. The wordmark is scaled to fit comfortably inside
    that circle (width ≈ 200dp) and centered on a 288dp transparent
    canvas.
    """
    container_dp = 288
    wordmark_w_dp = 200

    canvas_size = container_dp * SCALE
    src = Image.open(LOGO_SOURCE).convert("RGBA")
    target_w = wordmark_w_dp * SCALE
    target_h = round(src.height * (target_w / src.width))
    src = src.resize((target_w, target_h), Image.LANCZOS)

    canvas = Image.new("RGBA", (canvas_size, canvas_size), (0, 0, 0, 0))
    x = (canvas_size - target_w) // 2
    y = (canvas_size - target_h) // 2
    canvas.paste(src, (x, y), src)
    canvas.save(ANDROID12_ICON_OUTPUT, "PNG")
    print(f"Wrote {ANDROID12_ICON_OUTPUT}  {canvas_size}x{canvas_size}px  ({container_dp}x{container_dp}dp)")


def main() -> None:
    build_gradient()
    build_transparent()
    build_android_logo()
    build_android12_icon()

    logo = Image.open(LOGO_SOURCE).convert("RGBA")

    target_logo_w = LOGO_TARGET_WIDTH_DP * SCALE
    target_logo_h = round(logo.height * (target_logo_w / logo.width))
    logo = logo.resize((target_logo_w, target_logo_h), Image.LANCZOS)

    font = ImageFont.truetype(FONT_PATH, TAGLINE_FONT_DP * SCALE)
    tagline_max_w_px = TAGLINE_MAX_WIDTH_DP * SCALE
    lines = wrap_text(TAGLINE_TEXT, font, tagline_max_w_px)

    line_height_px = TAGLINE_LINE_HEIGHT_DP * SCALE
    tagline_h_px = line_height_px * len(lines)

    gap_px = GAP_DP * SCALE
    canvas_w = max(target_logo_w, tagline_max_w_px)
    canvas_h = target_logo_h + gap_px + tagline_h_px

    canvas = Image.new("RGBA", (canvas_w, canvas_h), (0, 0, 0, 0))
    canvas.paste(logo, ((canvas_w - target_logo_w) // 2, 0), logo)

    draw = ImageDraw.Draw(canvas)
    text_y = target_logo_h + gap_px
    for line in lines:
        bbox = draw.textbbox((0, 0), line, font=font)
        line_w = bbox[2] - bbox[0]
        x = (canvas_w - line_w) // 2
        draw.text((x, text_y), line, font=font, fill=TAGLINE_COLOR)
        text_y += line_height_px

    canvas.save(OUTPUT, "PNG")
    print(f"Wrote {OUTPUT}  {canvas_w}x{canvas_h}px  ({canvas_w//SCALE}x{canvas_h//SCALE}dp)")


if __name__ == "__main__":
    main()
