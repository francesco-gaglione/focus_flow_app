import 'package:flutter/material.dart';

import 'counter_view.dart';

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    // In this case, we're using a global CounterBloc.
    // If you wanted to use a page-level CounterBloc, you would wrap the CounterView with a BlocProvider.
    return const CounterView();
  }
}
