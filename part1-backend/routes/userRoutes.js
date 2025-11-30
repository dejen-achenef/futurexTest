const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const { authenticateToken } = require('../middleware/auth');
const { validateUpdateUser } = require('../validators/userValidator');
const upload = require('../middleware/upload');

router.get('/', authenticateToken, userController.getAllUsers.bind(userController));
router.get('/:id', authenticateToken, userController.getUserById.bind(userController));
router.put('/:id', authenticateToken, validateUpdateUser, upload.single('avatar'), userController.updateUser.bind(userController));
router.delete('/:id', authenticateToken, userController.deleteUser.bind(userController));

module.exports = router;

