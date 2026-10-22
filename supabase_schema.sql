-- ============================================================
-- Dar-e-Arqam Digital School: Supabase Database Schema & Seed
-- ============================================================

-- 1. Enable UUID Extension (Optional if needed)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. Create Tables
CREATE TABLE IF NOT EXISTS public.schools (
    school_id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    address TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS public.users (
    user_id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    phone TEXT,
    role TEXT NOT NULL CHECK (role IN ('admin', 'teacher', 'parent')),
    school_id TEXT NOT NULL,
    active BOOLEAN DEFAULT true
);

CREATE TABLE IF NOT EXISTS public.classes (
    class_id TEXT PRIMARY KEY,
    school_id TEXT NOT NULL,
    name TEXT NOT NULL,
    section TEXT NOT NULL,
    class_teacher_id TEXT
);

CREATE TABLE IF NOT EXISTS public.subjects (
    subject_id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    class_id TEXT NOT NULL,
    teacher_id TEXT
);

CREATE TABLE IF NOT EXISTS public.teachers (
    teacher_id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    assigned_class_ids TEXT[] DEFAULT '{}',
    assigned_subject_ids TEXT[] DEFAULT '{}'
);

CREATE TABLE IF NOT EXISTS public.students (
    student_id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    roll_number TEXT NOT NULL,
    class_id TEXT NOT NULL,
    parent_ids TEXT[] DEFAULT '{}',
    active BOOLEAN DEFAULT true,
    photo_url TEXT,
    link_code TEXT
);

CREATE TABLE IF NOT EXISTS public.parents (
    parent_id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    student_ids TEXT[] DEFAULT '{}'
);

CREATE TABLE IF NOT EXISTS public.attendance (
    attendance_id TEXT PRIMARY KEY,
    date TEXT NOT NULL,
    class_id TEXT NOT NULL,
    submitted BOOLEAN DEFAULT false,
    submitted_by TEXT,
    submitted_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.attendance_records (
    record_id TEXT PRIMARY KEY,
    attendance_id TEXT NOT NULL,
    student_id TEXT NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('present', 'absent', 'late', 'leave')),
    updated_at TIMESTAMPTZ DEFAULT now(),
    updated_by TEXT
);

CREATE TABLE IF NOT EXISTS public.diaries (
    diary_id TEXT PRIMARY KEY,
    date TEXT NOT NULL,
    class_id TEXT NOT NULL,
    published BOOLEAN DEFAULT false,
    published_at TIMESTAMPTZ,
    created_by TEXT
);

CREATE TABLE IF NOT EXISTS public.diary_entries (
    entry_id TEXT PRIMARY KEY,
    diary_id TEXT NOT NULL,
    subject_id TEXT NOT NULL,
    teacher_id TEXT,
    homework TEXT DEFAULT '',
    classwork TEXT DEFAULT '',
    test_info TEXT DEFAULT '',
    instructions TEXT DEFAULT '',
    status TEXT DEFAULT 'draft' CHECK (status IN ('draft', 'completed')),
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.marks (
    mark_id TEXT PRIMARY KEY,
    student_id TEXT NOT NULL,
    class_id TEXT NOT NULL,
    subject_id TEXT NOT NULL,
    exam_type TEXT NOT NULL,
    obtained_marks NUMERIC NOT NULL,
    total_marks NUMERIC NOT NULL,
    feedback TEXT DEFAULT '',
    created_by TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.notifications (
    notification_id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    student_id TEXT,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    type TEXT NOT NULL,
    read BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.holidays (
    holiday_id TEXT PRIMARY KEY,
    date TEXT NOT NULL,
    title TEXT NOT NULL,
    school_id TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS public.settings (
    school_id TEXT PRIMARY KEY,
    attendance_cutoff_time TEXT DEFAULT '09:30',
    diary_publish_time TEXT DEFAULT '14:00',
    minimum_attendance_percentage NUMERIC DEFAULT 75.0
);

-- 3. Row Level Security (RLS)
ALTER TABLE public.schools ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.classes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subjects ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.teachers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.students ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.parents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.attendance ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.attendance_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.diaries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.diary_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.marks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.holidays ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.settings ENABLE ROW LEVEL SECURITY;

-- Allow public access for anon client in demo/prototype mode (can be refined with auth.uid() in production)
DO $$
BEGIN
    EXECUTE 'CREATE POLICY "Allow public select on all tables" ON public.schools FOR SELECT USING (true)';
    EXECUTE 'CREATE POLICY "Allow public select on users" ON public.users FOR SELECT USING (true)';
    EXECUTE 'CREATE POLICY "Allow public all on users" ON public.users FOR ALL USING (true)';
    EXECUTE 'CREATE POLICY "Allow public all on classes" ON public.classes FOR ALL USING (true)';
    EXECUTE 'CREATE POLICY "Allow public all on subjects" ON public.subjects FOR ALL USING (true)';
    EXECUTE 'CREATE POLICY "Allow public all on teachers" ON public.teachers FOR ALL USING (true)';
    EXECUTE 'CREATE POLICY "Allow public all on students" ON public.students FOR ALL USING (true)';
    EXECUTE 'CREATE POLICY "Allow public all on parents" ON public.parents FOR ALL USING (true)';
    EXECUTE 'CREATE POLICY "Allow public all on attendance" ON public.attendance FOR ALL USING (true)';
    EXECUTE 'CREATE POLICY "Allow public all on attendance_records" ON public.attendance_records FOR ALL USING (true)';
    EXECUTE 'CREATE POLICY "Allow public all on diaries" ON public.diaries FOR ALL USING (true)';
    EXECUTE 'CREATE POLICY "Allow public all on diary_entries" ON public.diary_entries FOR ALL USING (true)';
    EXECUTE 'CREATE POLICY "Allow public all on marks" ON public.marks FOR ALL USING (true)';
    EXECUTE 'CREATE POLICY "Allow public all on notifications" ON public.notifications FOR ALL USING (true)';
    EXECUTE 'CREATE POLICY "Allow public all on holidays" ON public.holidays FOR ALL USING (true)';
    EXECUTE 'CREATE POLICY "Allow public all on settings" ON public.settings FOR ALL USING (true)';
EXCEPTION WHEN duplicate_object THEN
    NULL;
END $$;

-- 4. Initial Seed Data
INSERT INTO public.schools (school_id, name, address)
VALUES ('school_darearqam_01', 'Dar-e-Arqam Digital School', 'Main Campus, Gulshan Branch')
ON CONFLICT (school_id) DO NOTHING;

INSERT INTO public.users (user_id, name, email, phone, role, school_id) VALUES
('user_admin_01', 'Principal Tariq Mehmood', 'admin@daralarqam.demo', '+92 300 1112233', 'admin', 'school_darearqam_01'),
('user_teacher_ahmed', 'Sir Ahmed', 'teacher@daralarqam.demo', '+92 300 2223344', 'teacher', 'school_darearqam_01'),
('user_teacher_sana', 'Miss Sana', 'sana.teacher@daralarqam.demo', '+92 300 3334455', 'teacher', 'school_darearqam_01'),
('user_teacher_ali', 'Sir Ali', 'ali.teacher@daralarqam.demo', '+92 300 4445566', 'teacher', 'school_darearqam_01'),
('user_parent_tariq', 'Tariq Khan (Parent)', 'parent@daralarqam.demo', '+92 300 5556677', 'parent', 'school_darearqam_01'),
('user_parent_ahmed', 'Mr. Zahid Ahmed', 'zahid.parent@daralarqam.demo', '+92 300 6667788', 'parent', 'school_darearqam_01')
ON CONFLICT (user_id) DO NOTHING;

INSERT INTO public.classes (class_id, school_id, name, section, class_teacher_id) VALUES
('class_8a', 'school_darearqam_01', 'Class 8', 'A', 'user_teacher_ahmed'),
('class_7a', 'school_darearqam_01', 'Class 7', 'A', 'user_teacher_sana'),
('class_9b', 'school_darearqam_01', 'Class 9', 'B', 'user_teacher_ali')
ON CONFLICT (class_id) DO NOTHING;

INSERT INTO public.subjects (subject_id, name, class_id, teacher_id) VALUES
('subj_eng_8a', 'English', 'class_8a', 'user_teacher_sana'),
('subj_urdu_8a', 'Urdu', 'class_8a', 'user_teacher_sana'),
('subj_math_8a', 'Mathematics', 'class_8a', 'user_teacher_ahmed'),
('subj_sci_8a', 'Science', 'class_8a', 'user_teacher_ahmed'),
('subj_isl_8a', 'Islamiat', 'class_8a', 'user_teacher_ali'),
('subj_comp_8a', 'Computer', 'class_8a', 'user_teacher_ali')
ON CONFLICT (subject_id) DO NOTHING;

INSERT INTO public.teachers (teacher_id, user_id, assigned_class_ids, assigned_subject_ids) VALUES
('teacher_prof_ahmed', 'user_teacher_ahmed', ARRAY['class_8a'], ARRAY['subj_math_8a', 'subj_sci_8a']),
('teacher_prof_sana', 'user_teacher_sana', ARRAY['class_8a', 'class_7a'], ARRAY['subj_eng_8a', 'subj_urdu_8a']),
('teacher_prof_ali', 'user_teacher_ali', ARRAY['class_8a', 'class_9b'], ARRAY['subj_isl_8a', 'subj_comp_8a'])
ON CONFLICT (teacher_id) DO NOTHING;

INSERT INTO public.students (student_id, name, roll_number, class_id, parent_ids, link_code) VALUES
('student_01', 'Ali Khan', '01', 'class_8a', ARRAY['user_parent_tariq'], 'ARQ-8A-01'),
('student_02', 'Sana Ahmed', '02', 'class_8a', ARRAY['user_parent_ahmed'], 'ARQ-8A-02'),
('student_03', 'Usman Khan', '03', 'class_8a', ARRAY['user_parent_tariq'], 'ARQ-8A-03'),
('student_04', 'Ayesha Noor', '04', 'class_8a', ARRAY['user_parent_ahmed'], 'ARQ-8A-04'),
('student_05', 'Hamza Ali', '05', 'class_8a', '{}', 'ARQ-8A-05'),
('student_06', 'Fatima Khan', '06', 'class_8a', '{}', 'ARQ-8A-06'),
('student_07', 'Zain Ahmed', '07', 'class_8a', ARRAY['user_parent_ahmed'], 'ARQ-8A-07'),
('student_08', 'Maryam Ali', '08', 'class_8a', '{}', 'ARQ-8A-08'),
('student_09', 'Abdullah Khan', '09', 'class_8a', '{}', 'ARQ-8A-09'),
('student_10', 'Hira Noor', '10', 'class_8a', '{}', 'ARQ-8A-10')
ON CONFLICT (student_id) DO NOTHING;

INSERT INTO public.parents (parent_id, user_id, student_ids) VALUES
('parent_prof_tariq', 'user_parent_tariq', ARRAY['student_01', 'student_03']),
('parent_prof_ahmed', 'user_parent_ahmed', ARRAY['student_02', 'student_04', 'student_07'])
ON CONFLICT (parent_id) DO NOTHING;

INSERT INTO public.settings (school_id, attendance_cutoff_time, diary_publish_time, minimum_attendance_percentage)
VALUES ('school_darearqam_01', '09:30', '14:00', 75.0)
ON CONFLICT (school_id) DO NOTHING;

INSERT INTO public.holidays (holiday_id, date, title, school_id) VALUES
('hol_01', '2026-10-19', 'Sunday Holiday', 'school_darearqam_01'),
('hol_02', '2026-10-12', 'Sunday Holiday', 'school_darearqam_01'),
('hol_03', '2026-11-09', 'Iqbal Day Commemoration', 'school_darearqam_01')
ON CONFLICT (holiday_id) DO NOTHING;

INSERT INTO public.marks (mark_id, student_id, class_id, subject_id, exam_type, obtained_marks, total_marks, feedback, created_by) VALUES
('mark_01', 'student_01', 'class_8a', 'subj_math_8a', 'Weekly Test', 18.0, 20.0, 'Good progress. Needs more practice with fractions and algebraic identities.', 'user_teacher_ahmed'),
('mark_02', 'student_01', 'class_8a', 'subj_sci_8a', 'Weekly Test', 23.5, 25.0, 'Excellent conceptual grasp of Photosynthesis and respiration.', 'user_teacher_ahmed'),
('mark_03', 'student_01', 'class_8a', 'subj_eng_8a', 'Monthly Test', 44.0, 50.0, 'Good essay structure, but needs improvement in punctuation.', 'user_teacher_sana'),
('mark_04', 'student_03', 'class_8a', 'subj_math_8a', 'Weekly Test', 19.0, 20.0, 'Outstanding mathematical problem-solving skills!', 'user_teacher_ahmed'),
('mark_05', 'student_02', 'class_8a', 'subj_math_8a', 'Weekly Test', 17.0, 20.0, 'Well attempted. Revise linear equations.', 'user_teacher_ahmed')
ON CONFLICT (mark_id) DO NOTHING;

INSERT INTO public.notifications (notification_id, user_id, student_id, title, body, type, read) VALUES
('notif_01', 'user_parent_tariq', 'student_01', 'Attendance Alert', 'Ali Khan has been marked Present for today.', 'attendance', false),
('notif_02', 'user_parent_tariq', 'student_01', 'Diary Updated', 'New homework posted for Class 8-A: Mathematics and English.', 'diary', false),
('notif_03', 'user_parent_tariq', 'student_01', 'New Marks Uploaded', 'Weekly test marks for Mathematics (18/20) have been published.', 'marks', true)
ON CONFLICT (notification_id) DO NOTHING;

