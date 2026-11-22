const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '../.env') });

/**
 * In-memory storage fallback when MongoDB is not configured.
 * Keeps the backend runnable out of the box.
 */
const users = [];
const tasks = [];
let nextTaskId = 1;

const findUserByEmail = (email) => users.find((u) => u.email === email);
const findUserById = (id) => users.find((u) => u.id === id);
const createUser = (user) => {
  users.push(user);
  return user;
};
const getTasksByUser = (userId) => tasks.filter((t) => t.userId === userId);
const createTask = (task) => {
  const newTask = { ...task, id: nextTaskId++ };
  tasks.push(newTask);
  return newTask;
};
const updateTask = (id, userId, updates) => {
  const idx = tasks.findIndex((t) => t.id === id && t.userId === userId);
  if (idx === -1) return null;
  tasks[idx] = { ...tasks[idx], ...updates, id, userId };
  return tasks[idx];
};

const updateUser = (id, updates) => {
  const idx = users.findIndex((u) => u.id === id);
  if (idx === -1) return null;
  users[idx] = { ...users[idx], ...updates, id };
  return users[idx];
};
const deleteTask = (id, userId) => {
  const idx = tasks.findIndex((t) => t.id === id && t.userId === userId);
  if (idx === -1) return false;
  tasks.splice(idx, 1);
  return true;
};
const clearAll = () => {
  users.length = 0;
  tasks.length = 0;
  nextTaskId = 1;
};

module.exports = {
  users,
  tasks,
  findUserByEmail,
  findUserById,
  createUser,
  updateUser,
  getTasksByUser,
  createTask,
  updateTask,
  deleteTask,
  clearAll,
};
