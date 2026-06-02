# App Store Review — Prepared Responses

Use these if Apple requests clarification during review.

## Guideline 1.4.1 — Physical Harm / Medical Apps

CareLens Aged+ is **clinical decision-support**, not a diagnostic or treatment device. The app:

- Displays disclaimers on AI insight and NeuroWatch screens stating outputs require professional review.
- Does not claim to diagnose, cure, or treat conditions.
- Does not provide emergency triage or replace emergency services.

## Guideline 2.1 — Demo Account

| Field | Value |
|-------|-------|
| Username | `admin@carelens.health` |
| Password | `CareLens2026!` |

Tap the **Admin** demo credential button on the login screen, then **Sign In**. The account has Enterprise tier access with sample data preloaded.

## Guideline 2.3.2 — Accurate Metadata

Screenshots are captured from the production UI using UI tests on iPhone 17 Pro Max and iPad simulators. No mockups or misleading imagery.

## Guideline 3.1.1 — Access

This version does not include locked digital content or access flows. Access levels are assigned by organisation administrators. Reviewers can use the demo admin account with Enterprise access.

## Guideline 5.1.1 — Privacy / Health Data

- Health and clinical data are entered by authorised users for care delivery.
- Data syncs via Apple CloudKit under the user's Apple ID.
- Privacy Policy: https://wcs-full.vercel.app/privacy
- In-app legal documents: Settings → Legal & Compliance
- Privacy manifest: `PrivacyInfo.xcprivacy` included in the app bundle
- No third-party advertising or tracking

## Guideline 5.1.2 — AI / Data Use

When users request AI insights, relevant assessment context is sent to our API to generate decision-support text. Users are informed via Terms of Use and Privacy Policy. No training on customer data without consent.

## Export Compliance

The app uses standard HTTPS/TLS only. `ITSAppUsesNonExemptEncryption` is set to `false`.

## Contact

Christopher Appiah-Thompson  
christopher.appiahthompson@myworldclass.org  
https://wcs-full.vercel.app
