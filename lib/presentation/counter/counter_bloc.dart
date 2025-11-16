import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/counter_value.dart';
import '../../domain/usecases/decrement_counter.dart';
import '../../domain/usecases/get_counter.dart';
import '../../domain/usecases/increment_counter.dart';

abstract class CounterEvent {}

class CounterStarted extends CounterEvent {}

class CounterIncrementPressed extends CounterEvent {}

class CounterDecrementPressed extends CounterEvent {}

class CounterState {
  final CounterValue value;
  final bool isLoading;

  const CounterState({required this.value, this.isLoading = false});

  CounterState copyWith({CounterValue? value, bool? isLoading}) {
    return CounterState(
      value: value ?? this.value,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  final GetCounter _getCounter;
  final IncrementCounter _incrementCounter;
  final DecrementCounter _decrementCounter;

  CounterBloc({
    required GetCounter getCounter,
    required IncrementCounter incrementCounter,
    required DecrementCounter decrementCounter,
  }) : _getCounter = getCounter,
       _incrementCounter = incrementCounter,
       _decrementCounter = decrementCounter,
       super(const CounterState(value: CounterValue(0), isLoading: true)) {
    on<CounterStarted>(_onStarted);
    on<CounterIncrementPressed>(_onIncrement);
    on<CounterDecrementPressed>(_onDecrement);
  }

  Future<void> loadCounter() async {
    add(CounterStarted());
  }

  Future<void> _onStarted(
    CounterStarted event,
    Emitter<CounterState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    final value = await _getCounter();
    emit(CounterState(value: value, isLoading: false));
  }

  Future<void> _onIncrement(
    CounterIncrementPressed event,
    Emitter<CounterState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    final updated = await _incrementCounter(state.value);
    emit(CounterState(value: updated, isLoading: false));
  }

  Future<void> _onDecrement(
    CounterDecrementPressed event,
    Emitter<CounterState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    final updated = await _decrementCounter(state.value);
    emit(CounterState(value: updated, isLoading: false));
  }
}
