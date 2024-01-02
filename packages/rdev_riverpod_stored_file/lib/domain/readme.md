# Domain Layer for Authentication Feature

This layer is responsible for defining data for presentation/application layer. It usually contains models/VOs required for this feature.

### Rules

- Every VO ends with \_vo.dart
- Every model ends with \_model.dart
- Every model extends Model<T> where T is protobuf defined interface
- Every model contains methods to convert from/to protobuf, validate, construct from json, etc.
