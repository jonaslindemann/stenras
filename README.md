# Stenras!

En svensk programmeringsserie där man steg för steg bygger ett eget grottspel i [Processing](https://processing.org).

## Dokumentation

Tutorialen (på svenska) finns i `docs/` och byggs med [Zensical](https://zensical.org):

```bash
pip install zensical
python scripts/build_downloads.py   # packar mallar/lösningar till docs/downloads/
zensical serve    # förhandsgranska på http://localhost:8000
zensical build    # bygger statisk sajt till site/
```
