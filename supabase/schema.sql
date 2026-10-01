-- ==============================================================================
-- TASKFLOW - PRODUCTION POSTGRESQL SCHEMA FOR SUPABASE FREE TIER
-- ==============================================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. PROFILES TABLE (Linked with Supabase auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT UNIQUE NOT NULL,
    full_name TEXT,
    avatar_url TEXT,
    job_title TEXT DEFAULT 'Productivity Enthusiast',
    bio TEXT DEFAULT 'Organizing my universe with TaskFlow.',
    theme_mode TEXT DEFAULT 'system',
    accent_color TEXT DEFAULT '#6366F1',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 2. PROJECTS TABLE
CREATE TABLE IF NOT EXISTS public.projects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    color TEXT DEFAULT '#6366F1',
    icon TEXT DEFAULT 'folder',
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'completed', 'archived', 'paused')),
    start_date TIMESTAMP WITH TIME ZONE,
    deadline TIMESTAMP WITH TIME ZONE,
    progress INTEGER DEFAULT 0 CHECK (progress >= 0 AND progress <= 100),
    is_favorite BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 3. PROJECT MEMBERS TABLE (Team Collaboration)
CREATE TABLE IF NOT EXISTS public.project_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES public.projects(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    role TEXT DEFAULT 'member' CHECK (role IN ('owner', 'admin', 'member', 'viewer')),
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    UNIQUE (project_id, user_id)
);

-- 4. TASKS TABLE
CREATE TABLE IF NOT EXISTS public.tasks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    project_id UUID REFERENCES public.projects(id) ON DELETE SET NULL,
    title TEXT NOT NULL,
    description TEXT,
    status TEXT DEFAULT 'todo' CHECK (status IN ('todo', 'in_progress', 'review', 'completed', 'archived')),
    priority TEXT DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
    due_date DATE,
    due_time TIME,
    start_date DATE,
    estimated_duration_minutes INTEGER DEFAULT 30,
    category TEXT DEFAULT 'General',
    assignee_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    is_recurring BOOLEAN DEFAULT false,
    recurrence_pattern TEXT, -- 'daily', 'weekly', 'monthly', 'custom'
    reminder_at TIMESTAMP WITH TIME ZONE,
    is_deleted BOOLEAN DEFAULT false, -- Soft delete for Trash support
    deleted_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    completed_at TIMESTAMP WITH TIME ZONE
);

-- 5. SUBTASKS TABLE
CREATE TABLE IF NOT EXISTS public.subtasks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    task_id UUID NOT NULL REFERENCES public.tasks(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    is_completed BOOLEAN DEFAULT false,
    position INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 6. TASK COMMENTS TABLE
CREATE TABLE IF NOT EXISTS public.task_comments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    task_id UUID NOT NULL REFERENCES public.tasks(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 7. TASK ATTACHMENTS TABLE
CREATE TABLE IF NOT EXISTS public.task_attachments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    task_id UUID NOT NULL REFERENCES public.tasks(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    file_name TEXT NOT NULL,
    file_url TEXT NOT NULL,
    file_size INTEGER DEFAULT 0,
    file_type TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 8. TAGS TABLE
CREATE TABLE IF NOT EXISTS public.tags (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    color TEXT DEFAULT '#3B82F6',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    UNIQUE (user_id, name)
);

-- 9. TASK_TAGS JUNCTION TABLE
CREATE TABLE IF NOT EXISTS public.task_tags (
    task_id UUID NOT NULL REFERENCES public.tasks(id) ON DELETE CASCADE,
    tag_id UUID NOT NULL REFERENCES public.tags(id) ON DELETE CASCADE,
    PRIMARY KEY (task_id, tag_id)
);

-- 10. NOTIFICATIONS TABLE
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    type TEXT NOT NULL CHECK (type IN (
        'task_assigned', 'task_completed', 'task_overdue', 'comment_added',
        'mention', 'project_update', 'reminder', 'deadline_approaching', 'system'
    )),
    data JSONB DEFAULT '{}'::jsonb,
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 11. RECURRING TASKS CONFIG TABLE
CREATE TABLE IF NOT EXISTS public.recurring_tasks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    task_template_id UUID NOT NULL REFERENCES public.tasks(id) ON DELETE CASCADE,
    recurrence_type TEXT NOT NULL CHECK (recurrence_type IN ('daily', 'weekly', 'monthly', 'custom')),
    interval_val INTEGER DEFAULT 1,
    next_run_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 12. TASK REMINDERS TABLE
CREATE TABLE IF NOT EXISTS public.task_reminders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    task_id UUID NOT NULL REFERENCES public.tasks(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    remind_at TIMESTAMP WITH TIME ZONE NOT NULL,
    is_sent BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- ==============================================================================
-- INDEXES FOR MAXIMUM QUERY PERFORMANCE
-- ==============================================================================
CREATE INDEX IF NOT EXISTS idx_tasks_user_id ON public.tasks(user_id);
CREATE INDEX IF NOT EXISTS idx_tasks_project_id ON public.tasks(project_id);
CREATE INDEX IF NOT EXISTS idx_tasks_status ON public.tasks(status);
CREATE INDEX IF NOT EXISTS idx_tasks_priority ON public.tasks(priority);
CREATE INDEX IF NOT EXISTS idx_tasks_due_date ON public.tasks(due_date);
CREATE INDEX IF NOT EXISTS idx_tasks_is_deleted ON public.tasks(is_deleted);
CREATE INDEX IF NOT EXISTS idx_subtasks_task_id ON public.subtasks(task_id);
CREATE INDEX IF NOT EXISTS idx_comments_task_id ON public.task_comments(task_id);
CREATE INDEX IF NOT EXISTS idx_attachments_task_id ON public.task_attachments(task_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_projects_user_id ON public.projects(user_id);

-- ==============================================================================
-- AUTOMATIC TIMESTAMP UPDATERS
-- ==============================================================================
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = TIMEZONE('utc'::text, NOW());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_profiles_updated_at ON public.profiles;
CREATE TRIGGER set_profiles_updated_at
BEFORE UPDATE ON public.profiles
FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS set_projects_updated_at ON public.projects;
CREATE TRIGGER set_projects_updated_at
BEFORE UPDATE ON public.projects
FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS set_tasks_updated_at ON public.tasks;
CREATE TRIGGER set_tasks_updated_at
BEFORE UPDATE ON public.tasks
FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- Auto create profile on user registration
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, email, full_name, avatar_url)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
        COALESCE(NEW.raw_user_meta_data->>'avatar_url', '')
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Auto recalculate project progress trigger
CREATE OR REPLACE FUNCTION public.calculate_project_progress()
RETURNS TRIGGER AS $$
DECLARE
    target_project_id UUID;
    total_count INTEGER;
    completed_count INTEGER;
    new_progress INTEGER := 0;
BEGIN
    target_project_id := COALESCE(NEW.project_id, OLD.project_id);
    IF target_project_id IS NOT NULL THEN
        SELECT COUNT(*), COUNT(*) FILTER (WHERE status = 'completed')
        INTO total_count, completed_count
        FROM public.tasks
        WHERE project_id = target_project_id AND is_deleted = false;

        IF total_count > 0 THEN
            new_progress := ROUND((completed_count::NUMERIC / total_count::NUMERIC) * 100);
        ELSE
            new_progress := 0;
        END IF;

        UPDATE public.projects
        SET progress = new_progress, updated_at = NOW()
        WHERE id = target_project_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS on_task_status_changed ON public.tasks;
CREATE TRIGGER on_task_status_changed
AFTER INSERT OR UPDATE OF status, is_deleted, project_id OR DELETE ON public.tasks
FOR EACH ROW EXECUTE FUNCTION public.calculate_project_progress();

-- ==============================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ==============================================================================

-- Enable RLS on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.project_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subtasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.task_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.task_attachments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.task_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recurring_tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.task_reminders ENABLE ROW LEVEL SECURITY;

-- 1. PROFILES POLICIES
CREATE POLICY "Public profiles are viewable by authenticated users"
ON public.profiles FOR SELECT TO authenticated USING (true);

CREATE POLICY "Users can update their own profile"
ON public.profiles FOR UPDATE TO authenticated USING (auth.uid() = id);

-- 2. PROJECTS POLICIES
CREATE POLICY "Users can view their own projects or projects they are member of"
ON public.projects FOR SELECT TO authenticated
USING (
    auth.uid() = user_id OR
    EXISTS (SELECT 1 FROM public.project_members WHERE project_id = id AND user_id = auth.uid())
);

CREATE POLICY "Users can create projects"
ON public.projects FOR INSERT TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Owners and project admins can update projects"
ON public.projects FOR UPDATE TO authenticated
USING (
    auth.uid() = user_id OR
    EXISTS (SELECT 1 FROM public.project_members WHERE project_id = id AND user_id = auth.uid() AND role IN ('owner', 'admin'))
);

CREATE POLICY "Only project creators can delete projects"
ON public.projects FOR DELETE TO authenticated
USING (auth.uid() = user_id);

-- 3. PROJECT MEMBERS POLICIES
CREATE POLICY "Project members can view membership"
ON public.project_members FOR SELECT TO authenticated
USING (
    EXISTS (SELECT 1 FROM public.projects WHERE id = project_id AND (user_id = auth.uid() OR EXISTS (
        SELECT 1 FROM public.project_members pm WHERE pm.project_id = project_id AND pm.user_id = auth.uid()
    )))
);

CREATE POLICY "Project creators or admins can manage members"
ON public.project_members FOR ALL TO authenticated
USING (
    EXISTS (SELECT 1 FROM public.projects WHERE id = project_id AND user_id = auth.uid())
);

-- 4. TASKS POLICIES
CREATE POLICY "Users can view tasks assigned, created or in their projects"
ON public.tasks FOR SELECT TO authenticated
USING (
    auth.uid() = user_id OR
    auth.uid() = assignee_id OR
    EXISTS (
        SELECT 1 FROM public.projects p
        WHERE p.id = project_id AND (
            p.user_id = auth.uid() OR
            EXISTS (SELECT 1 FROM public.project_members WHERE project_id = p.id AND user_id = auth.uid())
        )
    )
);

CREATE POLICY "Users can create tasks"
ON public.tasks FOR INSERT TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Task creators or assignees can update tasks"
ON public.tasks FOR UPDATE TO authenticated
USING (
    auth.uid() = user_id OR
    auth.uid() = assignee_id OR
    EXISTS (
        SELECT 1 FROM public.projects p
        WHERE p.id = project_id AND (
            p.user_id = auth.uid() OR
            EXISTS (SELECT 1 FROM public.project_members WHERE project_id = p.id AND user_id = auth.uid() AND role IN ('owner', 'admin', 'member'))
        )
    )
);

CREATE POLICY "Task creators can delete tasks"
ON public.tasks FOR DELETE TO authenticated
USING (auth.uid() = user_id);

-- 5. SUBTASKS POLICIES
CREATE POLICY "Subtasks access matches task access"
ON public.subtasks FOR ALL TO authenticated
USING (
    EXISTS (SELECT 1 FROM public.tasks t WHERE t.id = task_id AND (
        t.user_id = auth.uid() OR t.assignee_id = auth.uid()
    ))
);

-- 6. COMMENTS POLICIES
CREATE POLICY "View comments on authorized tasks"
ON public.task_comments FOR SELECT TO authenticated
USING (
    EXISTS (SELECT 1 FROM public.tasks t WHERE t.id = task_id)
);

CREATE POLICY "Create comments on authorized tasks"
ON public.task_comments FOR INSERT TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can edit or delete their own comments"
ON public.task_comments FOR ALL TO authenticated
USING (auth.uid() = user_id);

-- 7. ATTACHMENTS POLICIES
CREATE POLICY "View attachments on authorized tasks"
ON public.task_attachments FOR SELECT TO authenticated
USING (
    EXISTS (SELECT 1 FROM public.tasks t WHERE t.id = task_id)
);

CREATE POLICY "Upload attachments"
ON public.task_attachments FOR INSERT TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Delete own attachments"
ON public.task_attachments FOR DELETE TO authenticated
USING (auth.uid() = user_id);

-- 8. TAGS POLICIES
CREATE POLICY "Users manage their own tags"
ON public.tags FOR ALL TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "Task tags access"
ON public.task_tags FOR ALL TO authenticated
USING (
    EXISTS (SELECT 1 FROM public.tasks t WHERE t.id = task_id AND t.user_id = auth.uid())
);

-- 9. NOTIFICATIONS POLICIES
CREATE POLICY "Users manage their own notifications"
ON public.notifications FOR ALL TO authenticated
USING (auth.uid() = user_id);

-- 10. RECURRING & REMINDERS POLICIES
CREATE POLICY "Users manage own recurring tasks"
ON public.recurring_tasks FOR ALL TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "Users manage own task reminders"
ON public.task_reminders FOR ALL TO authenticated
USING (auth.uid() = user_id);

-- ==============================================================================
-- STORAGE BUCKETS SETUP
-- ==============================================================================
-- Run these in Supabase Storage SQL editor if storage buckets are not yet created:
-- INSERT INTO storage.buckets (id, name, public) VALUES ('avatars', 'avatars', true);
-- INSERT INTO storage.buckets (id, name, public) VALUES ('task-attachments', 'task-attachments', true);

-- Storage bucket RLS policies:
-- CREATE POLICY "Avatar public access" ON storage.objects FOR SELECT USING (bucket_id = 'avatars');
-- CREATE POLICY "Avatar upload" ON storage.objects FOR INSERT TO authenticated WITH CHECK (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);
-- CREATE POLICY "Attachment read" ON storage.objects FOR SELECT TO authenticated USING (bucket_id = 'task-attachments');
-- CREATE POLICY "Attachment upload" ON storage.objects FOR INSERT TO authenticated WITH CHECK (bucket_id = 'task-attachments');
