# Data layer for Authentication Feature

This layer is responsible for consuming business logic from Application layer, handling it in meaningful way for presentation layer and to keep state of feature itself.
Its also responsible for handling errors, long running tasks and to provide data to presentation layer.

## Rules

- This layer should inject services from Application layer AND/OR other repositories from other features.
- All injected services/repositories must stay private
- Each repo MUST contain static method `provider` that returns the repo instance with all underlaying dependencies injected via Riverpod
- Ideally methods should NOT return result, rather update state of the repository
- Presentation layer makes decisions on what part of state it is interested in and what part it is not
