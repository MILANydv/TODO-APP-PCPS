/**
 * Custom error class for operational errors.
 * statusCode: HTTP status code
 * isOperational: whether the error is expected (validation, not found, etc.)
 */
class AppError extends Error {
  constructor(message, statusCode) {
    super(message);
    this.statusCode = statusCode;
    this.isOperational = true;

    Error.captureStackTrace(this, this.constructor);
  }
}

module.exports = AppError;
