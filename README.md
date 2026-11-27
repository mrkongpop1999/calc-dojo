# mental-math

**Calc Dojo** — interactive website for learning mental arithmetic, from basic to advanced.

- 18 techniques in 3 levels (Basic / Intermediate / Advanced), each with an explanation, a step-by-step worked example and visuals (number line, area model, "prism split")
- Random practice problems with step-by-step hints; 5 correct in a row = technique passed
- Home page = start the game: Weak-spot report (time per technique vs your other techniques at the same level, plus accuracy; drill button), Tempo rating (weighted correct answers per minute), daily goal and day streak, GitHub-style heatmap (volume or accuracy), personal bests, weekly accuracy trend
- Play page: Sprint 60 s, or untimed with solutions; each run is saved and compared with your best
- Learn page holds the 18 techniques
- Pen mode in the Play page: two inks (pen 1 = answer, read as a number; pen 2 = scratch, never read). iPad: tap a pen; keyboard: keys 1 / 2. Handwriting is read by a small CNN that runs in the browser (`js/recog.js`, weights in `js/digit-model.js`, about 37 KB); when it is not sure it says so instead of marking the answer wrong. Training scripts are in `tools/` (numpy only, MNIST plus synthetic pen strokes).
- "Recommended next" strip: points to the technique you are weakest at (under 70% after 3+ attempts), else the next one not yet passed
- Optional login (email + password via Supabase) to sync progress across devices. Without login everything still works and is saved in the browser (localStorage).

Static site (`index.html`, `learn.html`, `play.html` + `css/`, `js/`). Open `index.html` or host on GitHub Pages. Tables: `supabase/schema.sql` (technique_progress, daily_stats, play_runs).

## Supabase setup

- Schema and row-level security: `supabase/schema.sql` (each user can only touch their own rows)
- `index.html` contains the project URL and the **publishable** key (safe to expose; RLS does the protecting). Never put a `service_role` / secret key in this file.
- In the Supabase dashboard, set **Authentication → URL Configuration → Site URL** to the hosted address (e.g. the GitHub Pages URL) so email-confirmation links come back to the app. For personal use you can also turn off **Confirm email** under Authentication → Sign In / Providers → Email.
- Login needs the page to be hosted somewhere that can reach `*.supabase.co`. The claude.ai artifact preview blocks outside connections, so login only works on the hosted copy.

Design: light liquid glass, "Prism" direction — see `DESIGN.md` and `PRODUCT.md`.
