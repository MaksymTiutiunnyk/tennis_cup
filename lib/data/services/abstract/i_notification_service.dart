abstract interface class INotificationService {
  Future<void> registerDevice({required String token, required String platform});
  Future<void> deleteDevice(String token);
}
