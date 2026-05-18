import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/router/app_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) => appRouter);
