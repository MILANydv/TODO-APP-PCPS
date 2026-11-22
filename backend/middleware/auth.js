const jwt = require('jsonwebtoken');
const AppError = require('../utils/AppError');
const { findUserById } = require('../models/store');

/**
 * Authentication middleware.
 * Expects Authorization: Bearer <token>
 * Attaches req.user with { id }
 */
const protect = (req, res, next) => {
  let token;

  if (
    req.headers.authorization &&
    req.headers.authorization.startsWith('Bearer')
  ) {
    token = req.headers.authorization.split(' ')[1];
  }

  if (!token) {
    return next(new AppError('Not authorized, no token', 401));
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const user = findUserById(decoded.id);
    if (!user) {
      return next(new AppError('User not found', 401));
    }
    req.user = { id: user.id, email: user.email, name: user.name };
    next();
  } catch (err) {
    return next(new AppError('Not authorized, token failed', 401));
  }
};

module.exports = { protect };
