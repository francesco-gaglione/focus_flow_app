import 'package:focus_flow_app/domain/entities/counter_value.dart';
import 'package:focus_flow_app/domain/repositories/counter_repository.dart';

class InMemoryCounterRepositoryImpl implements CounterRepository {
  CounterValue _current = const CounterValue(0);

  @override
  Future<CounterValue> getCounter() async {
    // In a real case you might read from DB/local storage/API.
    return _current;
  }

  @override
  Future<CounterValue> saveCounter(CounterValue value) async {
    _current = value;
    return _current;
  }
}
