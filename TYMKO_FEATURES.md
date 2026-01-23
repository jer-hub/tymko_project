# Tymko - Student Task & Habit Manager

A comprehensive Flutter application designed to help students develop better study habits, strengthen self-discipline, and improve accountability through behavioral tracking and parental supervision.

## 🎯 Project Purpose

**Tymko** addresses a growing problem among students: poor time management, weak self-regulation, and lack of consistent academic habits. By providing a structured system for planning, tracking, and supervised accountability, the application encourages students to take responsibility for their learning while strengthening parent involvement in academic development.

## 🌟 Social Impact

The social impact of this study lies in promoting healthier academic behaviors, reducing procrastination, and supporting students who struggle with self-discipline, particularly in home-based and digital learning environments.

### How Behavioral Tracking Helps Students

Tracking student behavior allows the app to identify patterns that are directly linked to academic success or difficulty. By monitoring behaviors such as:

- **Task completion time** - Understanding how long tasks actually take
- **Frequency of procrastination** - Identifying unhealthy patterns early
- **Missed or delayed deadlines** - Detecting time management issues
- **Consistency of study schedules** - Building regular habits
- **Peak productivity hours** - Optimizing study time

The app provides **preventive intervention** by:
- Suggesting optimal schedules based on peak productivity
- Notifying students when unhealthy patterns repeat
- Alerting parents for guidance when intervention is needed

## 👥 Role-Based System

### 1. Student (Common User)
**What they can do:**
- ✅ Create and manage tasks
- ⏱️ Track study time with Pomodoro timer
- 📊 View personal progress and statistics
- 💡 Receive adaptive suggestions
- ✍️ Complete daily reflections
- 🎯 Break tasks into subtasks
- 🔄 Set recurring tasks

**Impact:** Builds self-awareness and self-regulation

**Where in the app:**
- Main dashboard with calendar view
- Task management screen
- Pomodoro timer for focused sessions
- Personal statistics view
- Daily reflection prompts

### 2. Parent (Supervising User)
**What they can do:**
- 👀 View student progress dashboard
- 📈 See consistency reports (7-day view)
- ⚠️ Receive alerts if patterns decline
- 📋 Monitor task completion rates
- 🕐 Track study time trends

**Impact:** Adds external accountability, which research shows improves habit adherence

**Where in the app:**
- Parent dashboard showing student metrics
- Weekly consistency chart
- Behavioral pattern analysis
- Recent activity feed
- Intervention alerts when needed

### 3. Admin (System-Level)
**What they can do:**
- 📊 Manage user data (for research integrity)
- 🔍 Review anonymous usage patterns
- 🛠️ Ensure system reliability
- 📈 Generate overall analytics

**Impact:** Ensures the system produces valid data for analysis and continuous improvement

**Where in the app:**
- Admin dashboard with system overview
- Anonymous analytics and usage patterns
- Feature effectiveness tracking

## 📚 Effective Study Patterns Implementation

### a. Consistent Study Schedules
**Feature:** Recurring task reminders and consistency tracking
- Set daily, weekly, or monthly recurring tasks
- Visual consistency score in statistics
- 7-day consistency chart for parents

### b. Pomodoro Method (Short Focused Sessions)
**Feature:** Built-in 25-minute focus timer
- Standard Pomodoro: 25 min work, 5 min break
- Long breaks (15 min) after 4 sessions
- Session tracking for analytics
- Completion counter

### c. Task Chunking
**Feature:** Subtasks and milestones
- Break large tasks into smaller subtasks
- Track completion of each subtask
- Visual progress indication
- Priority levels (1-5)

### d. Reflection After Studying
**Feature:** "What did you finish today?" prompt
- Daily reflection dialog
- Track accomplishments
- Note challenges faced
- Plan improvements for tomorrow
- Rate productivity (1-5 scale)

### e. Accountability Improves Consistency
**Feature:** Parent progress access
- Real-time parent dashboard
- Consistency reports
- Behavioral alerts
- Progress visibility

## 🔬 Academic Progress Correlation

### Behavioral Metrics Tracked

**For Each Student:**
- Tasks completed vs. created
- Tasks missed or past deadline
- Total study time per day
- Number of Pomodoro sessions
- Procrastination count
- Consistency score (0-100)
- Peak productivity hours

### Pattern Analysis

The app correlates academic progress by analyzing:

1. **Study duration vs. task completion rates**
   - Are longer study sessions more productive?
   - What's the optimal session length?

2. **Consistency vs. punctuality improvements**
   - Does regular scheduling reduce late submissions?
   - How does weekly consistency affect deadlines?

3. **Cramming reduction vs. workload stability**
   - Are tasks distributed evenly?
   - Is procrastination decreasing over time?

4. **Behavior changes before and after recommendations**
   - Do adaptive suggestions improve outcomes?
   - Which interventions work best?

### Adaptive Suggestions System

Based on analyzed patterns, the app provides personalized suggestions:

**Examples:**
- 📅 "Try setting a consistent study schedule each day to build better habits" (Low consistency)
- ⏰ "Consider using the Pomodoro timer to break tasks into focused 25-minute sessions" (High procrastination)
- 🎯 "Break larger tasks into smaller subtasks to make them more manageable" (Low productivity)
- ✨ "Your most productive hours are around 14:00. Schedule important tasks then!" (Peak hour detection)

## 🎨 Key Features

### For Students

#### 📅 **Schedule View**
- Weekly calendar with day selection
- Timeline showing tasks for selected day
- Empty state encouragement
- Quick access to Pomodoro timer
- Daily reflection button

#### ✅ **Task Management**
- Create tasks with title, description, date/time
- Categorize tasks (Study, Assignment, Project, etc.)
- Set priority levels
- Add subtasks for task chunking
- Mark recurring tasks
- Estimate duration
- Track actual completion time

#### ⏱️ **Pomodoro Timer**
- 25-minute focus sessions
- 5-minute short breaks
- 15-minute long breaks (every 4 sessions)
- Session completion tracking
- Visual progress indicator
- Educational information about the technique

#### ✍️ **Daily Reflection**
- "What did you finish today?" prompt
- Challenge tracking
- Improvement planning
- Productivity self-rating (1-5)
- Builds self-awareness

#### 📊 **Personal Statistics**
- Total, completed, and pending tasks
- Completion percentage
- Tasks by category breakdown
- Progress visualization

### For Parents

#### 📈 **Progress Dashboard**
- Student overview cards
- Task completion metrics
- Study time tracking
- Pomodoro session count

#### ⚠️ **Intervention Alerts**
- Automatic alerts when patterns decline
- Visual warning indicators
- Behavioral pattern summary

#### 📊 **Behavioral Analysis**
- Consistency rating (Excellent/Good/Needs Improvement)
- Procrastination level (Low/Moderate/High)
- Productivity assessment
- Average tasks per day

#### 📅 **Weekly Consistency Chart**
- 7-day visual overview
- Tasks completed per day
- Pattern recognition

#### 📋 **Recent Activity**
- Latest task completions
- Timestamp information
- Completion status

### For Admins

#### 📊 **System Analytics**
- Total tasks and completions
- Study sessions count
- Reflections submitted
- Anonymous usage patterns

#### 🔬 **Research Data**
- Category distribution
- Feature effectiveness
- System reliability metrics

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.9.2 or higher)
- Dart SDK
- Android Studio / VS Code
- An emulator or physical device

### Installation

1. **Clone the repository**
   ```bash
   cd tymko_project
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Demo Mode

The app launches in demo mode with three role options:

1. **Student** - Full task management and study features
2. **Parent** - Monitor student progress (linked to demo student)
3. **Admin** - View system analytics

## 📱 App Structure

```
lib/
├── main.dart                           # App entry point
├── models/
│   ├── task.dart                       # Task and Subtask models
│   ├── user_role.dart                  # User and role definitions
│   ├── behavior_metrics.dart           # Behavioral tracking data
│   ├── study_session.dart              # Pomodoro session data
│   └── reflection.dart                 # Daily reflection model
├── providers/
│   ├── task_provider.dart              # Task state management
│   ├── user_provider.dart              # User/role management
│   └── behavior_tracking_provider.dart # Analytics and patterns
├── screens/
│   ├── role_selection_screen.dart      # Role selection (demo mode)
│   ├── home_screen.dart                # Student dashboard
│   ├── tasks_screen.dart               # All tasks view
│   ├── stats_screen.dart               # Student statistics
│   ├── pomodoro_timer_screen.dart      # Focus timer
│   ├── parent_dashboard_screen.dart    # Parent supervision view
│   └── admin_dashboard_screen.dart     # Admin analytics
└── widgets/
    ├── calendar_week_view.dart         # Weekly calendar
    ├── task_list_item.dart             # Task card component
    ├── add_task_dialog.dart            # Create/edit task
    └── reflection_dialog.dart          # Daily reflection
```

## 🎯 How Features Support Academic Success

| Feature | Academic Benefit | Research Support |
|---------|-----------------|------------------|
| **Pomodoro Timer** | Improves focus, reduces mental fatigue | Proven technique for sustained concentration |
| **Task Chunking** | Makes large projects manageable | Reduces overwhelm, increases completion rates |
| **Daily Reflection** | Builds self-awareness | Metacognition improves learning outcomes |
| **Consistency Tracking** | Forms habits through repetition | Habit formation requires regular practice |
| **Parental Monitoring** | External accountability | Supervision correlates with better outcomes |
| **Behavioral Alerts** | Early intervention | Prevents academic decline before failure |
| **Adaptive Suggestions** | Personalized support | Tailored guidance more effective |
| **Pattern Analysis** | Data-driven decisions | Objective metrics reveal true habits |

## 🔄 Future Enhancements

- [ ] Data persistence (local database)
- [ ] Cloud sync for multi-device access
- [ ] Push notifications for reminders
- [ ] Advanced analytics with charts
- [ ] Export reports for parents/teachers
- [ ] Integration with school calendars
- [ ] Gamification elements
- [ ] Study group collaboration
- [ ] Resource library

## 📖 Research Foundation

This application is built on educational research showing that:

1. **Self-regulation skills** are teachable and improvable
2. **External accountability** (parent monitoring) increases adherence
3. **Reflection practices** enhance metacognition and learning
4. **Time management tools** reduce procrastination
5. **Consistent habits** lead to better academic outcomes
6. **Early intervention** prevents academic decline

## 🤝 Contributing

This is a research project. For questions or collaboration:
- Review the code structure
- Understand the behavioral tracking system
- Consider ethical implications of student monitoring

## 📄 License

This project is created for educational and research purposes.

## 🙏 Acknowledgments

- Research on Pomodoro Technique effectiveness
- Studies on parental involvement in education
- Behavioral psychology principles
- Flutter and Dart communities

---

**Tymko** - Empowering students to build better habits, one task at a time. 🎓✨
