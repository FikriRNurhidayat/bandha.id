abstract class DatabaseManager<T> {
  Future<void> connect();
  Future<void> disconnect();
  Future<void> reconnect();
  Future<T> getInstance();
}
