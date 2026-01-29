import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

/// Encryption & Security Utilities
/// Helper methods for encryption, hashing, and security
class EncryptionUtils {
  EncryptionUtils._();

  // ==================== Hashing ====================

  /// Generate MD5 hash
  static String md5Hash(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }

  /// Generate SHA-1 hash
  static String sha1Hash(String input) {
    return sha1.convert(utf8.encode(input)).toString();
  }

  /// Generate SHA-256 hash
  static String sha256Hash(String input) {
    return sha256.convert(utf8.encode(input)).toString();
  }

  /// Generate SHA-512 hash
  static String sha512Hash(String input) {
    return sha512.convert(utf8.encode(input)).toString();
  }

  /// Generate HMAC-SHA256
  static String hmacSha256(String input, String secret) {
    final key = utf8.encode(secret);
    final bytes = utf8.encode(input);
    final hmac = Hmac(sha256, key);
    return hmac.convert(bytes).toString();
  }

  // ==================== AES Encryption ====================

  /// Encrypt string using AES
  static String aesEncrypt(String plainText, String key) {
    final keyBytes = encrypt.Key.fromUtf8(key.padRight(32, '0').substring(0, 32));
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(keyBytes));
    
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return encrypted.base64;
  }

  /// Decrypt string using AES
  static String aesDecrypt(String encryptedText, String key) {
    final keyBytes = encrypt.Key.fromUtf8(key.padRight(32, '0').substring(0, 32));
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(keyBytes));
    
    final decrypted = encrypter.decrypt64(encryptedText, iv: iv);
    return decrypted;
  }

  /// Encrypt with custom IV
  static Map<String, String> aesEncryptWithIV(String plainText, String key) {
    final keyBytes = encrypt.Key.fromUtf8(key.padRight(32, '0').substring(0, 32));
    final iv = encrypt.IV.fromSecureRandom(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(keyBytes));
    
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    
    return {
      'encrypted': encrypted.base64,
      'iv': iv.base64,
    };
  }

  /// Decrypt with custom IV
  static String aesDecryptWithIV(
    String encryptedText,
    String key,
    String ivBase64,
  ) {
    final keyBytes = encrypt.Key.fromUtf8(key.padRight(32, '0').substring(0, 32));
    final iv = encrypt.IV.fromBase64(ivBase64);
    final encrypter = encrypt.Encrypter(encrypt.AES(keyBytes));
    
    final decrypted = encrypter.decrypt64(encryptedText, iv: iv);
    return decrypted;
  }

  // ==================== Base64 Encoding ====================

  /// Encode string to Base64
  static String base64Encode(String input) {
    return base64.encode(utf8.encode(input));
  }

  /// Decode Base64 string
  static String base64Decode(String encoded) {
    return utf8.decode(base64.decode(encoded));
  }

  /// Encode bytes to Base64
  static String base64EncodeBytes(Uint8List bytes) {
    return base64.encode(bytes);
  }

  /// Decode Base64 to bytes
  static Uint8List base64DecodeToBytes(String encoded) {
    return base64.decode(encoded);
  }

  // ==================== Random Generation ====================

  /// Generate secure random string
  static String generateRandomString(
    int length, {
    bool includeUppercase = true,
    bool includeLowercase = true,
    bool includeNumbers = true,
    bool includeSpecialChars = false,
  }) {
    const uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const lowercase = 'abcdefghijklmnopqrstuvwxyz';
    const numbers = '0123456789';
    const specialChars = '!@#\$%^&*()_+-=[]{}|;:,.<>?';

    var chars = '';
    if (includeUppercase) chars += uppercase;
    if (includeLowercase) chars += lowercase;
    if (includeNumbers) chars += numbers;
    if (includeSpecialChars) chars += specialChars;

    if (chars.isEmpty) chars = lowercase;

    final random = Random.secure();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)])
        .join();
  }

  /// Generate random bytes
  static Uint8List generateRandomBytes(int length) {
    final random = Random.secure();
    return Uint8List.fromList(
      List.generate(length, (index) => random.nextInt(256)),
    );
  }

  /// Generate random integer
  static int generateRandomInt(int min, int max) {
    final random = Random.secure();
    return min + random.nextInt(max - min);
  }

  /// Generate UUID-like string
  static String generateUUID() {
    final random = Random.secure();
    final bytes = List.generate(16, (index) => random.nextInt(256));
    
    bytes[6] = (bytes[6] & 0x0f) | 0x40; // Version 4
    bytes[8] = (bytes[8] & 0x3f) | 0x80; // Variant

    return [
      bytes.sublist(0, 4),
      bytes.sublist(4, 6),
      bytes.sublist(6, 8),
      bytes.sublist(8, 10),
      bytes.sublist(10, 16),
    ]
        .map((part) => part.map((b) => b.toRadixString(16).padLeft(2, '0')).join())
        .join('-');
  }

  // ==================== Password Hashing ====================

  /// Generate password hash (using SHA-256 with salt)
  static String hashPassword(String password, {String? salt}) {
    final saltToUse = salt ?? generateRandomString(16);
    final combined = password + saltToUse;
    final hashed = sha256Hash(combined);
    return '$saltToUse:$hashed';
  }

  /// Verify password against hash
  static bool verifyPassword(String password, String hashedPassword) {
    final parts = hashedPassword.split(':');
    if (parts.length != 2) return false;

    final salt = parts[0];
    final hash = parts[1];
    final combined = password + salt;
    final newHash = sha256Hash(combined);

    return hash == newHash;
  }

  // ==================== Token Generation ====================

  /// Generate random token (URL-safe)
  static String generateToken(int length) {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_';
    final random = Random.secure();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)])
        .join();
  }

  /// Generate API key
  static String generateAPIKey() {
    return generateToken(32);
  }

  /// Generate OTP (One-Time Password)
  static String generateOTP(int length) {
    final random = Random.secure();
    return List.generate(length, (index) => random.nextInt(10).toString()).join();
  }

  // ==================== Data Masking ====================

  /// Mask string (show only first and last n characters)
  static String maskString(
    String input, {
    int visibleStart = 2,
    int visibleEnd = 2,
    String maskChar = '*',
  }) {
    if (input.length <= visibleStart + visibleEnd) {
      return input;
    }

    final start = input.substring(0, visibleStart);
    final end = input.substring(input.length - visibleEnd);
    final masked = maskChar * (input.length - visibleStart - visibleEnd);

    return '$start$masked$end';
  }

  /// Mask email
  static String maskEmail(String email) {
    if (!email.contains('@')) return email;

    final parts = email.split('@');
    final username = parts[0];
    final domain = parts[1];

    final maskedUsername = maskString(username, visibleStart: 1, visibleEnd: 0);
    return '$maskedUsername@$domain';
  }

  /// Mask phone number
  static String maskPhone(String phone) {
    return maskString(phone, visibleStart: 0, visibleEnd: 4);
  }

  /// Mask credit card
  static String maskCreditCard(String cardNumber) {
    final cleaned = cardNumber.replaceAll(RegExp(r'\s'), '');
    return '**** **** **** ${cleaned.substring(cleaned.length - 4)}';
  }
}

/// Secure Storage Helper (for sensitive data)
class SecureDataHelper {
  SecureDataHelper._();

  static const String _encryptionKey = 'your-32-character-secret-key-here';

  /// Encrypt and store sensitive data
  static String encryptData(String data) {
    return EncryptionUtils.aesEncrypt(data, _encryptionKey);
  }

  /// Decrypt stored sensitive data
  static String decryptData(String encryptedData) {
    return EncryptionUtils.aesDecrypt(encryptedData, _encryptionKey);
  }

  /// Encrypt with custom key
  static String encryptWithKey(String data, String key) {
    return EncryptionUtils.aesEncrypt(data, key);
  }

  /// Decrypt with custom key
  static String decryptWithKey(String encryptedData, String key) {
    return EncryptionUtils.aesDecrypt(encryptedData, key);
  }
}