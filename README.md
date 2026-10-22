# Dar-e-Arqam Digital School Prototype

A functional Flutter school management prototype built for **Dar-e-Arqam Digital School**, featuring role-based workflows for **Admin / Principal**, **Teacher**, and **Parent**, powered by **Supabase (PostgreSQL)**, Auth, and Material 3 design with an Islamic school green & gold palette.

---

## 🌟 Key Features & Workflow Highlights

1. **Role-Based Portal Access**
   - Single codebase with automatic role detection (`admin`, `teacher`, `parent`).
   - Development 1-click login helper with pre-configured demo credentials.

2. **Teacher Attendance Workflow**
   - Initial state is **PENDING**; all students automatically default to **Present**.
   - Teacher quickly toggles only students who are **Absent**, **Late**, or on **Leave**.
   - Real-time attendance counters (Total, Present, Absent, Late, Leave).
   - Confirmation dialog before submission.
   - **Automated Absence Alerts**: Instant notification generated for linked parents when a student is marked Absent.
   - **Attendance Correction**: Teachers can correct attendance from Absent to Present; system immediately issues an `"Attendance for [Student] has been corrected"` alert to the parent.
   - 9:30 AM Cutoff alert warning if attendance remains pending.

3. **Academic Diary System**
   - Teacher inputs Classwork, Homework, Upcoming Tests, and Instructions.
   - Supports **Save Draft** and **Done** (marks subject as completed).
   - Class-wide overview showing all subjects (`Completed` vs `Pending`).
   - **Single Notification on Publish**: Parents receive one combined notification when the class teacher presses **PUBLISH CLASS DIARY**.
   - If a subject has no entry, it displays *"Aaj diary nahi di gayi."* without hiding the subject.

4. **Marks & Assessment Reports**
   - Teacher enters marks for Weekly Tests, Monthly Tests, Mid-Terms, and Finals.
   - Includes custom teacher feedback.
   - Automatically notifies the student's parent.
   - Parent portal displays clean report cards with percentage badges and cumulative average.

5. **Parent Portal (Read-Only & Child Switcher)**
   - Strictly read-only to prevent unauthorized modifications.
   - Multi-child dropdown switcher (e.g., *Ali Khan* and *Usman Khan*).
   - Historical attendance calendar view with `P`, `A`, `L`, and `LV` chips.
   - **Attendance Percentage Formula**: `(Present Days / Valid School Days) * 100`, with school holidays excluded.
   - Warning alert if student attendance falls below the minimum requirement (75%).

6. **Admin / Principal Dashboard & CRUD Management**
   - Live metrics: Total Students, Teachers, Classes, Absent Today, Attendance Pending, Diary Status.
   - Full CRUD forms for Classes, Subjects, Teachers, Students, and Parents.
   - School Holidays manager (holidays are automatically excluded from attendance penalty).
   - Dynamic graphical reports powered by Supabase data (Pie chart & linear progress).

7. **In-App Notification Center**
   - In-app notification inbox ensuring no alert is missed.
   - Categorized by type: `attendance`, `attendance_correction`, `diary`, `marks`, `system`.
   - Read/unread badges, timestamps, and mark-all-read capabilities.

8. **Dual-Mode Backend Engine**
   - **Out of the box**: Pre-seeded in-memory mock repository so you can test all workflows immediately with 0 configuration.
   - **Live Supabase Engine**: Full `SupabaseSchoolRepository` connecting directly to Supabase PostgreSQL using `supabase_schema.sql`.

---

## 🔑 Demo Login Credentials

| Role | Email | Password | Details |
| :--- | :--- | :--- | :--- |
| **Admin / Principal** | `admin@daralarqam.demo` | `123456` | Full school administration & reports |
| **Teacher** | `teacher@daralarqam.demo` | `123456` | Sir Ahmed (Class 8-A Teacher, Math & Sci) |
| **Parent** | `parent@daralarqam.demo` | `123456` | Tariq Khan (Parent of Ali Khan & Usman Khan) |

*(Use the **1-Click Demo Login Helper** on the login screen to sign in instantly).*

---

## 🗄️ Supabase PostgreSQL Architecture

The database structure is defined in [`supabase_schema.sql`](file:///C:/Users/imwas/.gemini/antigravity/scratch/darearqam_school/supabase_schema.sql) with 15 relational tables:

```text
users              (id, name, email, phone, role, school_id, active, created_at)
schools            (id, name, address, created_at)
classes            (id, school_id, name, section, class_teacher_id, created_at)
subjects           (id, name, class_id, teacher_id, created_at)
students           (id, name, roll_number, class_id, parent_ids, active, photo_url, created_at)
parents            (id, user_id, student_ids, created_at)
teachers           (id, user_id, assigned_class_ids, assigned_subject_ids, created_at)
attendance         (id, date, class_id, submitted, submitted_by, submitted_at)
attendance_records (id, attendance_id, student_id, status, updated_at, updated_by)
diaries            (id, date, class_id, published, published_at, created_by)
diary_entries      (id, diary_id, subject_id, teacher_id, homework, classwork, test_info, instructions, status, created_at)
marks              (id, student_id, class_id, subject_id, exam_type, obtained_marks, total_marks, feedback, created_by, created_at)
notifications      (id, user_id, student_id, title, body, type, is_read, created_at)
holidays           (id, date, title, school_id, created_at)
settings           (id, school_id, attendance_cutoff_time, diary_publish_time, minimum_attendance_percentage, created_at)
```

---

## 🚀 How to Run the App

### Prerequisites
- Flutter SDK (v3.22.0 or newer)
- Dart SDK (v3.4.0 or newer)

### Run the App Out-of-the-Box (Demo Mode)
```bash
# Navigate to the project root
cd darearqam_school

# Get dependencies
flutter pub get

# Run on Chrome / Web
flutter run -d chrome

# Run on Android Emulator / Device
flutter run -d android

# Run on Windows Desktop
flutter run -d windows
```

---

## ⚡ How to Connect Live Supabase Backend (3 Easy Steps)

### Step 1: Create a Project in Supabase
1. Go to [supabase.com](https://supabase.com) and create a free project.
2. Go to **Project Settings** -> **API** and copy:
   - **Project URL**
   - **anon / public key**

### Step 2: Run the SQL Schema
1. In Supabase Dashboard, open the **SQL Editor** on the left menu.
2. Click **New Query**.
3. Copy the entire contents of [`supabase_schema.sql`](file:///C:/Users/imwas/.gemini/antigravity/scratch/darearqam_school/supabase_schema.sql) and paste into the editor.
4. Click **Run**. All 15 tables, indexes, Row-Level Security (RLS) policies, and demo seed data (Class 8-A, students, teachers, subjects) will be created immediately!

### Step 3: Paste Keys into `lib/core/supabase/supabase_config.dart`
Open [`lib/core/supabase/supabase_config.dart`](file:///C:/Users/imwas/.gemini/antigravity/scratch/darearqam_school/lib/core/supabase/supabase_config.dart) and enter your credentials:

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'https://YOUR_PROJECT_ID.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOi...YOUR_ANON_KEY...';
}
```

Now restart the app (`flutter run`) — the app will automatically detect Supabase and connect in live database mode!

---

## 🔒 Security & Row-Level Security (RLS)

All tables in [`supabase_schema.sql`](file:///C:/Users/imwas/.gemini/antigravity/scratch/darearqam_school/supabase_schema.sql) have Row Level Security enabled with policies:
- Authenticated and public anonymous prototype access enabled for development testing.
- Role-based constraints for parent read-only, teacher write permissions, and admin management.

---

## 📂 Project Structure

```text
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart         # Green & gold branding palette
│   │   ├── app_theme.dart          # Material 3 typography & themes
│   │   └── school_constants.dart   # Cutoffs, roles, and status constants
│   └── supabase/
│       └── supabase_config.dart    # Supabase URL & Anon Key config
├── models/
│   ├── attendance_model.dart
│   ├── attendance_record_model.dart
│   ├── class_model.dart
│   ├── diary_entry_model.dart
│   ├── diary_model.dart
│   ├── holiday_model.dart
│   ├── mark_model.dart
│   ├── notification_model.dart
│   ├── parent_model.dart
│   ├── school_model.dart
│   ├── school_settings_model.dart
│   ├── student_model.dart
│   ├── subject_model.dart
│   ├── teacher_model.dart
│   └── user_model.dart
├── services/
│   ├── supabase_school_repository.dart   # Supabase PostgreSQL implementation
│   ├── mock_school_repository.dart       # In-memory reactive demo repository
│   ├── repository_manager.dart           # Seamless Supabase/Mock engine switcher
│   ├── school_repository.dart            # Abstract ISchoolRepository
│   └── seed_data.dart                    # Demo dataset generator
├── providers/
│   ├── admin_provider.dart               # Admin metrics & CRUD state
│   ├── attendance_provider.dart          # Attendance & alerts state
│   ├── auth_provider.dart                # User auth & role detection
│   ├── diary_provider.dart               # Diary editing & publishing state
│   ├── marks_provider.dart               # Grading & feedback state
│   ├── notification_provider.dart        # In-app notifications inbox
│   └── parent_provider.dart              # Multi-child switcher & read-only state
├── features/
│   ├── admin/
│   │   ├── admin_dashboard_screen.dart
│   │   ├── admin_holidays_screen.dart
│   │   ├── admin_management_screen.dart
│   │   ├── admin_reports_screen.dart
│   │   └── admin_settings_screen.dart
│   ├── auth/
│   │   └── login_screen.dart
│   ├── notifications/
│   │   └── notification_center_screen.dart
│   ├── parent/
│   │   ├── parent_attendance_screen.dart
│   │   ├── parent_dashboard_screen.dart
│   │   ├── parent_diary_screen.dart
│   │   ├── parent_profile_screen.dart
│   │   └── parent_results_screen.dart
│   └── teacher/
│       ├── teacher_attendance_screen.dart
│       ├── teacher_dashboard_screen.dart
│       ├── teacher_diary_screen.dart
│       ├── teacher_marks_screen.dart
│       └── teacher_profile_screen.dart
├── widgets/
│   ├── attendance_status_chip.dart
│   ├── connectivity_banner.dart
│   ├── firebase_status_dialog.dart       # Backend status & live Supabase sync dialog
│   ├── responsive_shell.dart
│   └── summary_stat_card.dart
├── routes/
│   └── app_router.dart
└── main.dart
```

---

## 🧪 Automated Test Suite

Run all verification tests with:
```bash
flutter test
```
Includes tests for:
- Role-based login and logout for Admin, Teacher, and Parent.
- Flow 1: Attendance default Present state, marking Absent, and parent alert creation.
- Flow 2: Attendance correction from Absent to Present with correction notifications.
- Flow 3: Diary drafts, subject completion, and publishing to class parents.
- Flow 4: Marks entry, percentage calculation, and parent result notification.
- Flow 5: Parent multi-child switcher and attendance percentage excluding holidays.
- Flow 6: Admin metrics and low attendance (< 75%) detection.
- App startup and widget layout rendering.

---

## 🧪 Automated Test Suite

Run all verification tests with:
```bash
flutter test
```
Includes tests for:
- Role-based login and logout for Admin, Teacher, and Parent.
- Flow 1: Attendance default Present state, marking Absent, and parent alert creation.
- Flow 2: Attendance correction from Absent to Present with correction notifications.
- Flow 3: Diary drafts, subject completion, and publishing to class parents.
- Flow 4: Marks entry, percentage calculation, and parent result notification.
- Flow 5: Parent multi-child switcher and attendance percentage excluding holidays.
- Flow 6: Admin metrics and low attendance (< 75%) detection.
- App startup and widget layout rendering.
