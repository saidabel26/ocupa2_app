import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../constants/api_constants.dart';
import '../http/api_client.dart';

/// Resultado de una subida de imagen
class UploadResult {
  final String key;
  final String url;
  final String mime;
  final int size;

  const UploadResult({
    required this.key,
    required this.url,
    required this.mime,
    required this.size,
  });

  factory UploadResult.fromJson(Map<String, dynamic> json) {
    return UploadResult(
      key: json['key'] as String? ?? '',
      url: json['url'] as String? ?? '',
      mime: json['mime'] as String? ?? '',
      size: json['size'] as int? ?? 0,
    );
  }
}

/// Servicio reutilizable para subir imágenes al API.
/// Acepta un [XFile] (de image_picker) o un [File] nativo.
/// Convierte la imagen a base64 y la envía a POST /uploads.
class UploadService {
  final ApiClient _client;

  UploadService(this._client);

  /// Sube un [XFile] (resultado de image_picker) y devuelve la URL pública.
  Future<UploadResult> uploadXFile(XFile xFile, {String? filename}) async {
    final bytes = await xFile.readAsBytes();
    final ext = xFile.path.split('.').last.toLowerCase();
    final mime = _mimeFromExt(ext);
    final dataUri = 'data:$mime;base64,${base64Encode(bytes)}';

    return _upload(dataUri, filename: filename ?? xFile.name);
  }

  /// Sube un [File] nativo y devuelve la URL pública.
  Future<UploadResult> uploadFile(File file, {String? filename}) async {
    final bytes = await file.readAsBytes();
    final ext = file.path.split('.').last.toLowerCase();
    final mime = _mimeFromExt(ext);
    final dataUri = 'data:$mime;base64,${base64Encode(bytes)}';
    final name = filename ?? file.path.split(Platform.pathSeparator).last;

    return _upload(dataUri, filename: name);
  }

  Future<UploadResult> _upload(String dataUri, {String? filename}) async {
    final body = <String, dynamic>{
      'image': dataUri,
      ?'filename': filename,
    };

    final response = await _client.post(
      ApiConstants.uploads,
      body: body,
    );

    final data = response['data'] as Map<String, dynamic>;
    return UploadResult.fromJson(data);
  }

  String _mimeFromExt(String ext) {
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      default:
        return 'image/jpeg';
    }
  }
}
