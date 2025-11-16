import '../entities/counter_value.dart';
import '../repositories/counter_repository.dart';

class GetCounter {
  final CounterRepository _repository;

  GetCounter(this._repository);

  Future<CounterValue> call() {
    return _repository.getCounter();
  }
}
