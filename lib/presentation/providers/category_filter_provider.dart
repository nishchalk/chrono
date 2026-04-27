import 'package:flutter_riverpod/flutter_riverpod.dart';

/// `null` = show all categories.
final categoryFilterProvider = StateProvider<String?>((ref) => null);
