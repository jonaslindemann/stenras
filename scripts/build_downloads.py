"""Packar mallar och lösningar som zip-filer i docs/downloads/.

Kör före `zensical build` / `zensical serve`:

    python scripts/build_downloads.py
"""

import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "docs" / "downloads"

# Processing-sketcher som ska packas. Mappnamnet måste behållas i zip-filen
# eftersom Processing kräver att mappen heter som huvudfilen (.pde).

SKETCHES = [
    "stenras_mall_del1",
    "stenras_mall_del2",
    "stenras_mall_del3",
    "stenras_mall_del4",
    "stenras_losning_del1",
    "stenras_losning_del2",
    "stenras_losning_del3",
    "stenras_losning_del4",
    "stenras_utmaningar_del4",
]

IGNORE = {".DS_Store", "Thumbs.db"}


def zip_sketch(name):
    src = ROOT / name
    dst = OUT / f"{name}.zip"
    with zipfile.ZipFile(dst, "w", zipfile.ZIP_DEFLATED) as zf:
        for path in sorted(src.rglob("*")):
            if path.is_file() and path.name not in IGNORE:
                zf.write(path, path.relative_to(ROOT).as_posix())
    print(f"{dst.relative_to(ROOT)} ({dst.stat().st_size // 1024} kB)")


if __name__ == "__main__":
    OUT.mkdir(parents=True, exist_ok=True)
    for name in SKETCHES:
        zip_sketch(name)
