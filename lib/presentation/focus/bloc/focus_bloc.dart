import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focus_flow_app/presentation/focus/bloc/focus_event.dart';
import 'package:focus_flow_app/presentation/focus/bloc/focus_state.dart';

class FocusBloc extends Bloc<FocusEvent, FocusState> {
  FocusBloc() : super(FocusState()) {}
}
