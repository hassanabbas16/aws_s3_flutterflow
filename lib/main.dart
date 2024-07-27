import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

const String bucketName = '***YOUR_BUCKET***';
const String region = '***YOUR_REGION';
const int partSize = 100 * 1024 * 1024; //100MBs per Chunk. Can be increased or decreased.

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter S3 Upload',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  Future<void> s3uploadFunc() async {
    print('Starting file picker...');
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result == null || result.files.isEmpty) {
      print('No file selected');
      return;
    }

    PlatformFile platformFile = result.files.first;
    print('File name: ${platformFile.name}');
    final filer = platformFile.name;
    print('File path: ${platformFile.path}');

    String? filePath = platformFile.path;
    if (filePath == null) {
      print('File path is null.');
      return;
    }

    print("Key made: $filer");

    // Create a File object from the filePath
    final file = File(filePath);
    Uint8List fileBytes;
    try {
      fileBytes = await file.readAsBytes();
      print('File bytes length: ${fileBytes.length}');
    } catch (e) {
      print('Error reading file from path: $e');
      return;
    }

    final String key = '$filer';
    print('Initiating multipart upload...');
    final responseInitiate = await http.post(
      Uri.parse('https://us-central1-missioncontroluploads.cloudfunctions.net/api/initiate-multipart-upload'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'key': key}),
    );

    if (responseInitiate.statusCode != 200) {
      print('Failed to initiate multipart upload');
      return;
    }

    final String uploadId = json.decode(responseInitiate.body)['UploadId'];
    print('UploadId received: $uploadId');

    final List<Map<String, dynamic>> parts = [];
    for (int i = 0; i < fileBytes.length; i += partSize) {
      final partBytes = fileBytes.sublist(
          i, i + partSize > fileBytes.length ? fileBytes.length : i + partSize);

      print('Getting pre-signed URL for part ${i ~/ partSize + 1}...');
      final responsePresignedUrl = await http.post(
        Uri.parse('https://us-central1-missioncontroluploads.cloudfunctions.net/api/generate-presigned-url'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'key': key,
          'partNumber': i ~/ partSize + 1,
          'uploadId': uploadId,
        }),
      );

      if (responsePresignedUrl.statusCode != 200) {
        print('Failed to get pre-signed URL');
        return;
      }

      final String presignedUrl = json.decode(responsePresignedUrl.body)['url'];
      print('Uploading part ${i ~/ partSize + 1}...');
      final responseUploadPart = await http.put(
        Uri.parse(presignedUrl),
        headers: {'Content-Length': partBytes.length.toString()},
        body: partBytes,
      );

      if (responseUploadPart.statusCode != 200) {
        print('Failed to upload part ${i ~/ partSize + 1}');
        return;
      }

      parts.add({
        'ETag': responseUploadPart.headers['etag'],
        'PartNumber': i ~/ partSize + 1,
      });

      print('Part ${i ~/ partSize + 1} uploaded successfully');
    }

    print('Completing multipart upload...');
    final responseComplete = await http.post(
      Uri.parse('https://us-central1-missioncontroluploads.cloudfunctions.net/api/complete-multipart-upload'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'key': key,
        'uploadId': uploadId,
        'parts': parts,
      }),
    );

    if (responseComplete.statusCode != 200) {
      print('Failed to complete multipart upload');
      return;
    }

    print('File uploaded successfully.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter S3 Upload'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: s3uploadFunc,
          child: Text('Upload File'),
        ),
      ),
    );
  }
}

//FLUTTERFLOW CODE.
/*// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

const String bucketName = 'gw-testbucket';
const String region = 'us-east-1';
const int partSize = 50 * 1024 * 1024; // 50MB per chunk. Can be increased.

Future<void> s3uploadFunc(BuildContext context, String folderName, String filename) async {
  print('Starting file picker...');
  FilePickerResult? result = await FilePicker.platform.pickFiles();

  if (result == null || result.files.isEmpty) {
    print('No file selected');
    return;
  }

  PlatformFile platformFile = result.files.first;
  print('Selected file name: ${platformFile.name}');

  Uint8List? fileBytes = platformFile.bytes;
  if (fileBytes == null) {
    print('File bytes are null.');
    return;
  }

  print('File bytes length: ${fileBytes.length}');

  // Get the file extension
  String fileExtension = path.extension(platformFile.name);
  if (!filename.endsWith(fileExtension)) {
    filename += fileExtension;
  }

  // Construct the key using folder name and filename
  final String key = '$folderName/$filename';

  print('Initiating multipart upload with key: $key');
  final responseInitiate = await http.post(
    Uri.parse(
        'https://YOUR_API_URL/initiate-multipart-upload'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({'key': key}),
  );

  if (responseInitiate.statusCode != 200) {
    print('Failed to initiate multipart upload');
    return;
  }

  final String uploadId = json.decode(responseInitiate.body)['UploadId'];
  print('UploadId received: $uploadId');

  final List<Map<String, dynamic>> parts = [];
  for (int i = 0; i < fileBytes.length; i += partSize) {
    final partBytes = fileBytes.sublist(
        i, i + partSize > fileBytes.length ? fileBytes.length : i + partSize);

    print('Getting pre-signed URL for part ${i ~/ partSize + 1}...');
    final responsePresignedUrl = await http.post(
      Uri.parse(
          'https://YOUR_API_URL/generate-presigned-url'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'key': key,
        'partNumber': i ~/ partSize + 1,
        'uploadId': uploadId,
      }),
    );

    if (responsePresignedUrl.statusCode != 200) {
      print('Failed to get pre-signed URL');
      return;
    }

    final String presignedUrl = json.decode(responsePresignedUrl.body)['url'];
    print('Uploading part ${i ~/ partSize + 1}...');
    final responseUploadPart = await http.put(
      Uri.parse(presignedUrl),
      body: partBytes,
    );

    if (responseUploadPart.statusCode != 200) {
      print('Failed to upload part ${i ~/ partSize + 1}');
      return;
    }

    parts.add({
      'ETag': responseUploadPart.headers['etag'],
      'PartNumber': i ~/ partSize + 1,
    });

    print('Part ${i ~/ partSize + 1} uploaded successfully');
  }

  print('Completing multipart upload...');
  final responseComplete = await http.post(
    Uri.parse(
        'https://YOUR_API_URL/complete-multipart-upload'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'key': key,
      'uploadId': uploadId,
      'parts': parts,
    }),
  );

  if (responseComplete.statusCode != 200) {
    print('Failed to complete multipart upload');
    return;
  }

  print('File uploaded successfully.');
}
*/





