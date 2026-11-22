const express = require('express');
const router = express.Router();
const {
  register,
  login,
  getMe,
  updateMe,
} = require('../controllers/authController');
const { protect } = require('../middleware/auth');
const {
  registerValidation,
  loginValidation,
  profileUpdateValidation,
  validate,
} = require('../middleware/validate');

router.post('/register', registerValidation, validate, register);
router.post('/login', loginValidation, validate, login);
router.get('/me', protect, getMe);
router.patch('/me', protect, profileUpdateValidation, validate, updateMe);

module.exports = router;
