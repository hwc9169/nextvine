import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

class FileUploadResponse {
  final String fileID;
  final String downloadURL;

  FileUploadResponse(this.fileID, this.downloadURL);
}

class FirebaseStorageRepository {
  final storage = FirebaseStorage.instanceFor(
          bucket: "gs://nextvine-b2705.firebasestorage.app")
      .ref("/scoliosis/videos");

  Future<FileUploadResponse> uploadFile(File file) async {
    final fileID =
        '${DateTime.now().millisecondsSinceEpoch}-${p.basename(file.path)}';

    final uploadTask = storage.child(fileID).putFile(file);
    final uploadTaskSnapshot = await uploadTask.whenComplete(() {});
    final downloadURL = await uploadTaskSnapshot.ref.getDownloadURL();

    return FileUploadResponse(fileID, downloadURL);
  }
}
