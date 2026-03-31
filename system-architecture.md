# Student Daily Workflow System Architecture

> Complete technical reference for reproducing the conversation-driven workflow system in Boxel.

---

## Table of Contents

1. [System Overview](#system-overview)
2. [Architecture Diagram](#architecture-diagram)
3. [Card Definitions (GTS)](#card-definitions-gts)
4. [Predicate Engine](#predicate-engine)
5. [Real-Time Interaction Model](#real-time-interaction-model)
6. [UI Component Formats](#ui-component-formats)
7. [Design System](#design-system)
8. [Data Model (JSON)](#data-model-json)
9. [File Inventory](#file-inventory)
10. [Reproduction Guide](#reproduction-guide)

---

## System Overview

### What It Is

An AI-augmented daily activity tracking system for special education classrooms. Teachers type natural observations into a conversation feed; a **predicate engine** auto-classifies entries against schedule blocks, and an **AI responder** confirms matches in real time.

### Core Flow

```
Teacher types observation
       |
       v
Message added to localMessages (@tracked)
       |
       v
Predicate engine evaluates ALL messages against step predicates
       |
       v
Matching schedule blocks auto-complete (checkbox + donut update)
       |
       v
AI Classification response generated (with matched block label)
       |
       v
Activity Log sidebar updates
```

### Key Constraints

- **Boxel runtime**: Card fields (`containsMany`, `linksTo`) cannot be reliably assigned from component code (`this.args.model.messages = [...]` fails silently). All new session messages go through `@tracked localMessages` instead.
- **No persistent writes**: New messages exist only for the current session. Persisted messages come from the JSON data files.
- **String-typed booleans**: `isBot` is `StringField` stored as `''` or `'true'`, not a boolean.
- **Predicate evaluation is pure**: `resolveWorkflowState()` is a stateless function — given a model + message facts, it returns the complete workflow state.

---

## Architecture Diagram

```
ClassroomWorkflowDashboard (master-detail)
  |
  |-- workflows: linksToMany StudentDayWorkflow
  |     |
  |     |-- student: linksTo Student
  |     |-- participants: containsMany ParticipantField
  |     |-- messages: containsMany MessageField        <-- persisted conversation
  |     |-- steps: containsMany StepField              <-- schedule blocks + predicates
  |     |-- attachments: containsMany AttachmentField
  |     |     |
  |     |     |-- linkedCard: linksTo CardDef
  |     |           |-- GoalProgressCard
  |     |           |-- BehaviorIncidentCard
  |     |           |-- AssessmentResultCard
  |     |
  |     |-- [Component State]
  |           |-- localMessages: MessageView[]   <-- session-only messages
  |           |-- _messagesVersion: number       <-- reactivity trigger
  |
  Student
  |-- tags: containsMany StudentTag
  |-- alerts: containsMany Alert
  |-- supportStaff: linksTo Staff
  |
  LearningGoal
  |-- student: linksTo Student
```

### Six Layers

| Layer | Purpose | Cards |
|-------|---------|-------|
| Enums | Typed dropdowns | GradeLevel, EntryType, BlockDomain, BlockStatus, DayStatus, AiSuggestionStatus, AlertUrgency, TagType |
| Shared Fields | Reusable compound fields | StudentTag, Alert, ParentInfo |
| Entity Cards | People & goals | Student, Staff, LearningGoal |
| Attachment Cards | Structured evidence | GoalProgressCard, BehaviorIncidentCard, AssessmentResultCard |
| Operational Cards | Daily workflow engine | StudentDayWorkflow (with predicate engine) |
| Dashboard | Classroom overview | ClassroomWorkflowDashboard |

---

## Card Definitions (GTS)

### StudentDayWorkflow (`student-day-workflow.gts`)

The main card — contains the entire conversation UI, predicate engine, and AI responder.

#### Fields

| Field | Type | Description |
|-------|------|-------------|
| `student` | `linksTo(CardDef)` | Linked Student card |
| `studentName` | `StringField` | Display name |
| `studentInitials` | `StringField` | 2-letter initials for avatar |
| `dateLabel` | `StringField` | e.g. "Mar 14, 2026" |
| `gradeLabel` | `StringField` | e.g. "2nd Grade" |
| `category` | `StringField` | "IEP", "504", or "Gen Ed" |
| `categoryTone` | `StringField` | CSS class: `iep`, `plan504`, `gened` |
| `title` | `StringField` | Card header title |
| `preview` | `StringField` | Summary text for fitted view |
| `progressPercent` | `NumberField` | Fallback progress (overridden by engine) |
| `progressTone` | `StringField` | CSS class for donut color |
| `unreadCount` | `NumberField` | Badge count on fitted card |
| `composerPlaceholder` | `StringField` | Textarea placeholder text |
| `participants` | `containsMany(ParticipantField)` | Team members |
| `messages` | `containsMany(MessageField)` | Persisted conversation |
| `steps` | `containsMany(StepField)` | Schedule blocks with predicates |
| `attachments` | `containsMany(AttachmentField)` | Evidence cards linked to messages |
| `cardTitle` | Computed `StringField` | `title ?? studentName ?? 'Student Workflow'` |

#### Nested FieldDefs

**MessageField**

| Field | Type | Values |
|-------|------|--------|
| `initials` | `StringField` | "LC", "SM", "AI", etc. |
| `author` | `StringField` | "@You", "Mr. Chen", "AI Classification", "System" |
| `sentAt` | `StringField` | "8:20 AM" format |
| `text` | `StringField` | Message body |
| `tone` | `StringField` | `teacher`, `aide`, `therapist`, `ai`, `system` |
| `isBot` | `StringField` | `""` (human) or `"true"` (bot/AI/system) |

**StepField**

| Field | Type | Description |
|-------|------|-------------|
| `label` | `StringField` | "Homeroom", "DI Math", "Dismissal", etc. |
| `status` | `StringField` | Static fallback: "completed", "upcoming" |
| `weight` | `NumberField` | Progress weight (default 1) |
| `predicate` | `contains(PredicateField)` | Auto-completion rule |

**PredicateField**

| Field | Type | Description |
|-------|------|-------------|
| `group` | `StringField` | `"all"` (AND) or `"any"` (OR) |
| `conditions` | `containsMany(PredicateConditionField)` | List of conditions |

**PredicateConditionField**

| Field | Type | Description |
|-------|------|-------------|
| `subject` | `StringField` | `"message"`, `"attachment"`, or `"linked-card"` |
| `textContains` | `StringField` | Substring match (case-insensitive) |
| `author` | `StringField` | Exact match on message author |
| `tone` | `StringField` | Exact match on message tone |
| `attachmentType` | `StringField` | For attachment subjects |
| `fieldName` | `StringField` | For linked-card field inspection |
| `comparator` | `StringField` | `"equals"`, `"contains"`, or presence |
| `value` | `StringField` | Expected value for comparator |

**ParticipantField**

| Field | Type | Values |
|-------|------|--------|
| `initials` | `StringField` | "LC", "SM", "KR" |
| `name` | `StringField` | "Mr. Chen" |
| `role` | `StringField` | "Lead Teacher", "Classroom Aide", "Speech Therapist" |
| `tone` | `StringField` | `teacher`, `aide`, `therapist` |

**AttachmentField**

| Field | Type | Description |
|-------|------|-------------|
| `attachmentType` | `StringField` | `"goal-progress"`, `"behavior-incident"`, `"assessment"` |
| `typeLabel` | `StringField` | Display label |
| `status` | `StringField` | Card status |
| `ctaLabel` | `StringField` | Button text, e.g. "View Goal Data" |
| `messageRef` | `StringField` | Index (as string) of parent message |
| `linkedCard` | `linksTo(CardDef)` | The evidence card |

#### Component State (Isolated View)

| Property | Type | Purpose |
|----------|------|---------|
| `draftMessage` | `@tracked string` | Textarea value |
| `localMessages` | `@tracked MessageView[]` | Session-only messages |
| `_messagesVersion` | `@tracked number` | Reactivity counter — consumed in `workflowState` getter, incremented on send/AI response |
| `isAtBottom` | `@tracked boolean` | Auto-scroll flag |
| `isReplaying` | `@tracked boolean` | Replay mode active |
| `replayVisibleCount` | `@tracked number` | Messages shown during replay |
| `showTyping` | `@tracked boolean` | Typing indicator visible |
| `typingAuthor` | `@tracked string` | Who is "typing" |
| `typingInitials` | `@tracked string` | Avatar initials |
| `typingTone` | `@tracked string` | Avatar color class |

#### MessageView Interface (Component-Level)

```typescript
interface MessageView {
  id: string;              // "msg-3" or "local-1711035600000"
  initials: string;
  author: string;
  sentAt: string;
  text: string;
  tone: string;
  isOwn: boolean;          // true if author === '@You'
  isBot: boolean;          // true boolean (not string)
  attachmentIndices: number[];  // indices into model.attachments
}
```

---

### ClassroomWorkflowDashboard (`classroom-workflow-dashboard.gts`)

Master-detail layout showing all student workflows for a classroom.

| Field | Type | Description |
|-------|------|-------------|
| `dashboardTitle` | `StringField` | Header title |
| `classroomName` | `StringField` | e.g. "Classroom 2A" |
| `dateLabel` | `StringField` | e.g. "Mar 14, 2026" |
| `workflows` | `linksToMany(CardDef)` | StudentDayWorkflow cards |

**Component state**: `@tracked selectedIndex` (number) — which workflow is displayed in detail.

**Layout**: 300px dark nav sidebar | workflow isolated view.

---

### GoalProgressCard (`attachment-cards.gts`)

Evidence card showing goal mastery change.

| Field | Type | Description |
|-------|------|-------------|
| `goalTitle` | `StringField` | "Count to 20 independently" |
| `domain` | `StringField` | Math, Reading, Social, Behavioral, Motor, Communication |
| `currentMastery` | `NumberField` | Current percentage |
| `previousMastery` | `NumberField` | Previous percentage |
| `targetMastery` | `NumberField` | Target percentage |
| `trialResult` | `StringField` | Short trial description |
| `sessionNote` | `StringField` | Detailed session note |
| `linkedGoal` | `linksTo(CardDef)` | Reference to LearningGoal card |

**Computed**: `delta` (current - previous), `deltaLabel` ("+10%"), `domainColor`.

---

### BehaviorIncidentCard (`attachment-cards.gts`)

ABC-model behavior documentation.

| Field | Type | Description |
|-------|------|-------------|
| `incidentType` | `StringField` | "Task refusal", "Off-task behavior" |
| `severity` | `StringField` | "High", "Medium", "Low" |
| `antecedent` | `StringField` | What happened before |
| `behavior` | `StringField` | What the student did |
| `consequence` | `StringField` | How it was resolved |
| `duration` | `StringField` | "5 min" |

---

### AssessmentResultCard (`attachment-cards.gts`)

Formal assessment documentation.

| Field | Type | Description |
|-------|------|-------------|
| `assessmentName` | `StringField` | "DI Math Lesson 45 Quiz" |
| `domain` | `StringField` | Math, Reading, etc. |
| `score` | `StringField` | "8/10" |
| `percentage` | `NumberField` | 80 |
| `benchmark` | `StringField` | "Exceeds", "Proficient", "Approaching", "Below" |
| `notes` | `StringField` | Assessment notes |

---

### Student (`student.gts`)

| Field | Type | Description |
|-------|------|-------------|
| `firstName` | `StringField` | |
| `lastName` | `StringField` | |
| `preferredName` | `StringField` | Nickname |
| `gradeLevel` | `contains(GradeLevel)` | Enum with `value` |
| `photoUrl` | `StringField` | Avatar image URL |
| `location` | `StringField` | "In Classroom" |
| `locationDetail` | `StringField` | |
| `hasIEP` | `BooleanField` | |
| `has504` | `BooleanField` | |
| `hasAllergy` | `BooleanField` | |
| `hasMedication` | `BooleanField` | |
| `tags` | `containsMany(StudentTag)` | IEP, 504, Allergy, etc. |
| `alerts` | `containsMany(Alert)` | Urgent/normal alerts |
| `supportStaff` | `linksTo(Staff)` | |

**Computed fields**: `displayName`, `fullName`, `initials`, `name`, `shortName`, `grade`, `avatar`, `tagSummary`, `title`.

---

### Staff (`staff.gts`)

| Field | Type | Description |
|-------|------|-------------|
| `name` | `StringField` | "Mr. Chen" |
| `role` | `StringField` | "Lead Teacher", "Classroom Aide" |
| `initials` | `StringField` | "LC" |
| `avatar` | `StringField` | Image URL |
| `color` | `StringField` | `coral`, `teal`, `purple`, `amber` |

---

### LearningGoal (`learning-goal.gts`)

| Field | Type | Description |
|-------|------|-------------|
| `goalTitle` | `StringField` | |
| `description` | `StringField` | Full IEP goal text |
| `domain` | `StringField` | Math, Reading, Social, Behavioral |
| `priority` | `StringField` | High, Medium, Low |
| `currentMastery` | `NumberField` | 0-100 |
| `targetMastery` | `NumberField` | 0-100 |
| `student` | `linksTo(CardDef)` | |

---

### Shared Fields (`shared-fields.gts`)

**StudentTag**: `label` (StringField), `color` (StringField), `tagType` (contains TagType). Renders as a colored pill.

**Alert**: `alertType` (StringField), `urgency` (StringField: "Urgent"/"normal"), `message` (StringField), `detail` (StringField). Renders with urgency-colored left border.

**ParentInfo**: `firstName`, `lastName`, `relationship`, `email`, `phone` (all StringField). Renders as 2x2 grid.

---

### Enums (`enums.gts`)

All enums are FieldDefs with a `value` StringField and an embedded component rendering a colored pill.

| Enum | Values | Color Mapping |
|------|--------|---------------|
| `GradeLevel` | Any string (K, 1st, 2nd...) | No color |
| `EntryType` | academic, social, behavioral, curriculumnote, observation | coral, purple, amber, teal, neutral |
| `BlockDomain` | math, reading, social, behavioral, motor, communication, general | coral, amber, purple, amber, teal, blue, neutral |
| `BlockStatus` | done, current, upcoming, skipped | teal, coral, neutral, neutral |
| `DayStatus` | planned, in-progress, completed, absent | neutral, coral, teal, neutral |
| `AiSuggestionStatus` | pending, accepted, rejected, edited | amber, teal, coral, purple |
| `AlertUrgency` | Any string | No color |
| `TagType` | Any string | No color |

---

### AiTagSuggestion (`ai-tag-suggestion.gts`)

AI confidence display field.

| Field | Type | Description |
|-------|------|-------------|
| `suggestedType` | `StringField` | academic/social/behavioral |
| `suggestedBlock` | `StringField` | Schedule block name |
| `suggestedGoal` | `StringField` | Goal name |
| `confidence` | `NumberField` | 0-100 |
| `reasoning` | `StringField` | AI explanation |
| `accepted` | `StringField` | pending/accepted/rejected/edited |

---

## Predicate Engine

### How It Works

The predicate engine is a **pure function pipeline** that runs on every render:

```
model.messages + localMessages
        |
        v
  buildMessageFacts()    -->  MessageFact[]
  buildAttachmentFacts() -->  AttachmentFact[]
        |
        v
  For each step.predicate:
    evaluatePredicate(predicate, messageFacts, attachmentFacts)
        |
        v
  step.completed = true/false
        |
        v
  Calculate progressPercent = completedWeight / totalWeight * 100
```

### Interfaces

```typescript
interface MessageFact {
  index: number;
  author: string;
  tone: string;
  text: string;
  isBot: boolean;
}

interface AttachmentFact {
  index: number;
  attachmentType: string;
  typeLabel: string;
  status: string;
  messageIndex: number;
  author: string;
  tone: string;
  text: string;
  linkedCard: CardDef | null;
}
```

### Condition Matching

For **message** subjects:
1. If `condition.author` is set, message author must match exactly (case-insensitive)
2. If `condition.tone` is set, message tone must match exactly
3. If `condition.textContains` is set, message text must include it (case-insensitive substring)
4. All specified conditions must pass (implicit AND within a single condition)

For **attachment** subjects:
1. Same as message, plus `condition.attachmentType` must match

For **linked-card** subjects:
1. Attachment must have a linkedCard
2. Attachment conditions must pass
3. If `condition.fieldName` is set, the linked card's field value is checked with `condition.comparator` and `condition.value`

### Group Logic

- `group: "all"` — every condition in the array must be satisfied (AND)
- `group: "any"` — at least one condition must be satisfied (OR)

### Step Resolution

1. For each step, if it has a predicate with conditions, evaluate against facts
2. If no predicate, fall back to `step.status === 'completed'`
3. First non-completed step gets status `"current"`; rest are `"upcoming"`
4. Progress = `sum(completed weights) / sum(all weights) * 100`, rounded

### Reactivity Bridge

Since `model.messages` changes don't trigger Glimmer auto-tracking through function boundaries:

```typescript
@tracked _messagesVersion = 0;  // incremented on every send/AI response

get workflowState() {
  this._messagesVersion;  // consume tracking tag to force recompute
  // ... build extra facts from localMessages
  // ... call resolveWorkflowState(model, undefined, extraFacts)
}
```

---

## Real-Time Interaction Model

### sendMessage()

```
User presses Enter or clicks Send
  |
  v
1. Trim draft text, bail if empty
2. Generate timestamp ("3:45 PM" format)
3. Push MessageView to localMessages array (immutable spread)
4. Increment _messagesVersion (triggers workflowState recompute)
5. Clear draftMessage, set isAtBottom, scrollToBottom
6. Call generateAiResponse(text, timestamp)
```

### generateAiResponse()

```
After 600-1000ms delay (setTimeout):
  |
  v
1. Scan all step predicates for textContains match against user text
2. If match found: "Matched schedule block: {label}. Block marked as documented."
3. If no match: "No schedule block matched — recorded as general note."
4. Push AI MessageView to localMessages
5. Increment _messagesVersion
6. scrollToBottom
```

### Replay System

```
User clicks play button
  |
  v
1. Clear localMessages, set isReplaying=true, replayVisibleCount=0
2. scheduleNextReplayMessage() — recursive:
   a. If count >= total: stop replay
   b. If next message isBot: short delay (300-800ms), show immediately
   c. If human: think delay (700-1900ms) + show typing indicator + type delay
   d. Increment replayVisibleCount, scrollToBottom, recurse
3. workflowState uses limit parameter during replay
4. Sidebar shows real-time progress as messages appear
```

---

## UI Component Formats

Every CardDef has four view formats:

### Isolated (Full Page)

**StudentDayWorkflow**: Two-column layout
- Left: conversation header + message stream + composer
- Right: student sidebar (donut progress, schedule blocks, activity log, team)

**ClassroomWorkflowDashboard**: Two-column master-detail
- Left 300px: dark nav with fitted workflow cards
- Right: selected workflow in isolated format

### Fitted (Tile Card)

Dark gradient background (~160px tall) showing:
- Date, category pill, unread badge
- Student initials + name
- Title + preview text
- Team members + mini progress ring

### Embedded (Compact Inline)

Dark rounded bar showing:
- Initials, category pill, name, mini ring + percentage

### Atom (Minimal Badge)

Single-line inline badge (Student, Staff only).

---

## Design System

### Color Palette

```
--c-dark:    #0f1117     (background)
--c-white:   #ffffff
--c-surface: #f7f8fa     (light gray)
--c-border:  #e4e7ed
--c-text:    #1a1f2e
--c-muted:   #6b7280
--c-accent:  #2a9d8f     (teal)
--c-ai:      #0aad82     (green)
--c-ai-bg:   rgba(10, 173, 130, 0.08)
```

### Role Colors

| Role | Color | Hex |
|------|-------|-----|
| Teacher | Teal | `#2a9d8f` |
| Aide | Purple | `#7c5fc4` |
| Therapist | Amber | `#c08b30` |
| AI | Green | `#0aad82` |
| System | Gray | `#94a3b8` |

### Category Colors

| Category | Pill BG | Text | Donut |
|----------|---------|------|-------|
| IEP | `rgba(224,93,80,0.12)` | `#e05d50` | `#e05d50` |
| 504 | `rgba(192,139,48,0.12)` | `#c08b30` | `#c08b30` |
| Gen Ed | `rgba(42,157,143,0.12)` | `#2a9d8f` | `#2a9d8f` |

### Domain Colors

| Domain | Color |
|--------|-------|
| Math | `#e05d50` (coral) |
| Reading | `#c08b30` (amber) |
| Social | `#7c5fc4` (purple) |
| Behavioral | `#c08b30` (amber) |
| Motor | `#2a9d8f` (teal) |
| Communication | `#4a7cc4` (blue) |

### CSS Donut Progress

```css
@property --pct {
  syntax: '<number>';
  inherits: false;
  initial-value: 0;
}

.donut {
  --pct: 0;
  width: 110px; height: 110px; border-radius: 50%;
  background:
    radial-gradient(closest-side, #fff 72%, transparent 74%),
    conic-gradient(var(--ring-c) calc(var(--pct) * 1%), var(--track-c) 0);
  transition: --pct 420ms cubic-bezier(0.22, 1, 0.36, 1);
}
```

Set via template: `style={{concat '--pct:' this.workflowState.progressPercent ';'}}`

### Animations

| Animation | Duration | Effect |
|-----------|----------|--------|
| `msgFadeIn` | 0.25s | Opacity 0→1, translateY 8→0 |
| `typingBounce` | 1.4s infinite | Three dots bouncing |
| `donutBreathe` | 3.2s infinite | Scale 1→1.018→1 (during replay) |

### Attachment Card Click Behavior

- **Card body** (`.att-card-body`): `pointer-events: none` prevents Boxel navigation on preview click
- **CTA button** (`.att-cta`): Contains invisible `<LinkedCard @format="atom" />` overlay that triggers Boxel's navigation when clicked

```css
.att-no-nav { pointer-events: none; }
.att-cta { position: relative; }
.att-cta-text { position: relative; z-index: 1; pointer-events: none; }
.att-cta-nav { position: absolute; inset: 0; opacity: 0; z-index: 2; overflow: hidden; }
```

---

## Data Model (JSON)

### JSON Card Structure

Every card instance follows this pattern:

```json
{
  "data": {
    "type": "card",
    "attributes": {
      "fieldName": "value",
      "nestedField": { "subField": "value" },
      "arrayField": [{ "item1": "value" }]
    },
    "relationships": {
      "linkedField": {
        "links": { "related": "../CardType/card-name" }
      }
    },
    "meta": {
      "adoptsFrom": {
        "module": "./source-file",
        "name": "ExportedClass"
      }
    }
  }
}
```

### Sample Data: Jamie Chen Workflow

**4 Students**: Jamie Chen (IEP + Allergy), Riley Kim (IEP + ADHD meds), Alex Park (504), Emma Walsh (Gen Ed)

**3 Staff**: Mr. Chen (coral), Ms. Martinez (teal), Ms. Rivers (purple)

**5 Learning Goals**:
- Jamie: "Count to 20" (Math, High, 55/80) + "Request help" (Social, High, 30/70)
- Riley: "50 Dolch sight words" (Reading, High, 40/80) + "Sustain attention 10 min" (Behavioral, Medium, 35/60)
- Alex: "Comprehension at Level F" (Reading, Medium, 60/85)

**3 GoalProgressCards**: Jamie math (45→55%), Jamie social (30→50%), Riley reading (52→60%)

**2 BehaviorIncidentCards**: Alex task refusal (Medium, 5 min), Riley off-task (Low, 3 min)

**2 AssessmentResultCards**: Jamie math quiz (8/10, 80%, Proficient), Riley sight words (15/25, 60%, Approaching)

**1 Dashboard**: Classroom 2A linking all 4 workflows

### Predicate Patterns Per Student

**Jamie Chen** (6 steps, 83% complete):

| Step | Predicate | Status |
|------|-----------|--------|
| Homeroom | `message textContains "homeroom"` | completed |
| DI Math | `message textContains "math" AND attachment type "goal-progress"` | completed |
| Reading | `message textContains "reading"` | completed |
| Snack / Recess | `message textContains "snack"` | completed |
| Social Skills | `message textContains "social skills"` | completed |
| Dismissal | `message textContains "dismissal"` | upcoming |

**Riley Kim** (6 steps, 50% complete):

| Step | Predicate | Status |
|------|-----------|--------|
| Homeroom | `message textContains "homeroom"` | completed |
| DI Math | `message textContains "math"` | completed |
| Reading | `message textContains "reading"` | completed |
| Snack / Recess | `message textContains "snack"` | upcoming |
| OT / Motor | `message textContains "motor"` | upcoming |
| Dismissal | `message textContains "dismissal"` | upcoming |

**Alex Park** (6 steps, 50% complete):

| Step | Predicate | Status |
|------|-----------|--------|
| Homeroom | `message textContains "homeroom"` | completed |
| DI Math | `message textContains "math"` | completed |
| Reading | `message textContains "reading"` | completed |
| Snack / Recess | `message textContains "snack"` | upcoming |
| Speech Therapy | `message textContains "speech"` | upcoming |
| Dismissal | `message textContains "dismissal"` | upcoming |

**Emma Walsh** (6 steps, 67% complete):

| Step | Predicate | Status |
|------|-----------|--------|
| Homeroom | `message textContains "homeroom"` | completed |
| DI Math | `message textContains "math"` | completed |
| Reading | `message textContains "reading"` | completed |
| Snack / Recess | `message textContains "snack"` | completed |
| Social Skills | `message textContains "social skills"` | upcoming |
| Dismissal | `message textContains "dismissal"` | upcoming |

### Attachment Linking Pattern

Attachments reference their parent message by index:

```json
{
  "attachmentType": "goal-progress",
  "typeLabel": "Math: 45% -> 55%",
  "status": "current",
  "ctaLabel": "View Goal Data",
  "messageRef": "4"
}
```

`messageRef: "4"` means this attachment renders below message index 4 in the conversation. The relationship links to the actual card:

```json
"relationships": {
  "attachments": {
    "links": {
      "related": null
    }
  },
  "attachments.0.linkedCard": {
    "links": {
      "related": "../GoalProgressCard/jamie-math-progress"
    }
  }
}
```

---

## File Inventory

### GTS Source Files (9 files)

| File | Lines | Exports | Description |
|------|-------|---------|-------------|
| `student-day-workflow.gts` | ~1,410 | StudentDayWorkflow + 6 FieldDefs | Main workflow card + predicate engine |
| `classroom-workflow-dashboard.gts` | 280 | ClassroomWorkflowDashboard | Master-detail dashboard |
| `attachment-cards.gts` | 471 | GoalProgressCard, BehaviorIncidentCard, AssessmentResultCard | 3 evidence cards |
| `learning-goal.gts` | 179 | LearningGoal | IEP goal card |
| `student.gts` | 281 | Student | Student entity |
| `staff.gts` | 182 | Staff | Staff entity |
| `shared-fields.gts` | 148 | StudentTag, Alert, ParentInfo | Reusable fields |
| `enums.gts` | 247 | 8 enum FieldDefs | Typed dropdowns |
| `ai-tag-suggestion.gts` | 125 | AiTagSuggestion | AI confidence display |

### JSON Data Files (24 files)

| Directory | Count | Cards |
|-----------|-------|-------|
| `StudentDayWorkflow/` | 4 | jamie-chen-day, riley-kim-day, alex-park-day, emma-walsh-day |
| `Student/` | 4 | jamie-chen, riley-kim, alex-park, emma-walsh |
| `Staff/` | 3 | mr-chen, ms-martinez, ms-rivers |
| `LearningGoal/` | 5 | jamie-count-to-20, jamie-request-help, riley-sight-words, riley-focus-duration, alex-reading-comprehension |
| `GoalProgressCard/` | 3 | jamie-math-progress, jamie-social-progress, riley-reading-progress |
| `BehaviorIncidentCard/` | 2 | alex-refusal, riley-focus-break |
| `AssessmentResultCard/` | 2 | jamie-math-quiz, riley-sight-word-check |
| `ClassroomWorkflowDashboard/` | 1 | classroom-2a |

### Config Files

| File | Purpose |
|------|---------|
| `index.json` | Workspace root (adopts IndexCard) |
| `cards-grid.json` | Card grid layout (adopts CardsGrid) |

---

## Reproduction Guide

### Step-by-Step

1. **Create Boxel workspace** via CLI or app
2. **Create enum file** (`enums.gts`) — all 8 enums with colored embedded components
3. **Create shared fields** (`shared-fields.gts`) — StudentTag, Alert, ParentInfo
4. **Create entity cards** — Student, Staff, LearningGoal (each with isolated/fitted/embedded/atom views)
5. **Create attachment cards** (`attachment-cards.gts`) — GoalProgressCard, BehaviorIncidentCard, AssessmentResultCard
6. **Create the main workflow card** (`student-day-workflow.gts`):
   - Define all 6 FieldDefs (MessageField, StepField, PredicateField, PredicateConditionField, ParticipantField, AttachmentField)
   - Implement the predicate engine functions
   - Implement the Isolated component with conversation UI, composer, sidebar, replay system
   - Implement Fitted and Embedded views
7. **Create the dashboard** (`classroom-workflow-dashboard.gts`) — master-detail layout
8. **Create AiTagSuggestion** (`ai-tag-suggestion.gts`)
9. **Create JSON data files** — students, staff, goals, evidence cards, workflow cards, dashboard
10. **Push to Boxel** with `boxel push <local-dir> <workspace-url> --force`

### Key Implementation Notes

- **Imports**: All Boxel imports come from `https://cardstack.com/base/...` URLs
- **Glimmer**: Use `@tracked` for component state, `@field` for card fields
- **Templates**: Glimmer/Ember template syntax (`{{#if}}`, `{{#each}}`, `{{on 'click' this.handler}}`)
- **CSS**: All styles use `<style scoped>` inside template blocks
- **Helpers**: `concat`, `get` from `@ember/helper`; `eq` from `@cardstack/boxel-ui/helpers`
- **Modifiers**: `on` from `@ember/modifier`
- **Reactivity**: Use `@tracked` counters to force getter recomputation when Boxel field changes don't propagate through function boundaries
- **String booleans**: `isBot` field is StringField (`""` / `"true"`), not BooleanField. Compare with `=== 'true'`
- **Attachment click**: Use `pointer-events: none` on card body + invisible LinkedCard overlay on CTA button
- **No direct model writes**: Don't assign to `this.args.model.fieldName` from component code; use `@tracked` local state instead
