const bcrypt = require('bcryptjs');
const { generateToken } = require('../services/tokenService');
const asyncHandler = require('../utils/asyncHandler');
const AppError = require('../utils/AppError');
const {
  findUserByEmail,
  findUserById,
  createUser,
  updateUser,
} = require('../models/store');

/**
 * POST /api/auth/register
 */
const register = asyncHandler(async (req, res) => {
  const { name, email, password } = req.body;

  const userExists = findUserByEmail(email);
  if (userExists) {
    return res.status(400).json({
      success: false,
      message: 'User already exists',
    });
  }

  const salt = await bcrypt.genSalt(10);
  const hashedPassword = await bcrypt.hash(password, salt);

  const user = createUser({
    id: String(Date.now()),
    name,
    email,
    password: hashedPassword,
    createdAt: new Date().toISOString(),
  });

  const token = generateToken(user.id);

  res.status(201).json({
    success: true,
    token,
    user: {
      id: user.id,
      name: user.name,
      email: user.email,
    },
  });
});

/**
 * POST /api/auth/login
 */
const login = asyncHandler(async (req, res) => {
  const { email, password } = req.body;

  const user = findUserByEmail(email);
  if (!user) {
    return res.status(401).json({
      success: false,
      message: 'Invalid email or password',
    });
  }

  const isMatch = await bcrypt.compare(password, user.password);
  if (!isMatch) {
    return res.status(401).json({
      success: false,
      message: 'Invalid email or password',
    });
  }

  const token = generateToken(user.id);

  res.json({
    success: true,
    token,
    user: {
      id: user.id,
      name: user.name,
      email: user.email,
    },
  });
});

/**
 * GET /api/auth/me
 * Returns the currently logged-in user
 */
const getMe = asyncHandler(async (req, res) => {
  const user = findUserById(req.user.id);
  if (!user) {
    throw new AppError('User not found', 404);
  }

  res.json({
    success: true,
    user: {
      id: user.id,
      name: user.name,
      email: user.email,
    },
  });
});

/**
 * PATCH /api/auth/me
 * Updates the currently logged-in user's name and/or email.
 */
const updateMe = asyncHandler(async (req, res, next) => {
  const { name, email } = req.body;
  const userId = req.user.id;

  // If email is being changed, ensure it's not already taken.
  if (email) {
    const existing = findUserByEmail(email);
    if (existing && existing.id !== userId) {
      return res.status(400).json({
        success: false,
        message: 'Email is already in use',
      });
    }
  }

  const updated = updateUser(userId, {
    ...(name !== undefined ? { name } : {}),
    ...(email !== undefined ? { email } : {}),
  });

  if (!updated) {
    return next(new AppError('User not found', 404));
  }

  res.json({
    success: true,
    user: {
      id: updated.id,
      name: updated.name,
      email: updated.email,
    },
  });
});

module.exports = { register, login, getMe, updateMe };
