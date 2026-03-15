#!/usr/bin/env python3
"""
Freesound.org ASMR Downloader for HonneChat
=============================================

Setup:
  1. Register at https://freesound.org/apiv2/apply/ (無料)
  2. 「API credentials」でトークンをコピー
  3. export FREESOUND_TOKEN=your_token_here
  4. python3 download_asmr.py

Requirements:
  pip3 install requests  (already installed)
  ※ ffmpegは不要。MP3プレビューをそのまま使用します。

After running:
  - HonneChat/HonneChat/ に asmr_*.mp3 が保存されます
  - Xcodeで古い asmr_*.wav を削除し、新しい .mp3 を追加してください
"""

import os
import sys
import requests
from pathlib import Path

# ── Freesound API Token ──────────────────────────────────────────────────────
TOKEN = os.environ.get("FREESOUND_TOKEN", "")
if not TOKEN:
    print("=" * 50)
    print("ERROR: FREESOUND_TOKENが設定されていません")
    print()
    print("手順:")
    print("  1. https://freesound.org/apiv2/apply/ で無料登録")
    print("  2. アプリを作成してClient Credentialsを取得")
    print("  3. 以下を実行:")
    print("     export FREESOUND_TOKEN=your_token_here")
    print("     python3 download_asmr.py")
    print("=" * 50)
    sys.exit(1)

# ── Paths ────────────────────────────────────────────────────────────────────
SCRIPT_DIR = Path(__file__).parent
OUTPUT_DIR = SCRIPT_DIR / "HonneChat" / "HonneChat"
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

# ── Sound Map: filename → (freesound_id, license, attribution) ──────────────
# Freesound.org CC0/CC-BY音源
# ライセンス情報は ASMR_CREDITS.txt に出力されます
SOUNDS = {
    # 自然
    "asmr_crickets_wind":     (275640,  "CC0",   "seth-m"),
    "asmr_campfire_crackling": (620324, "CC-BY", "Freesound contributor"),
    "asmr_ocean_waves":       (578524,  "CC0",   "Freesound contributor"),
    "asmr_forest_birds":      (800712,  "CC0",   "KVV Audio"),
    "asmr_river_crickets":    (345144,  "CC0",   "LG"),
    "asmr_spring_wind_birds": (781115,  "CC0",   "Freesound contributor"),
    "asmr_arctic_wind":       (117136,  "CC-BY", "cobratronik"),
    # 室内
    "asmr_rain_cafe":         (702709,  "CC0",   "Thimblerig"),
    "asmr_bar_ambient":       (415974,  "CC-BY", "BurghRecords"),
    "asmr_snow_fireplace":    (680856,  "CC-BY", "Freesound contributor"),
    "asmr_library_quiet":     (765173,  "CC0",   "Freesound contributor"),
    "asmr_hot_spring":        (829622,  "CC0",   "Nox_Sound"),
    # 都会
    "asmr_city_wind":         (686064,  "CC-BY", "Freesound contributor"),
    "asmr_train_rumble":      (419478,  "CC0",   "Freesound contributor"),
    # 特別
    "asmr_festival_crowd":    (746444,  "CC-BY", "Freesound contributor"),
    "asmr_spaceship_hum":     (638442,  "CC0",   "GregorQuendel"),
}

API_BASE = "https://freesound.org/apiv2"
SESSION  = requests.Session()
SESSION.params = {"token": TOKEN}  # type: ignore

def get_sound_info(sound_id: int) -> dict:
    resp = SESSION.get(f"{API_BASE}/sounds/{sound_id}/")
    resp.raise_for_status()
    return resp.json()

def download_file(url: str, dest: Path) -> bool:
    resp = SESSION.get(url, stream=True)
    resp.raise_for_status()
    with open(dest, "wb") as f:
        for chunk in resp.iter_content(chunk_size=16384):
            f.write(chunk)
    return True

def main():
    print("HonneChat ASMR Downloader (Freesound.org)")
    print(f"出力先: {OUTPUT_DIR}\n")

    success = []
    failed  = []
    attributions = {}

    for fname, (sound_id, lic, attr) in SOUNDS.items():
        output_mp3 = OUTPUT_DIR / f"{fname}.mp3"

        # スキップ（既にダウンロード済み）
        if output_mp3.exists():
            size_kb = output_mp3.stat().st_size // 1024
            print(f"[SKIP] {fname}.mp3 ({size_kb} KB) - 既に存在します")
            success.append(fname)
            attributions[fname] = (sound_id, lic, attr)
            continue

        print(f"[{fname}] Freesound ID: {sound_id}")

        # 音源情報を取得
        try:
            info = get_sound_info(sound_id)
            title    = info.get("name", "Unknown")
            duration = info.get("duration", 0)
            actual_lic = info.get("license", lic)
            print(f"  タイトル : {title}")
            print(f"  長さ     : {duration:.1f}秒")
            print(f"  ライセンス: {actual_lic}")
        except requests.HTTPError as e:
            if e.response.status_code == 404:
                print(f"  [!] Sound ID {sound_id} が見つかりません")
                print(f"      → https://freesound.org/search/?q={fname.replace('_',' ')}")
                print(f"         で別のIDを探してスクリプト内のIDを更新してください")
            else:
                print(f"  [!] API エラー: {e}")
            failed.append(fname)
            continue
        except Exception as e:
            print(f"  [!] 取得失敗: {e}")
            failed.append(fname)
            continue

        # HQプレビューMP3をダウンロード（認証不要）
        previews = info.get("previews", {})
        url = previews.get("preview-hq-mp3") or previews.get("preview-lq-mp3")
        if not url:
            print(f"  [!] プレビューURLが取得できませんでした")
            failed.append(fname)
            continue

        print(f"  ダウンロード中...")
        try:
            download_file(url, output_mp3)
            size_kb = output_mp3.stat().st_size // 1024
            print(f"  完了 → {fname}.mp3 ({size_kb} KB)")
            success.append(fname)
            attributions[fname] = (sound_id, lic, attr)
        except Exception as e:
            print(f"  [!] ダウンロード失敗: {e}")
            failed.append(fname)

    # クレジットファイルを出力（CC-BY のためアトリビューション必須）
    credits_path = OUTPUT_DIR / "ASMR_CREDITS.txt"
    with open(credits_path, "w") as f:
        f.write("ASMR Sound Credits - HonneChat\n")
        f.write("=" * 40 + "\n")
        f.write("Sounds sourced from Freesound.org\n\n")
        for fn, (sid, lic, attribution) in attributions.items():
            f.write(f"{fn}.mp3\n")
            f.write(f"  License     : {lic}\n")
            if "CC-BY" in lic:
                f.write(f"  Attribution : {attribution} on Freesound.org\n")
            f.write(f"  Source      : https://freesound.org/s/{sid}/\n\n")
    print(f"\nクレジット → {credits_path}")

    # サマリー
    print(f"\n{'='*40}")
    print(f"成功: {len(success)}/{len(SOUNDS)}")
    if failed:
        print(f"失敗: {failed}")
        print()
        print("失敗した音源の対処法:")
        print("  1. https://freesound.org で直接検索")
        print("  2. このスクリプトの SOUNDS 辞書のIDを更新して再実行")
    print()
    print("次のステップ (Xcode):")
    print("  1. Xcodeで古い asmr_*.wav ファイルをすべて削除（Move to Trash）")
    print("  2. 新しい asmr_*.mp3 を Xcodeプロジェクトにドラッグ&ドロップ")
    print("  3. 「Copy items if needed」にチェックを入れてAdd")

if __name__ == "__main__":
    main()
