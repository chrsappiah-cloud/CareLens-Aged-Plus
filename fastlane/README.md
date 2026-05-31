fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios test

```sh
[bundle exec] fastlane ios test
```

Run unit tests

### ios screenshots

```sh
[bundle exec] fastlane ios screenshots
```

Generate App Store screenshots (iPhone + iPad)

### ios prepare_screenshot_folders

```sh
[bundle exec] fastlane ios prepare_screenshot_folders
```

Copy generated screenshots into deliver folders (iphone65 + ipadPro129)

### ios bump_build

```sh
[bundle exec] fastlane ios bump_build
```

Increment build number from latest TestFlight build

### ios build_release

```sh
[bundle exec] fastlane ios build_release
```

Build Release IPA

### ios beta

```sh
[bundle exec] fastlane ios beta
```

Upload build to TestFlight

### ios privacy

```sh
[bundle exec] fastlane ios privacy
```

Upload App Privacy nutrition labels to App Store Connect

### ios exclude_china

```sh
[bundle exec] fastlane ios exclude_china
```

Remove China mainland from App Store availability

### ios submit_review

```sh
[bundle exec] fastlane ios submit_review
```

Upload build 4 IPA, metadata, and submit for App Review (skip screenshot re-upload)

### ios resubmit_review

```sh
[bundle exec] fastlane ios resubmit_review
```

Build, upload screenshots/metadata, exclude China, and submit for App Review

### ios release

```sh
[bundle exec] fastlane ios release
```

Upload metadata + screenshots and submit for App Review

### ios metadata

```sh
[bundle exec] fastlane ios metadata
```

Upload metadata and screenshots only (no review submission)

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
