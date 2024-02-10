# Presentation layer

This layer is responsible for the presentation of the RdevRiverpodStoredFile feature. It directly communicates with data layer - repository.

## Rules

- try to structure presentation layer in a way that it is easy to understand and navigate, for example move pages, forms, widgets to separate folders.
- make sure that name of the file reflects class you extending from
- unless its really necessary (ie ask first), try to avoid creating statefull widgets, if you need to keep state use ConsumerWidget (check pages for example) and create state using Riverpod pattern (\_controller.dart file)

### Widgets (dumb)

- I call them dumb widgets, because they should only think about themselves and know nothing about the rest of the app
- they should use parameters (or VOs) and callbacks to communicate with the rest of the app
- they should not have any state
- they should not have any magic numbers/constants
- they should be localized
- they should be tested
- if you plan to reuse them more then twice, consider moving them to `UI` feature

### Pages

- should always extend `ConsumerWidget` class
- should define `controller` logic in separate file using `Riverpod` pattern
- should keep `controller` and `state` access in `build` method
- every `action` from UI should be handled in `controller` and not in `build` method
- ideally we should not use other `Riverpod` provider in `build` method, BUT I am flexible with it, as long as it make sense. (not related to feature, and it should not be handled by REPO)
