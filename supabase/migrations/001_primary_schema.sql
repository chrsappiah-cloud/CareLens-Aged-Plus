-- CareLens Aged+ — Supabase primary schema
-- Apply in Supabase SQL editor or via CLI

create table if not exists clients (
  id text primary key,
  record_type text default 'client',
  payload jsonb not null default '{}',
  updated_at timestamptz not null default now(),
  synced_at timestamptz
);

create table if not exists assessments (
  id text primary key,
  record_type text default 'assessment',
  payload jsonb not null default '{}',
  updated_at timestamptz not null default now(),
  synced_at timestamptz
);

create table if not exists care_plans (
  id text primary key,
  record_type text default 'care_plan',
  payload jsonb not null default '{}',
  updated_at timestamptz not null default now(),
  synced_at timestamptz
);

create table if not exists monitoring_events (
  id text primary key,
  record_type text default 'monitoring_event',
  payload jsonb not null default '{}',
  updated_at timestamptz not null default now(),
  synced_at timestamptz
);

create index if not exists idx_clients_updated on clients (updated_at desc);
create index if not exists idx_assessments_client on assessments ((payload->>'clientID'));

alter table clients enable row level security;
alter table assessments enable row level security;
alter table care_plans enable row level security;
alter table monitoring_events enable row level security;

-- Service role bypasses RLS; anon policies should be tightened per facility in production.
