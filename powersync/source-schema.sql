-- Example for a PostgreSQL source database connected to PowerSync Cloud.
-- Run only in a database prepared for this sample.
CREATE TABLE public.todos (
  id text PRIMARY KEY,
  owner_id text NOT NULL,
  description text NOT NULL,
  completed boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now()
);

INSERT INTO public.todos (id, owner_id, description, completed) VALUES
  ('todo-1', 'sample-user', 'PowerSync Cloud から同期する', false),
  ('todo-2', 'sample-user', '機内モードで一覧を表示する', false);

-- If the powersync publication already exists, add this table to it instead.
CREATE PUBLICATION powersync FOR TABLE public.todos;
-- Grant SELECT on public.todos to the replication role configured in Cloud.
-- Also configure logical replication and role privileges for your DB provider.
