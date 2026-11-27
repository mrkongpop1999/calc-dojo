-- Mental Math Lab: per-user progress, one row per technique.
-- Applied to the Supabase project as two migrations (create_technique_progress, tighten_technique_progress_grants).

create table public.technique_progress (
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  technique_id text not null check (char_length(technique_id) between 1 and 40),
  correct integer not null default 0 check (correct >= 0),
  wrong integer not null default 0 check (wrong >= 0),
  streak integer not null default 0 check (streak >= 0),
  timing jsonb not null default '[]'::jsonb, -- migration technique_progress_add_timing: last 40 first-attempt timings [ms, ok, question, epoch]
  best_streak integer not null default 0 check (best_streak >= 0),
  updated_at timestamptz not null default now(),
  primary key (user_id, technique_id)
);

alter table public.technique_progress enable row level security;

revoke all on public.technique_progress from anon;
grant select, insert, update, delete on public.technique_progress to authenticated;
revoke truncate, references, trigger on public.technique_progress from authenticated;

create policy "own rows select" on public.technique_progress
  for select to authenticated using ((select auth.uid()) = user_id);
create policy "own rows insert" on public.technique_progress
  for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "own rows update" on public.technique_progress
  for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "own rows delete" on public.technique_progress
  for delete to authenticated using ((select auth.uid()) = user_id);

-- Calc Dojo stats (migration: create_daily_stats_and_play_runs). Same own-row RLS and grants as above.
-- daily_stats: one row per user per local day (attempts, correct) -> heatmap.
-- play_runs: one row per finished sprint / free / exam run (client_id makes uploads idempotent) -> personal bests, Tempo history.
create table public.daily_stats (
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  day date not null,
  attempts integer not null default 0 check (attempts >= 0 and attempts <= 100000),
  correct integer not null default 0 check (correct >= 0 and correct <= attempts),
  updated_at timestamptz not null default now(),
  primary key (user_id, day)
);
create table public.play_runs (
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  client_id text not null check (char_length(client_id) between 1 and 60),
  played_at timestamptz not null,
  mode text not null check (mode in ('sprint','free','exam')),
  score integer not null check (score >= 0 and score <= 10000),
  total integer not null check (total >= score and total <= 10000),
  secs integer not null default 0 check (secs >= 0 and secs <= 86400),
  best_streak integer not null default 0 check (best_streak >= 0 and best_streak <= 10000),
  belt integer not null default 0 check (belt between 0 and 5),
  passed boolean not null default false,
  tempo numeric(6,2) check (tempo is null or (tempo >= 0 and tempo <= 1000)), -- migration play_runs_add_tempo; belt/passed are legacy, unused
  primary key (user_id, client_id)
);
-- (RLS enabled, anon revoked, authenticated limited to select/insert/update/delete, 4 own-row policies per table)
