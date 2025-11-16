import '../entities/counter_value.dart';
import '../repositories/counter_repository.dart';

class IncrementCounter {
  final CounterRepository _repository;

  IncrementCounter(this._repository);

  Future<CounterValue> call(CounterValue current) async {
    final next = CounterValue(current.value + 1);
    return _repository.saveCounter(next);
  }
}
