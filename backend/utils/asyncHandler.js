/**
 * Wraps async route handlers so rejections are forwarded to Express error middleware.
 * Usage: router.post('/', asyncHandler(async (req, res) => { ... }))
 */
const asyncHandler = (fn) => (req, res, next) => {
  Promise.resolve(fn(req, res, next)).catch(next);
};

module.exports = asyncHandler;
