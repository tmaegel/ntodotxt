# Contribution

First of all, thank you for considering contributing to this project!

Whether you're fixing a bug, improving documentation, suggesting a feature, or submitting code, every contribution is appreciated. Every contribution, no matter how small, helps make ntodotxt better. Thank you for taking the time to contribute and for helping keep the project useful, maintainable, and open source!

This document explains how to contribute effectively and what to expect when working on this project.

## Before you start

Before investing time in a contribution, please:

- Check existing issues and pull requests to avoid duplicate work.
- Read the project documentation.
- For larger changes or new features, open an issue first to discuss your idea.
- Keep in mind that ntodotxt is maintained by a single maintainer in their spare time.

Please don't take a lack of immediate feedback personally. Reviews and responses may take some time.

## Ways to contribute

There are many ways to help:

- Bug reports: Report reproducible bugs and unexpected behavior.
- Feature requests: Suggest improvements and new functionality.
- Code contributions: Fix bugs, implement features, or improve existing code.
- Documentation: Improve explanations, examples, and setup instructions.
- Testing: Test new releases and report regressions.
- Feedback: Share your experience using ntodotxt.

Not every feature request will be implemented. The project's direction and priorities are ultimately determined by the maintainer.

## Reporting bugs

When reporting a bug, please provide as much relevant information as possible:

- A clear and descriptive title.
- Steps to reproduce the issue.
- What you expected to happen.
- What actually happened.
- Flutter and Dart versions.
- Device, operating system, and relevant environment details.
- Screenshots or logs, if applicable.

Please make sure the issue hasn't already been reported.

Avoid including personal information, passwords, private task data, or other sensitive information in bug reports.

## Suggesting features

Feature requests are welcome!

Please explain:

- What problem you are trying to solve.
- Why the feature would be useful.
- How you imagine it working.
- Whether there are alternative ways to achieve the same result.

A feature request is a proposal, not a commitment to implementation.

## Code Contributions

### General guidelines

Please follow these principles:

- Follow the existing Dart and Flutter coding conventions.
- Keep changes focused and reasonably small.
- Avoid unnecessary dependencies.
- Prefer readable and maintainable code over clever abstractions.
- Reuse existing patterns and components where appropriate.
- Avoid unrelated refactoring in feature or bug-fix pull requests.
- Consider backwards compatibility, especially regarding todo.txt file handling.
- Do not introduce breaking changes without discussing them first.

### Code quality

Before submitting a pull request, run the relevant checks:

```bash
flutter pub get
dart format .
flutter analyze
flutter test
```

Please resolve any new warnings, errors, or failing tests introduced by your changes.

If a test cannot reasonably be added, explain why in the pull request.

### Dependencies

New dependencies should be avoided unless they provide clear value.

If you want to introduce a new package, explain:

- Why it is needed.
- Why existing Flutter or Dart functionality is insufficient.
- Whether it is actively maintained.
- Its license and potential security implications.

The maintainer reserves the right to reject unnecessary dependencies.

## Pull requests

Before submitting a pull request:

- Make sure your branch is based on the latest relevant upstream changes.
- Ensure your changes are focused on a single issue or feature.
- Run formatting, analysis, and tests.
- Update documentation where necessary.
- Add or update tests where appropriate.

### Pull request description

Please include:

- A short description of the changes.
- The problem being solved.
- Steps to test the changes.
- Screenshots for UI changes, if applicable.
- Relevant issue references.

Keep pull requests as small and understandable as possible.

### Review process

Please understand that this project is maintained by a single person.

- Reviews may take time.
- Feedback may require changes before a PR can be merged.
- A PR may be closed if it is outside the project's scope or direction.
- The maintainer may request simplifications or alternative implementations.
- Submitting a PR does not guarantee that it will be merged.

Please be respectful during the review process. Technical disagreements are perfectly fine; personal attacks are not.

## AI-Assisted contributions

AI tools, including code assistants and large language models (LLMs), may be used when contributing to this project.

However, using AI does not change the expectations for contributions.

You may use AI tools to:

- Help understand unfamiliar code.
- Suggest implementations or refactorings.
- Generate boilerplate code.
- Help write or improve tests.
- Improve documentation and comments.
- Assist with debugging.
- Review your own changes.

If you use AI-generated or AI-assisted code, you must:

- Understand the submitted code and be able to explain how it works.
- Review every generated change before submitting it.
- Verify that the code actually works.
- Run formatting, static analysis, and relevant tests.
- Check for security issues, performance problems, and unintended side effects.
- Ensure that generated code does not introduce incompatible or unnecessary dependencies.
- Ensure that the contribution does not violate third-party copyrights, licenses, or other legal obligations.
- Verify that generated documentation and comments are accurate.

Do not submit code that you cannot understand or adequately maintain.

AI-generated pull requests are welcome only when they meet the same quality standards as any other contribution.

In particular:

- Do not submit large, unreviewed AI-generated changes.
- Do not generate pull requests simply to increase contribution activity.
- Do not submit speculative refactorings without a clear benefit.
- Do not blindly accept AI-generated suggestions.
- Do not use AI as a substitute for testing or understanding the project.
