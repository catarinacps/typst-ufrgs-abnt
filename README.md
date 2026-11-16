# A Typst Template for ABNT documents

This is far, far from ready.

## Fonts

The template sets its text in STIX Two Text, which is not bundled with Typst.
Typst packages cannot provide fonts, so a copy ships in `fonts/` (STIX Two
Text 2.13 b171, static OTF, under the SIL Open Font License, see
`fonts/OFL.txt`). Point the compiler at it:

```sh
typst compile --font-path <path-to-this-package>/fonts main.typ
```

or set `TYPST_FONT_PATHS` to that directory.
