import '../entities/counter_value.dart';

abstract class CounterRepository {
  Future<CounterValue> getCounter();
  Future<CounterValue> saveCounter(CounterValue value);
}
