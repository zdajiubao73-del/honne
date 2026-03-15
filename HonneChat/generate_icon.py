#!/usr/bin/env python3
"""
HonneChat App Icon Generator v7
コンセプト: 辛い時に開きたくなる × 一目でわかる
デザイン: 暗い夜空 × 大きく温かい会話バブル（輪郭くっきり）
"""

import math, random
import numpy as np
from PIL import Image, ImageDraw, ImageFilter

SIZE = 1024
ICON_PATH = "/Users/okubotomoya/Desktop/Projects/HonneChat/HonneChat/Assets.xcassets/AppIcon.appiconset"


def create_icon(size=1024, mode="light"):
    rng = random.Random(7)

    if mode == "tinted":
        bg_top      = (14, 14, 28)
        bg_bottom   = (6, 6, 16)
        star_c      = (160, 165, 185)
        bubble_rgb  = (170, 135, 80)
        inner_rgb   = (200, 165, 100)
        dot_c       = (255, 248, 220)
        glow_c      = (180, 140, 70)
    elif mode == "dark":
        bg_top      = (5, 6, 18)
        bg_bottom   = (2, 3, 10)
        star_c      = (200, 215, 255)
        bubble_rgb  = (215, 155, 45)
        inner_rgb   = (245, 190, 80)
        dot_c       = (255, 252, 230)
        glow_c      = (230, 160, 50)
    else:  # light
        bg_top      = (7, 9, 26)
        bg_bottom   = (2, 3, 14)
        star_c      = (205, 218, 255)
        bubble_rgb  = (225, 162, 48)
        inner_rgb   = (250, 196, 88)
        dot_c       = (255, 252, 228)
        glow_c      = (235, 168, 55)

    # ── 背景グラデーション ──────────────────────────
    img = Image.new("RGBA", (size, size), (0, 0, 0, 255))
    draw = ImageDraw.Draw(img)
    for y in range(size):
        t = y / size
        r = int(bg_top[0] + (bg_bottom[0] - bg_top[0]) * t)
        g = int(bg_top[1] + (bg_bottom[1] - bg_top[1]) * t)
        b = int(bg_top[2] + (bg_bottom[2] - bg_top[2]) * t)
        draw.line([(0, y), (size, y)], fill=(r, g, b, 255))

    # ── 星 ────────────────────────────────────────
    for _ in range(160):
        x = rng.randint(0, size)
        y = rng.randint(0, size)
        r = rng.choice([1, 1, 1, 2])
        a = rng.randint(80, 210)
        draw.ellipse([x-r, y-r, x+r, y+r], fill=(*star_c, a))

    # ── バブルの寸法（大きく・中央） ─────────────────
    cx, cy = size // 2, size // 2 - 30
    bw = int(size * 0.74)   # 横幅
    bh = int(size * 0.38)   # 縦幅
    br = 72                  # 角丸
    bx = cx - bw // 2
    by = cy - bh // 2
    tail_h = 70              # しっぽの長さ

    # ── バブルの後光（柔らかなグロー） ───────────────
    for exp, alpha in [(55, 22), (35, 40), (18, 62), (7, 80)]:
        gl = Image.new("RGBA", (size, size), (0, 0, 0, 0))
        gd = ImageDraw.Draw(gl)
        gd.rounded_rectangle(
            [bx-exp, by-exp, bx+bw+exp, by+bh+exp],
            radius=br+exp, fill=(*glow_c, alpha)
        )
        gl = gl.filter(ImageFilter.GaussianBlur(radius=exp * 1.5))
        img = Image.alpha_composite(img, gl)

    draw = ImageDraw.Draw(img)

    # ── バブル本体（グラデーション風：上が明るい） ───
    # 下地
    draw.rounded_rectangle([bx, by, bx+bw, by+bh], radius=br, fill=(*bubble_rgb, 252))
    # 上半分を少し明るく（光が当たっている感）
    bright = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    bd = ImageDraw.Draw(bright)
    bd.rounded_rectangle([bx, by, bx+bw, by+bh//2], radius=br, fill=(*inner_rgb, 180))
    bright = bright.filter(ImageFilter.GaussianBlur(radius=18))
    img = Image.alpha_composite(img, bright)
    draw = ImageDraw.Draw(img)

    # ── バブルのしっぽ（左下） ─────────────────────
    tx = bx + int(bw * 0.22)
    ty = by + bh
    draw.polygon([
        (tx - 28, ty - 2),
        (tx - 10, ty + tail_h),
        (tx + 42, ty - 2),
    ], fill=(*bubble_rgb, 252))

    # ── バブル内輝き（左上の反射） ────────────────
    shine = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    sd = ImageDraw.Draw(shine)
    sd.ellipse([bx+30, by+18, bx+bw-200, by+bh//2-20], fill=(255, 255, 255, 45))
    shine = shine.filter(ImageFilter.GaussianBlur(radius=22))
    img = Image.alpha_composite(img, shine)
    draw = ImageDraw.Draw(img)

    # ── 3点ドット（大きく・くっきり） ────────────────
    dot_y = by + bh // 2 + 4
    sp = 68
    dr = 20
    for dx_off in [-sp, 0, sp]:
        ddx = cx + dx_off
        draw.ellipse([ddx-dr, dot_y-dr, ddx+dr, dot_y+dr], fill=(*dot_c, 245))

    final = Image.new("RGB", (size, size))
    final.paste(img.convert("RGB"))
    return final


def main():
    for mode, fname in [("light","AppIcon-light"), ("dark","AppIcon-dark"), ("tinted","AppIcon-tinted")]:
        icon = create_icon(SIZE, mode=mode)
        icon.save(f"{ICON_PATH}/{fname}.png")
        print(f"{mode} -> {fname}.png")

if __name__ == "__main__":
    main()
