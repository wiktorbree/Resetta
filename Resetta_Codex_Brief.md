# Resetta — Codex Product & Engineering Brief

## 1. Product Summary

**App name:** Resetta  
**Platform:** Native iOS app  
**Target:** iOS 26+  
**Current pricing model:** Completely free  
**Future pricing model:** May introduce optional paid features later, but the initial architecture should not force monetization or include paywalls.

Resetta is a minimalist dopamine detox app. Its core purpose is to help users intentionally spend time away from stimulation. The app should feel calm, premium, native, and focused. It should not become another productivity app filled with streaks, badges, points, progress bars, gamification, or excessive analytics.

The core user experience is simple:

1. User chooses a detox duration.
2. User optionally chooses an intention.
3. User starts a session.
4. During the active session, the screen shows only a large digital timer.
5. If the user taps the screen, an “End Session” button appears for 5 seconds and then disappears.
6. When the session ends, the user can reflect on how it felt.
7. Completed sessions are saved locally and shown in a calm history/calendar view.

The app should feel like a ritual, not a tool that demands attention.

---

## 2. Product Philosophy

Resetta should follow these principles:

- Minimalism over features.
- Calm over motivation.
- Reflection over gamification.
- Intentional boredom over productivity optimization.
- Native iOS feel over custom flashy UI.
- Quiet design over dopamine-heavy interactions.

The app should avoid:

- XP systems.
- Coins.
- Levels.
- Leaderboards.
- Social feeds.
- Aggressive streak mechanics.
- Confetti.
- Flashy animations.
- Pushy reminders.
- Progress bars during the active timer.

Marketing direction:

> Do nothing. On purpose.

---

## 3. Visual Direction

The app should look and feel like a premium Apple-style calm app.

### General style

- Minimalist.
- Typography-focused.
- Spacious.
- Calm.
- Native SwiftUI.
- No visual clutter.
- Smooth, subtle animations only.

### Colors

Use a simple neutral palette:

- Pure black or near-black for active session.
- Off-white / white text.
- Soft gray secondary text.
- Optional muted accent color.

Possible accent colors:

- Muted blue.
- Soft green.
- Warm beige.
- Amber.

Avoid bright, saturated, dopamine-heavy colors.

### Typography

- Timer: monospaced system font, e.g. `.monospacedDigit()` or SF Mono-like styling.
- Other UI: SF Pro system font.
- Large readable text.
- Avoid dense screens.

### Animations

Use subtle animations only:

- Fade in / fade out.
- Small opacity changes.
- Gentle scale transitions.
- Smooth sheet transitions.

No bouncy, flashy, or gamified animations.

---

## 4. Core Screens

### 4.1 OnboardingView

Purpose: explain the app philosophy quickly and emotionally.

Do not create a long tutorial.

Suggested onboarding screens:

#### Screen 1

Title:

> Your brain wasn’t built for infinite stimulation.

Body:

> Every scroll, swipe and notification trains your mind to escape boredom.

Button:

> Continue

#### Screen 2

Title:

> Silence feels uncomfortable first.

Body:

> That discomfort is the point. Sit with it. Let your brain reset.

Button:

> Continue

#### Screen 3

Title:

> This app does almost nothing.

Body:

> No feeds. No badges. No rewards. Just time away from stimulation.

Button:

> Start your first detox

#### First session screen

Title:

> Start small.

Body:

> Try your first 2-minute reset. Put your phone down. Do nothing.

Button:

> Begin

Implementation note:

- Store onboarding completion in `AppStorage`.
- Keep onboarding visually minimal.

---

### 4.2 HomeView

Purpose: start a detox session quickly.

Primary elements:

- “Today” label.
- Main prompt: “Ready to disconnect?”
- Selected duration displayed prominently.
- Preset duration chips:
  - 5 min
  - 15 min
  - 30 min
  - 60 min
  - Custom
- Primary button: “Start Detox”
- Optional small text: “Sit with the boredom.”

Behavior:

- User selects a duration.
- User taps “Start Detox”.
- App navigates to `SessionIntentView` or directly to `ActiveSessionView` depending on implementation stage.

MVP note:

- It is acceptable to skip custom duration in the first implementation and add it later.

---

### 4.3 SessionIntentView

Purpose: give the session a small emotional context without adding friction.

Title:

> What are you doing this for?

Options:

- Think
- Rest
- Breathe
- Walk
- Journal
- Do nothing

Button:

> Start

Behavior:

- User can select one intention.
- Intention is optional.
- Tapping Start begins `ActiveSessionView`.

MVP note:

- If this slows down initial development, make it optional and simple.

---

### 4.4 ActiveSessionView

This is the most important screen in the app.

Purpose: show only a digital timer during an active dopamine detox session.

Rules:

- Show only the timer by default.
- No progress bar.
- No navigation bar.
- No visible buttons.
- No icons.
- No labels.
- No motivational text.
- No decorations.

Default visible content:

```text
14:32
```

Interaction:

- User taps anywhere on the screen.
- “End Session” button fades in.
- Button remains visible for 5 seconds.
- After 5 seconds, button fades out automatically.
- If user taps again, the 5-second visibility timer resets.

End button:

- Text: “End Session”
- Style: minimal, low-contrast, but tappable.

When End Session is tapped:

- Show confirmation UI, preferably a minimal sheet or overlay.

Confirmation text:

Title:

> End this session?

Body:

> You can stop, but the discomfort may be the practice.

Buttons:

- Continue
- End Session

Orientation behavior:

- `ActiveSessionView` is the only view where landscape orientation is allowed.
- Every other view should remain portrait-only.

Screen behavior:

- Consider keeping the screen awake during active sessions.
- This should be controlled by a setting later.

Timer behavior:

- Timer counts down from selected duration.
- When timer reaches zero:
  - Mark session as completed.
  - Save session data.
  - Navigate to `CompletionView`.

Important technical behavior:

- The timer should remain reliable when app goes into background and returns.
- Use session start date and expected end date rather than relying only on an in-memory countdown.
- Remaining time should be calculated from `endDate.timeIntervalSinceNow`.

---

### 4.5 CompletionView

Purpose: calmly acknowledge a completed session.

Avoid confetti or achievement-like feedback.

Content:

Title:

> Session complete.

Body example:

> You spent 15 minutes without stimulation.

Buttons:

- Reflect
- Done

Behavior:

- Reflect opens `ReflectionView`.
- Done returns to Home.

---

### 4.6 ReflectionView

Purpose: allow the user to record how the session felt.

Title:

> How did it feel?

Options:

- Calm
- Restless
- Clear
- Difficult

Optional note field:

Placeholder:

> Add a note…

Button:

> Save

Behavior:

- Update the session with selected feeling and note.
- Return to Home or History.

Design note:

- Keep this very quiet and simple.
- Reflection should feel personal, not like a productivity report.

---

### 4.7 HistoryView

Purpose: show calm long-term progress without turning the app into a gamified tracker.

Layout:

- Monthly calendar view.
- Each day can show a subtle dot if at least one completed session exists.
- Dot intensity or size can represent total detox time for that day.

Avoid:

- Aggressive streaks.
- Red warning states.
- Shame-based missed days.
- “You failed” messaging.

Useful small stats:

- Quiet time this week.
- Sessions this week.
- Longest session.

Day tap behavior:

- Opens `DayDetailView`.

---

### 4.8 DayDetailView

Purpose: show sessions and reflections for a selected day.

Content:

- Date.
- List of sessions.
- Duration.
- Completion state.
- Intention.
- Feeling.
- Note.

Example:

```text
May 15

15 min
Intent: Do nothing
Feeling: Restless
Note: Hard to sit still, but worth it.
```

---

### 4.9 InsightsView

Optional for v1.0 or later.

Purpose: provide very light, calm insights.

Possible cards:

- Quiet time this week.
- Longest session.
- Most common feeling.
- Best time of day.

Example insight:

> You usually feel calmer after sessions longer than 10 minutes.

Avoid heavy analytics.

---

### 4.10 SettingsView

Purpose: configure essential preferences.

Sections:

#### Session

- Keep screen awake during session.
- Gentle haptics.
- End confirmation.

#### Appearance

- System.
- Light.
- Dark.
- Pure Black Mode.

#### Reminders

- Daily reminder toggle.
- Reminder time.

#### Future integrations

- Apple Health Mindfulness Minutes.
- Live Activities.
- Lock Screen widgets.

#### About

- App philosophy.
- Privacy.
- Contact.

Monetization note:

- Do not include paywall UI in the initial version.
- Do not lock core detox sessions behind payment.
- Architecture may include a neutral `EntitlementService` placeholder later, but do not implement monetization now unless requested.

---

## 5. Navigation Structure

Suggested structure:

- Root decides between:
  - `OnboardingView`
  - Main app

Main app:

- `HomeView`
- `HistoryView`
- `SettingsView`

Possible UI structure:

- Use a minimal TabView with 3 tabs:
  - Home
  - History
  - Settings

Alternative:

- Home as main screen.
- History and Settings accessible from small top buttons.

Recommendation:

For MVP, use a simple `TabView` because it is native and easy to maintain. Keep tab labels minimal.

---

## 6. Data Models

### DetoxSession

```swift
struct DetoxSession: Identifiable, Codable, Hashable {
    let id: UUID
    let startDate: Date
    let endDate: Date
    let plannedDuration: TimeInterval
    let actualDuration: TimeInterval
    let completed: Bool
    var intent: SessionIntent?
    var feeling: SessionFeeling?
    var note: String?
}
```

### SessionIntent

```swift
enum SessionIntent: String, Codable, CaseIterable, Identifiable {
    case think = "Think"
    case rest = "Rest"
    case breathe = "Breathe"
    case walk = "Walk"
    case journal = "Journal"
    case doNothing = "Do nothing"

    var id: String { rawValue }
}
```

### SessionFeeling

```swift
enum SessionFeeling: String, Codable, CaseIterable, Identifiable {
    case calm = "Calm"
    case restless = "Restless"
    case clear = "Clear"
    case difficult = "Difficult"

    var id: String { rawValue }
}
```

### UserSettings

```swift
struct UserSettings: Codable, Hashable {
    var keepScreenAwake: Bool
    var hapticsEnabled: Bool
    var endConfirmationEnabled: Bool
    var pureBlackModeEnabled: Bool
    var dailyReminderEnabled: Bool
    var dailyReminderDate: Date?
}
```

---

## 7. Suggested Services

### SessionTimerService

Responsibilities:

- Start session.
- Track remaining time based on dates.
- Pause is not needed.
- End session.
- Complete session.
- Handle app returning from background.

Important:

- Do not rely only on a decrementing timer.
- Store start date and end date.
- Compute remaining time from real current time.

### SessionStorageService

Responsibilities:

- Save sessions locally.
- Load sessions.
- Update reflection fields.

MVP storage options:

- SwiftData preferred for iOS 26 native app.
- JSON file storage acceptable for early prototype.

Recommendation:

Use SwiftData if the project is clean and iOS 26-only.

### HapticsService

Responsibilities:

- Start haptic.
- End haptic.
- Button reveal haptic.
- Completion haptic.

Keep haptics subtle.

### OrientationService

Responsibilities:

- Allow landscape only during `ActiveSessionView`.
- Force portrait for all other screens.

Important:

- This may require UIKit bridge / AppDelegate / SceneDelegate-style orientation handling.
- Keep implementation isolated to avoid messy code.

### NotificationService

Later feature.

Responsibilities:

- Request notification permission.
- Schedule daily gentle reminder.

Reminder copy examples:

- “Take a quiet moment.”
- “Reset for a few minutes.”
- “Do nothing. On purpose.”

### HealthKitService

Later feature.

Responsibilities:

- Save completed detox sessions as mindfulness minutes.

Do not implement in MVP unless requested.

---

## 8. Orientation Requirement

Important requirement:

- Only `ActiveSessionView` supports landscape.
- All other screens are portrait-only.

Implementation guidance:

- Create a centralized orientation manager.
- Use UIKit integration where needed.
- When entering ActiveSessionView, allow `.portrait`, `.landscapeLeft`, `.landscapeRight`.
- When leaving ActiveSessionView, return to `.portrait` only.

This should be treated as a core UX requirement, not a later feature.

---

## 9. Free App Requirement

The initial version of Resetta must be completely free.

Do not include:

- Paywall.
- Subscription UI.
- In-app purchase implementation.
- Locked features.
- Trial banners.
- Upgrade prompts.

However, write the app in a way that does not make future monetization difficult.

Future paid features may include:

- Extra themes.
- Advanced insights.
- iCloud sync.
- Apple Health integration.
- Live Activities.
- Ambient sounds.
- Custom session packs.

Core timer functionality should remain free even if monetization is added later.

For now:

- No monetization code.
- No fake premium flags.
- No paywall placeholders visible to users.

---

## 10. Privacy Direction

Resetta should be privacy-first.

Initial version:

- All data stored locally on device.
- No account required.
- No analytics required.
- No cloud sync required.

Possible privacy copy:

> Resetta stores your sessions on your device. No account. No feed. No tracking.

---

## 11. MVP Scope

Build this first:

1. Native SwiftUI iOS 26 app.
2. App name: Resetta.
3. Onboarding flow.
4. Home screen with duration presets.
5. Optional session intention selection.
6. Active timer screen.
7. Timer-only UI during active session.
8. Tap anywhere to reveal “End Session” for 5 seconds.
9. End confirmation.
10. Session completion screen.
11. Reflection screen.
12. Local session saving.
13. History screen with basic list or simple calendar.
14. Settings screen with basic toggles.
15. Orientation: landscape only during timer, portrait elsewhere.
16. Completely free app with no paywall.

---

## 12. V1.0 Scope

After MVP works, improve with:

1. Better calendar UI.
2. Custom duration picker.
3. Weekly quiet time summary.
4. Haptics polish.
5. Pure black mode.
6. Gentle reminders.
7. Better empty states.
8. Better onboarding copy polish.
9. App icon concept.
10. Accessibility improvements.

---

## 13. Future Scope

Possible future features:

1. Live Activities.
2. Dynamic Island support.
3. Lock Screen widgets.
4. Apple Health Mindfulness Minutes.
5. iCloud sync.
6. Ambient sounds.
7. Siri Shortcuts.
8. Focus Mode integration.
9. Optional paid themes or advanced insights.

Do not implement these in the first build unless specifically requested.

---

## 14. Accessibility Requirements

The app should support:

- Dynamic Type where reasonable.
- VoiceOver labels.
- High contrast readability.
- Reduced Motion support.
- Large tap targets.

Active timer should remain extremely readable.

---

## 15. Suggested File Structure

```text
Resetta/
  App/
    ResettaApp.swift
    AppRootView.swift
  Models/
    DetoxSession.swift
    SessionIntent.swift
    SessionFeeling.swift
    UserSettings.swift
  Services/
    SessionTimerService.swift
    SessionStorageService.swift
    HapticsService.swift
    OrientationService.swift
    NotificationService.swift
  Views/
    Onboarding/
      OnboardingView.swift
      OnboardingPageView.swift
    Home/
      HomeView.swift
      DurationPresetView.swift
    Session/
      SessionIntentView.swift
      ActiveSessionView.swift
      EndSessionConfirmationView.swift
      CompletionView.swift
      ReflectionView.swift
    History/
      HistoryView.swift
      DayDetailView.swift
      CalendarDayCell.swift
    Settings/
      SettingsView.swift
  Theme/
    ResettaTheme.swift
    Typography.swift
  Utilities/
    TimeFormatting.swift
```

---

## 16. Development Priorities

Build in this order:

1. Project setup and app shell.
2. Models.
3. Home screen.
4. Timer logic.
5. ActiveSessionView.
6. Tap-to-reveal End Session button.
7. Completion and reflection flow.
8. Local storage.
9. History.
10. Onboarding.
11. Settings.
12. Orientation handling.
13. Polish and accessibility.

---

## 17. Final Product Reminder for Codex

Resetta should feel like opening a quiet room.

The app should not entertain the user.  
The app should not reward the user with dopamine.  
The app should not compete for attention.  
The app should help the user put the phone down.

Core experience:

> Choose time. Start. See only timer. Do nothing. Reflect. Leave.
