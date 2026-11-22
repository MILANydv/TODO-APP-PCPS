const asyncHandler = require('../utils/asyncHandler');
const AppError = require('../utils/AppError');
const {
  getTasksByUser,
  createTask,
  updateTask,
  deleteTask,
} = require('../models/store');

/**
 * GET /api/tasks
 */
const getTasks = asyncHandler(async (req, res) => {
  const tasks = getTasksByUser(req.user.id);
  res.json({
    success: true,
    count: tasks.length,
    data: tasks,
  });
});

/**
 * POST /api/tasks
 */
const createTaskCtrl = asyncHandler(async (req, res) => {
  const { title, description } = req.body;

  const task = createTask({
    userId: req.user.id,
    title,
    description: description || '',
    isCompleted: false,
    createdAt: new Date().toISOString(),
  });

  res.status(201).json({
    success: true,
    data: task,
  });
});

/**
 * PATCH /api/tasks/:id
 */
const updateTaskCtrl = asyncHandler(async (req, res, next) => {
  const id = parseInt(req.params.id, 10);
  const task = updateTask(id, req.user.id, req.body);
  if (!task) {
    return next(new AppError('Task not found', 404));
  }

  res.json({
    success: true,
    data: task,
  });
});

/**
 * DELETE /api/tasks/:id
 */
const deleteTaskCtrl = asyncHandler(async (req, res, next) => {
  const id = parseInt(req.params.id, 10);
  const deleted = deleteTask(id, req.user.id);
  if (!deleted) {
    return next(new AppError('Task not found', 404));
  }

  res.json({
    success: true,
    message: 'Task deleted',
  });
});

module.exports = {
  getTasks,
  createTask: createTaskCtrl,
  updateTask: updateTaskCtrl,
  deleteTask: deleteTaskCtrl,
};
