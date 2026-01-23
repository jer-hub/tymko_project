# 📊 Behavioral Tracking & Early Intervention System

## Overview
Tymko includes a comprehensive behavioral tracking system that monitors student study patterns and provides early intervention when academic difficulties are detected.

---

## 🎯 Monitored Behaviors

### 1. Task Completion Time
**What's tracked:**
- Time between task creation and completion
- On-time vs. late completion rates
- Procrastination patterns

**Detection:**
- **Early Completer**: <20% late completion rate ✅
- **Mixed Pattern**: 20-50% late completion rate ⚠️
- **Chronic Procrastinator**: >50% late completion rate 🚨

**Intervention:**
- Suggests setting earlier personal deadlines
- Recommends Pomodoro technique for focus
- Alerts parents when pattern becomes concerning

---

### 2. Procrastination Frequency
**What's tracked:**
- Number of tasks completed after deadline
- Trending increase in last-minute work
- Consistency of procrastination behavior

**Early Warning Triggers:**
- ≥5 procrastinated tasks in last 5 days

**Automatic Actions:**
- Student notification with time management tips
- Parent alert with actionable guidance
- Suggested study schedule based on peak productivity hours

---

### 3. Missed/Delayed Deadlines
**What's tracked:**
- Tasks not completed by due date
- Frequency of missed deadlines
- Recent increase in missed tasks

**Early Warning Triggers:**
- ≥3 missed deadlines in past 3 days

**Severity Level:** HIGH 🚨

**Parent Guidance:**
- "Have a conversation about time management"
- "Help establish a daily study routine"
- "Work together to create a weekly study schedule"

---

### 4. Study Schedule Consistency
**What's tracked:**
- Days with completed tasks vs. inactive days
- Consistency score (0-100%)
- Week-over-week consistency trends

**Scoring:**
- **Excellent**: ≥70% consistency
- **Good**: 50-69% consistency
- **Needs Improvement**: <50% consistency

**Early Warning Triggers:**
- ≥3 days without any task completion in last 7 days
- Consistency drop of ≥20% from previous week

**Interventions:**
- Recurring study reminders
- Suggested daily study blocks
- Parent notification to help establish routines

---

### 5. Peak Productivity Hours
**What's tracked:**
- Time of day when most tasks are completed
- Study session start times
- Top 3 most productive hours

**Usage:**
- Personalized schedule recommendations
- "Schedule important tasks around [peak hour]:00"
- Adaptive task reminders during high-productivity periods

---

## ⚠️ Early Warning System

### Detection Algorithm
The system analyzes:
1. **Recent Activity** (last 7 days)
2. **Historical Patterns** (last 30 days)
3. **Trend Direction** (improving vs. declining)

### Warning Severity Levels

#### 🔴 HIGH Priority
Triggers when:
- Multiple missed deadlines (≥3 in 3 days)
- Extended inactivity (≥3 days no tasks)
- Critical productivity decline

**Actions:**
- Immediate parent alert
- Student notification with urgent tips
- Detailed intervention recommendations

#### 🟠 MEDIUM Priority
Triggers when:
- Moderate procrastination pattern (≥5 in 5 days)
- Consistency drop of 20%+
- Declining productivity trend

**Actions:**
- Parent notification
- Suggested schedule adjustments
- Behavioral pattern analysis

#### 🔵 LOW Priority
Triggers when:
- Minor inconsistencies detected
- Room for optimization

**Actions:**
- Adaptive suggestions
- Productivity tips

---

## 🔔 Student Notifications

### When Unhealthy Patterns Detected
Students see a **Pattern Warning Banner** on their home screen displaying:

1. **Current Issues** (e.g., "Consistent pattern of last-minute completion")
2. **Immediate Suggestions** (e.g., "Use Pomodoro timer for focused sessions")
3. **Detailed Analysis** (click for full behavioral report)

### Notification Content Includes:
- Current patterns (consistency, procrastination, productivity)
- Completion behavior analysis
- Personalized recommendations
- Suggested study schedule based on their peak hours

---

## 👨‍👩‍👧 Parent Alerts

### Enhanced Alert System
Parents receive **actionable guidance** when intervention is needed:

#### Alert Components:
1. **Severity Indicator** (High/Medium/Low)
2. **Detected Issues** (specific behaviors causing concern)
3. **Recommended Actions** (concrete steps to help)
4. **Timing Information** (when patterns were detected)

#### Example Parent Guidance:
```
⚠️ Urgent: Alex Needs Support

Detected Issues:
• Multiple missed deadlines in the past 3 days
• Study consistency has dropped by 35%
• No tasks completed on 4 of the last 7 days

Recommended Actions:
→ Have a conversation about time management
→ Work together to create a weekly study schedule
→ Set up recurring study reminders
→ Alex works best around 14:00 - schedule important tasks then
```

---

## 📈 Completion Time Patterns Dashboard

### Displayed Metrics:
- **On Time**: Tasks completed before/on deadline
- **Late**: Tasks completed after deadline
- **Late Rate**: Percentage of procrastinated tasks
- **Pattern Classification**: Early Completer / Mixed / Chronic Procrastinator

### Pattern-Based Recommendations:

**Early Completer (✅):**
> "Great time management! Keep maintaining this consistent approach"

**Mixed Pattern:**
> "Use the Pomodoro technique to maintain focus and avoid last-minute rushes"

**Chronic Procrastinator (⚠️):**
> "Set earlier personal deadlines 24-48 hours before actual due dates"

---

## 🧠 Adaptive Suggestion Engine

### Data Sources:
1. Behavioral metrics (last 30 days)
2. Study session data
3. Peak productivity analysis
4. Reflection journal entries

### Personalized Suggestions:

**If low consistency:**
```
📅 Try setting a consistent study schedule each day to build better habits.
```

**If high procrastination:**
```
⏰ Consider using the Pomodoro timer to break tasks into focused 25-minute sessions.
```

**If low productivity:**
```
🎯 Break larger tasks into smaller subtasks to make them more manageable.
```

**If peak hours identified:**
```
✨ Your most productive hours are around 14:00. Schedule important tasks then!
```

---

## 📋 Suggested Study Schedule Generator

### Algorithm:
1. Analyzes peak productivity hours from historical data
2. Considers current behavioral patterns
3. Generates personalized study blocks

### Default Schedule (No Historical Data):
```
9:00 AM  - Morning Study Session (50 min)
2:00 PM  - Afternoon Focus Time (50 min)
7:00 PM  - Review & Planning (30 min)
```

### Personalized Schedule Example:
```
14:00 - Peak Productivity Study Block (50 min)
         Based on your highest productivity period

16:00 - Peak Productivity Study Block (50 min)
         Based on your highest productivity period

Daily - Morning Task Planning (10 min)
        Helps prevent last-minute rushes
```

---

## 🎓 Academic Foundation Features

### a. Consistent Study Schedules
**Feature:** Recurring study reminders
- Students can set daily/weekly/monthly recurring tasks
- System tracks adherence to schedule
- Consistency score calculated automatically

### b. Pomodoro Method (Short Focused Sessions)
**Feature:** Built-in 25-minute focus timer
- Work session: 25 minutes
- Short break: 5 minutes
- Long break: 15 minutes (after 4 sessions)
- Tracks total Pomodoro sessions completed

### c. Task Chunking
**Feature:** Subtasks and milestones
- Break large tasks into smaller, manageable subtasks
- Track progress on each subtask
- Visual completion indicators

### d. Reflection After Studying
**Feature:** "What did you finish today?" prompt
- Daily reflection dialogs
- Productivity rating (1-5)
- Challenges and improvements tracking
- Builds metacognitive awareness

### e. Accountability Improves Consistency
**Feature:** Parent progress access
- Real-time dashboard of student metrics
- Behavioral pattern analysis
- Early intervention alerts
- Actionable guidance for parents

---

## 🔧 Implementation Details

### Key Files:
- **behavior_tracking_provider.dart**: Core analytics engine
- **pattern_warning_banner.dart**: Student notification widget
- **parent_dashboard_screen.dart**: Parent monitoring interface
- **behavior_metrics.dart**: Data models for tracking

### Data Tracked Per Day:
```dart
{
  tasksCompleted: int,
  tasksCreated: int,
  tasksMissed: int,
  totalStudyTime: Duration,
  pomodoroSessions: int,
  procrastinationCount: int,
  consistencyScore: double,
  peakProductivityHours: List<int>,
}
```

### Analysis Methods:
- `detectEarlyWarnings()` - Identifies concerning patterns
- `getCompletionTimePatterns()` - Analyzes task timing behavior
- `getParentAlert()` - Generates actionable parent notifications
- `getSuggestedSchedule()` - Creates personalized study schedules
- `getAdaptiveSuggestions()` - Provides context-aware tips

---

## 🚀 Usage

### For Students:
1. Complete tasks and study sessions normally
2. System automatically tracks behaviors
3. Receive warnings when patterns need improvement
4. View detailed analysis by tapping info button on warnings
5. Use suggested schedule to optimize productivity

### For Parents:
1. Access parent dashboard from role selection
2. View real-time metrics and patterns
3. Receive alerts when intervention needed
4. Follow recommended actions to support student
5. Monitor weekly consistency chart

### For Administrators:
1. View aggregated analytics across all students
2. Identify students needing support
3. Track effectiveness of interventions
4. Monitor overall program success

---

## 📊 Success Metrics

The system helps students by:
- ✅ Detecting poor time management **before** academic failure
- ✅ Providing **preventive interventions** instead of reactive fixes
- ✅ Offering **personalized** rather than generic advice
- ✅ Engaging **parents** with actionable guidance
- ✅ Building **self-awareness** through reflection and metrics

---

## 🔮 Future Enhancements

Potential additions:
- Machine learning for pattern prediction
- Integration with calendar apps
- Smart notification timing
- Gamification rewards for consistency
- Peer comparison (anonymized)
- Export reports for teachers/counselors
