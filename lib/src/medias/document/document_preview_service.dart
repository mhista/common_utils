
// ─────────────────────────────────────────────────────────────────────────────
// FILE: document/document_preview_service.dart
// Generates thumbnails for PDFs and documents.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// import 'package:pdf_render/pdf_render.dart';

class DocumentPreviewService {
  static final DocumentPreviewService _instance = DocumentPreviewService._();
  factory DocumentPreviewService() => _instance;
  DocumentPreviewService._();

  final _cacheManager = DefaultCacheManager();
  final Map<String, Uint8List> _thumbnailCache = {};

  /// Generate thumbnail for a document URL
  Future<Uint8List?> generateThumbnail(String documentUrl) async {
    // Check memory cache
    if (_thumbnailCache.containsKey(documentUrl)) {
      return _thumbnailCache[documentUrl];
    }

    try {
      // Download document
      final file = await _cacheManager.getSingleFile(documentUrl);

      // Generate thumbnail based on file type
      if (_isPdf(file.path)) {
        final thumbnail = await _generatePdfThumbnail(file);
        if (thumbnail != null) {
          _thumbnailCache[documentUrl] = thumbnail;
        }
        return thumbnail;
      } else {
        // For other document types, return a generic icon
        return null;
      }
    } catch (e) {
      debugPrint('Failed to generate thumbnail for $documentUrl: $e');
      return null;
    }
  }

  Future<Uint8List?> _generatePdfThumbnail(File pdfFile) async {
    // try {
    //   final document = await pdfFile.open(pdfFile.path);
    //   final page = await document.getPage(1); // First page
    //   final pageImage = await page.render(
    //     width: 200,
    //     height: 200,
    //     format: PdfPageImageFormat.png,
    //   );
    //   await page.close();
    //   await document.dispose();
    //   return pageImage?.bytes;
    // } catch (e) {
    //   debugPrint('PDF thumbnail generation failed: $e');
    //   return null;
    // }
    return null;
  }

  bool _isPdf(String path) => path.toLowerCase().endsWith('.pdf');

  void clearCache() {
    _thumbnailCache.clear();
  }
}
