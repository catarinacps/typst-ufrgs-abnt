// Paragraph leadings. The text box is exactly 1em tall (top-edge 0.7em,
// bottom-edge -0.3em), so the baseline-to-baseline pitch is 1em + leading.
// "Single" spacing is a 1.2em pitch (14.4pt at 12pt); the others are
// multiples of it, as in word processors' "1.5 lines" and "double".
#let single-spacing = 0.2em // pitch 1.2em
#let normal-spacing = 0.8em // pitch 1.8em = 1.5 x single (ABNT NBR 14724, 5.2)
#let double-spacing = 1.4em // pitch 2.4em = 2 x single

// Space above and below section titles: one blank 1.5-spaced line
// (ABNT NBR 14724, 5.2.2), i.e. the normal leading plus one 1.8em line.
#let section-spacing = normal-spacing + 1.8em

#let blank-line-spacing = v(double-spacing, weak: true)
