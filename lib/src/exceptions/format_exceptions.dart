// CUSTOM EXCEPTION CLASS TO HANLDE VARIOUS FORMAT-RELATED  ERRORS
class CommonFormatExceptions implements Exception {
  // the errror code associated with the exception
  final String message;

  // Default constructot with a generic message
  const CommonFormatExceptions(
      [this.message =
          'An unexpected format error occurred. Please check your input.']);

  factory CommonFormatExceptions.fromMessage(String message) {
    return CommonFormatExceptions(message);
  }
  // get the corresponding error message
  String get formattedMessage => message;
  factory CommonFormatExceptions.fromCode(String code) {
    switch (code) {
      case 'invalid-email-format':
        return const CommonFormatExceptions(
            'The email address format is invalid. Please enter a valid email');

      case 'invalid-phone-number-format':
        return const CommonFormatExceptions(
            'The provided phone nunmber format is invalid. Please enter a valid number');
      case 'invalid-date-format':
        return const CommonFormatExceptions(
            'The date format is invalid. Please enter a valid date');
      case 'invalid-url-format':
        return const CommonFormatExceptions(
            'The URL format is invalid. Please enter a valid URL');
      case 'invalid-credit-card-format':
        return const CommonFormatExceptions(
            'The credit card format is invalid. PLease enter a valid credit card number');
      case 'invalid numeric-format':
        return const CommonFormatExceptions(
            'The input should be a valid numeric format');

      default:
        return const CommonFormatExceptions(
            'Invalid format. please use corrrect formatting');
    }
  }
}
