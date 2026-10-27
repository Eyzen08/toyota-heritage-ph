# Toyota Heritage PH

**Automotive website designed and developed by EJ Christian Medilo for a client project.**

An interactive brand experience built around Toyota's heritage in the Philippines — an editorial, scroll-driven
site with immersive photography, a 22-model catalogue, a heritage timeline, data visualisations, and a
responsive interface.

**Live site:** <https://toyota-heritage-ph.vercel.app> — open `index.html` to run it locally, no build step or
server required.

## Features

- **Hero** — parallax Fortuner shot, staggered headline reveal, creator pill.
- **Heritage timeline** — 6 eras with watermark years, tab navigation and prev/next controls.
- **Philippines in numbers** — 4 animated counters, model-popularity bar chart, category donut.
- **Vehicle catalogue** — 22 models with live search, 7 category filters, 3D-tilt cards, spec modal and compare tray.
- **Story** — 6-slide auto-rotating narrative with arrows and dots.
- **Innovation** — 5 switchable innovation panels with custom icon treatment.
- **Gallery** — 12-image mosaic with keyboard-navigable lightbox (← → Esc).
- **Campaign** — 3 campaign cards opening a detail modal.
- **Interface** — fixed glass navigation with scroll-spy, light/dark theme toggle (persisted), mobile burger
  menu, and `prefers-reduced-motion` support.

## Framework

No framework — plain **HTML, CSS and vanilla JavaScript** in a single self-contained file (`index.html`): no
build step, no dependencies, no API, no database. Fonts (Fraunces, Manrope, JetBrains Mono, Petit Formal Script)
and all photography are self-hosted in `assets/`, so the page works offline. It is deployed as a static site on
Vercel.

## Credits and licensing

**Designed & Developed by EJ Christian Medilo.**

The “Behind the journey” section presents the two client profiles credited on the project: Katrina Guillermo and
Trish Stephanie Cahanding.

Photography is sourced from Wikimedia Commons and used under Creative Commons licences — each original filename
is recorded in `_source/image-map.json` so attribution can be traced.

Toyota Heritage PH is an independent project. It is not affiliated with, endorsed by, or sponsored by Toyota
Motor Corporation or Toyota Motor Philippines. All vehicle names and trademarks belong to their respective
owners; “Toyota” and “Let's Go Places” are trademarks of Toyota Motor Corporation.
