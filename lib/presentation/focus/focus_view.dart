import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focus_flow_app/presentation/focus/bloc/focus_bloc.dart';
import 'package:focus_flow_app/presentation/focus/bloc/focus_state.dart';

class FocusView extends StatelessWidget {
  const FocusView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Focus')),
      body: BlocBuilder<FocusBloc, FocusState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
