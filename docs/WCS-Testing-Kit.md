# WCS Testing Kit

This testing kit extracts the concepts and themes from *iOS Unit Testing by Example* and turns them into a practical production-readiness standard for World Class Scholars iOS apps.

## Chapter themes

### Part I: Foundations

- Assertions, test naming, and the meaning of a unit test.
- Test lifecycle, setUp, tearDown, and the AAA structure.
- Code coverage, characterization tests, and safe progress on legacy code.
- App launch control and isolating view controllers.
- Managing difficult dependencies with fakes, spies, mocks, and dependency injection.

### Part II: iOS testing tips and techniques

- Outlet connections, button taps, alerts, and navigation.
- Testing UserDefaults, network requests, asynchronous responses, and closures.
- Text fields, delegate methods, input focus, table views, and snapshots.
- Text fields, delegate methods, input focus, table views, and snapshots.

### Part III: Using your new power

- Refactoring safely with tests.
- Moving from MVC to MVVM and MVP.
- Applying TDD to drive new code design.

## Production testing scope

### 1. Assertion discipline

Use the right assertion for the behavior under test. Prefer clear failures, avoid redundant messages, and keep tests readable. Use equality tests for state, Boolean assertions for conditions, and explicit failure only when the test truly cannot continue.

### 2. Test lifecycle discipline

Treat each test as a clean room. Put shared setup in setUp, clean up in tearDown, and avoid shared mutable state that leaks between tests. Use **Test Zero** when creating a new suite so you know the test wiring works before adding behavior.

### 3. Coverage discipline

Turn on code coverage early and use it to find gaps, not as a vanity metric. Cover conditions, loops, and sequential statements with enough tests to prove behavior at the boundaries. Add characterization tests for legacy code before changing it.

### 4. View controller discipline

Load storyboards, XIBs, and code-based controllers under test. Verify outlets, actions, alerts, and navigation without depending on the full app flow. When a view needs a real window or hierarchy, add it explicitly so focus and responder behavior works.

> **SwiftUI note:** CareLens Aged+ uses SwiftUI. Host views with `UIHostingController` in a test window when responder chain or layout matters.

### 5. Dependency discipline

Isolate difficult dependencies behind protocols or boundaries. Use dependency injection for network sessions, storage, factories, singleton access, and closures that create objects. Prefer fakes for stateful replacements, spies for observation, and mocks for strict verification.

### 6. UIKit interaction discipline

Test button taps through actions, alerts through verifiers, text fields through their delegates, and tables through data source and delegate calls. Keep helpers small and reusable so tests stay expressive.

### 7. Appearance discipline

Use snapshot tests for layout and rendering changes. Lock reference images for critical screens like onboarding, login, dashboards, and content-entry forms so unplanned UI drift is caught early.

### 8. Refactoring discipline

Refactor in small verified steps. Use tests as your safety net while moving behavior between objects or changing architecture. Verify behavior after every move, especially when extracting presenters, view models, and helper types.

## WCS module checklist

| Area | What to test |
|------|--------------|
| App startup | Launch path, initial controller, scene/app delegate behavior |
| Forms | Text entry, return-key behavior, validation, focus changes |
| Navigation | Push, modal, segue, and dismissal flows |
| Storage | Defaults, persistence, recovery, and empty-state behavior |
| Networking | Requests, responses, async completions, errors, retries |
| Tables | Row count, cell content, row selection, updates |
| Alerts | Message text, button wiring, cancel/confirm behavior |
| Appearance | Layout, snapshot comparisons, device variations |
| Refactoring safety | Tests that protect extracted types and moved logic |

## WCS App Store readiness criteria

A feature is ready only when it has:

- Direct unit tests for core logic.
- View controller tests for UI behavior.
- Dependency isolation for external services.
- Coverage for edge cases and failure paths.
- Snapshot or UI checks for critical appearance.
- CI execution with green results.
- Safe refactoring coverage before structural changes.

## Test design rules

1. Write a failing test first for new behavior.
2. Keep each test focused on one behavior.
3. Prefer stable, fast, deterministic tests.
4. Use helpers to remove repetition, but do not hide intent.
5. Add tests before changing legacy code.
6. Test both success and failure states.
7. Verify the thing the user experiences, not just implementation details.

## Suggested suite structure

| Suite | Purpose |
|-------|---------|
| `AppLaunchTests` | Launch args, test environment, Test Zero |
| `AssertionTests` | Assertion discipline examples |
| `LifecycleTests` | setUp/tearDown clean room |
| `CoverageTests` | Boundary and branch coverage targets |
| `StartupControllerTests` | Auth routing (login vs main app) |
| `NavigationTests` | Tab bar and screen transitions |
| `StorageTests` | SwiftData persistence |
| `NetworkRequestTests` | Request formation and gating |
| `NetworkResponseTests` | Success/failure async handling |
| `TextFieldTests` | Login validation rules |
| `TableViewTests` | List content and selection |
| `AlertTests` | Confirm/cancel flows |
| `SnapshotTests` | Critical screen appearance |
| `RefactoringSafetyTests` | Characterization tests for legacy modules |

## Practical WCS checklist

- [ ] Every screen loads in a test without the full app running.
- [ ] Every important button, field, and cell has a test.
- [ ] Every network request has at least one success and one failure test.
- [ ] Every persistence path has save and reload coverage.
- [ ] Every critical journey has a UI or snapshot test.
- [ ] Every legacy module gets characterization tests before changes.
- [ ] Every release passes CI with test coverage enabled.

## CareLens Aged+ mapping

| WCS suite | Location |
|-----------|----------|
| Foundations | `Carelens-Aged+Tests/FoundationsTests.swift` |
| WCS discipline suites | `Carelens-Aged+Tests/WCS/` |
| End-to-end units | `Carelens-Aged+Tests/EndToEnd/` |
| UI journeys | `Carelens-Aged+UITests/` |
| Device E2E | `scripts/run_e2e_device_systematic.sh` |
| CI | `.github/workflows/ci.yml` |

Run readiness check:

```bash
bash scripts/wcs_test_readiness_check.sh
```
