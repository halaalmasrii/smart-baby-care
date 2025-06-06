import '../models/child_data.dart';

class DatabaseService {
  Future<void> saveChildData(ChildData data) async {
    // Simulate saving data to database
  }

  Future<ChildData> getChildData() async {
    // Simulate fetching data from database
    return ChildData(name: 'Baby', age: 1, weight: 10.5, height: 75.0);
  }
}