const { body, validationResult } = require('express-validator');

/**
 * Register validation rules
 */
const registerValidation = [
  body('name')
    .trim()
    .notEmpty()
    .withMessage('Name is required')
    .isLength({ max: 50 })
    .withMessage('Name must be under 50 chars'),
  body('email')
    .normalizeEmail()
    .isEmail()
    .withMessage('Please enter a valid email'),
  body('password')
    .isLength({ min: 6 })
    .withMessage('Password must be at least 6 characters'),
];

/**
 * Login validation rules
 */
const loginValidation = [
  body('email').normalizeEmail().isEmail().withMessage('Please enter a valid email'),
  body('password').notEmpty().withMessage('Password is required'),
];

/**
 * Task validation rules (create) - title required
 */
const taskValidation = [
  body('title')
    .trim()
    .notEmpty()
    .withMessage('Title is required')
    .isLength({ max: 100 })
    .withMessage('Title must be under 100 chars'),
  body('description')
    .optional()
    .isLength({ max: 500 })
    .withMessage('Description must be under 500 chars'),
  body('isCompleted')
    .optional()
    .isBoolean()
    .withMessage('isCompleted must be a boolean'),
];

/**
 * Task update validation rules (patch) - all fields optional
 */
const taskUpdateValidation = [
  body('title')
    .optional()
    .trim()
    .notEmpty()
    .withMessage('Title cannot be empty')
    .isLength({ max: 100 })
    .withMessage('Title must be under 100 chars'),
  body('description')
    .optional()
    .isLength({ max: 500 })
    .withMessage('Description must be under 500 chars'),
  body('isCompleted')
    .optional()
    .isBoolean()
    .withMessage('isCompleted must be a boolean'),
];

/**
 * Profile update validation rules (patch) - all fields optional
 */
const profileUpdateValidation = [
  body('name')
    .optional()
    .trim()
    .notEmpty()
    .withMessage('Name cannot be empty')
    .isLength({ max: 50 })
    .withMessage('Name must be under 50 chars'),
  body('email')
    .optional()
    .normalizeEmail()
    .isEmail()
    .withMessage('Please enter a valid email'),
];

/**
 * Express-validator result handler: sends 400 if validation fails.
 */
const validate = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({
      success: false,
      message: 'Validation failed',
      errors: errors.array().map((e) => ({ field: e.param, message: e.msg })),
    });
  }
  next();
};

module.exports = {
  registerValidation,
  loginValidation,
  taskValidation,
  taskUpdateValidation,
  profileUpdateValidation,
  validate,
};
