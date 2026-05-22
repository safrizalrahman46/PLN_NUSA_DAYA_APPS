-- Additive support objects for PLN Nusa Daya monitoring.
-- Safe to adapt when existing production tables already exist.

create table if not exists notifications (
  id uuid primary key,
  title text not null,
  description text not null,
  priority text not null default 'sedang',
  type text not null default 'general',
  target_type text not null default 'notificationDetail',
  user_id text,
  local_id text,
  error_log_id text,
  unit_id text,
  read boolean not null default false,
  payload jsonb not null default '{}'::jsonb,
  recipient_roles jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists error_logs (
  id uuid primary key,
  user_id text,
  user_name text,
  role text,
  page text not null,
  error_type text not null,
  message text not null,
  detail text,
  stack_trace text,
  status text not null default 'baru',
  source text not null default 'app',
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists audit_logs (
  id uuid primary key,
  entity_id text not null,
  user_id text not null,
  user_name text not null,
  role text not null,
  sync_status text not null,
  changes jsonb not null default '[]'::jsonb,
  edited_at timestamptz not null default now()
);

create table if not exists data_retention_logs (
  id uuid primary key,
  action text not null,
  affected_count integer not null default 0,
  file_name text,
  note text,
  created_at timestamptz not null default now()
);

create table if not exists report_download_logs (
  id uuid primary key,
  user_id text,
  user_name text,
  period_label text not null,
  file_name text not null,
  format text not null,
  filters jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

alter table if exists operator_inputs
  add column if not exists approval_status text not null default 'pendingReview',
  add column if not exists rejection_reason text not null default '',
  add column if not exists session_id text not null default '',
  add column if not exists last_edited_by text not null default '',
  add column if not exists last_edited_at timestamptz,
  add column if not exists archived_at timestamptz;

create or replace function archive_old_operator_inputs(retention_years integer default 5)
returns table(local_id text, archived_at timestamptz)
language plpgsql
as $$
begin
  return query
  update operator_inputs
     set archived_at = now()
   where archived_at is null
     and submitted_at < now() - make_interval(years => retention_years)
  returning operator_inputs.local_id, operator_inputs.archived_at;
end;
$$;

-- Example RLS snippets (adapt to existing auth strategy):
-- create policy operator_read_own_inputs on operator_inputs
--   for select using (operator_id = current_setting('request.jwt.claim.sub', true));
-- create policy supervisor_read_all_inputs on operator_inputs
--   for select using (
--     current_setting('request.jwt.claim.role', true) in ('supervisor', 'admin', 'superadmin')
--   );
