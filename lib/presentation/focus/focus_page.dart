import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focus_flow_app/presentation/focus/bloc/focus_bloc.dart';
import 'package:focus_flow_app/presentation/focus/focus_view.dart';

class FocusPage extends StatelessWidget {
  const FocusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => FocusBloc(), child: const FocusView());
  }
}
