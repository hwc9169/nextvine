import 'package:flutter_test/flutter_test.dart';

void main() {
  test('bucket name is HELLO WORLD from environment', () {
    const bucketName = String.fromEnvironment('GCP_BUCKET_NAME');
    expect(bucketName, equals('HELLO WORLD'));
  });
}
