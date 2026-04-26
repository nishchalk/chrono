import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'sort_mode.dart';

final sortModeProvider = StateProvider<SortMode>((ref) => SortMode.closestUpcoming);
