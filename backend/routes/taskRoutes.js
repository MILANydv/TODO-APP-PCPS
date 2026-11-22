const express = require('express');
const router = express.Router();
const {
  getTasks,
  createTask,
  updateTask,
  deleteTask,
} = require('../controllers/taskController');
const { protect } = require('../middleware/auth');
const { taskValidation, taskUpdateValidation, validate } = require('../middleware/validate');

router.get('/', protect, getTasks);
router.post('/', protect, taskValidation, validate, createTask);
router.patch('/:id', protect, taskUpdateValidation, validate, updateTask);
router.delete('/:id', protect, deleteTask);

module.exports = router;
