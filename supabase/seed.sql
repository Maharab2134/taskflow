-- ==============================================================================
-- TASKFLOW - SEED / DEMO DATA (FOR DEV & INITIAL SETUP)
-- ==============================================================================

-- Demo Projects (Replace user_id with your authenticated user's ID or dynamic seed)
-- Example script:
DO $$
DECLARE
    v_user_id UUID;
    v_proj_portfolio UUID;
    v_proj_ecommerce UUID;
    v_proj_banking UUID;
    v_proj_uni UUID;
    v_proj_personal UUID;
    v_task1 UUID;
    v_task2 UUID;
    v_task3 UUID;
    v_task4 UUID;
    v_task5 UUID;
BEGIN
    SELECT id INTO v_user_id FROM auth.users LIMIT 1;
    IF v_user_id IS NULL THEN
        RAISE NOTICE 'No user in auth.users yet. Seed data can be applied after creating an account.';
        RETURN;
    END IF;

    -- Insert Projects
    INSERT INTO public.projects (id, user_id, name, description, color, icon, status, start_date, deadline, progress)
    VALUES 
    (gen_random_uuid(), v_user_id, 'Portfolio Website', 'Personal developer showcase and portfolio with modern design', '#6366F1', 'globe', 'active', NOW(), NOW() + INTERVAL '14 days', 75)
    RETURNING id INTO v_proj_portfolio;

    INSERT INTO public.projects (id, user_id, name, description, color, icon, status, start_date, deadline, progress)
    VALUES 
    (gen_random_uuid(), v_user_id, 'E-commerce App', 'Full-stack cross-platform shop application with checkout', '#EC4899', 'shopping_bag', 'active', NOW() - INTERVAL '5 days', NOW() + INTERVAL '30 days', 45)
    RETURNING id INTO v_proj_ecommerce;

    INSERT INTO public.projects (id, user_id, name, description, color, icon, status, start_date, deadline, progress)
    VALUES 
    (gen_random_uuid(), v_user_id, 'Mobile Banking App', 'Fintech user interface with encrypted transfers and analytics', '#10B981', 'credit_card', 'active', NOW() - INTERVAL '10 days', NOW() + INTERVAL '45 days', 20)
    RETURNING id INTO v_proj_banking;

    INSERT INTO public.projects (id, user_id, name, description, color, icon, status, start_date, deadline, progress)
    VALUES 
    (gen_random_uuid(), v_user_id, 'University Research', 'Distributed algorithms research paper and benchmark code', '#F59E0B', 'book_open', 'active', NOW(), NOW() + INTERVAL '20 days', 60)
    RETURNING id INTO v_proj_uni;

    INSERT INTO public.projects (id, user_id, name, description, color, icon, status, start_date, deadline, progress)
    VALUES 
    (gen_random_uuid(), v_user_id, 'Personal Development', 'Habit tracking, morning routine, reading list and workouts', '#8B5CF6', 'smile', 'active', NOW(), NOW() + INTERVAL '90 days', 30)
    RETURNING id INTO v_proj_personal;

    -- Insert Tasks
    INSERT INTO public.tasks (id, user_id, project_id, title, description, status, priority, due_date, due_time, estimated_duration_minutes, category)
    VALUES
    (gen_random_uuid(), v_user_id, v_proj_portfolio, 'Design landing page hero section in Figma', 'Craft sleek dark mode hero with glassmorphism badges and dynamic CTA', 'completed', 'high', CURRENT_DATE, '15:00:00', 90, 'Design')
    RETURNING id INTO v_task1;

    INSERT INTO public.tasks (id, user_id, project_id, title, description, status, priority, due_date, due_time, estimated_duration_minutes, category)
    VALUES
    (gen_random_uuid(), v_user_id, v_proj_portfolio, 'Implement responsive navbar & routing', 'Set up GoRouter with smooth transition routes and mobile hamburger menu', 'in_progress', 'high', CURRENT_DATE, '18:00:00', 60, 'Engineering')
    RETURNING id INTO v_task2;

    INSERT INTO public.tasks (id, user_id, project_id, title, description, status, priority, due_date, due_time, estimated_duration_minutes, category)
    VALUES
    (gen_random_uuid(), v_user_id, v_proj_ecommerce, 'Integrate Stripe payment checkout sheet', 'Configure webhooks, verify Apple Pay & Google Pay tokens', 'todo', 'urgent', CURRENT_DATE + 1, '14:30:00', 120, 'Payment')
    RETURNING id INTO v_task3;

    INSERT INTO public.tasks (id, user_id, project_id, title, description, status, priority, due_date, due_time, estimated_duration_minutes, category)
    VALUES
    (gen_random_uuid(), v_user_id, v_proj_banking, 'Audit security encryption and biometric login', 'Validate FaceID / TouchID biometric prompt fallback and token refresh', 'review', 'urgent', CURRENT_DATE + 3, '11:00:00', 180, 'Security')
    RETURNING id INTO v_task4;

    INSERT INTO public.tasks (id, user_id, project_id, title, description, status, priority, due_date, due_time, estimated_duration_minutes, category)
    VALUES
    (gen_random_uuid(), v_user_id, v_proj_personal, 'Read 2 chapters of "Designing Data-Intensive Applications"', 'Take markdown notes on partition rebalancing and consensus protocols', 'todo', 'low', CURRENT_DATE, '21:00:00', 45, 'Learning')
    RETURNING id INTO v_task5;

    -- Insert Subtasks for Task 1
    INSERT INTO public.subtasks (task_id, title, is_completed, position) VALUES
    (v_task1, 'Choose color scheme and typography hierarchy', true, 1),
    (v_task1, 'Sketch wireframe on paper', true, 2),
    (v_task1, 'Export SVG assets and 3D icons', true, 3);

    -- Insert Subtasks for Task 2
    INSERT INTO public.subtasks (task_id, title, is_completed, position) VALUES
    (v_task2, 'Create navigation shell and tabs', true, 1),
    (v_task2, 'Test responsive breakpoints (mobile, tablet, desktop)', false, 2),
    (v_task2, 'Add micro-animations for active tab indicator', false, 3);

    -- Insert Comments
    INSERT INTO public.task_comments (task_id, user_id, content) VALUES
    (v_task2, v_user_id, 'Working on the responsive navigation shell right now. Looking super slick!'),
    (v_task3, v_user_id, 'Stripe test API keys configured in Supabase vault.');

    -- Insert Notifications
    INSERT INTO public.notifications (user_id, title, message, type, is_read) VALUES
    (v_user_id, 'Welcome to TaskFlow!', 'Explore your projects, create tasks, and boost your daily productivity.', 'system', false),
    (v_user_id, 'Deadline Approaching', 'Task "Design landing page hero section" is due today.', 'deadline_approaching', false);

END $$;
