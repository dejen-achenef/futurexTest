const express = require('express');
const router = express.Router();
const videoController = require('../controllers/videoController');
const { authenticateToken } = require('../middleware/auth');
const { optionalAuth } = require('../middleware/optionalAuth');
const { validateCreateVideo } = require('../validators/videoValidator');

router.post('/', authenticateToken, validateCreateVideo, videoController.createVideo.bind(videoController));
router.get('/', optionalAuth, videoController.getVideos.bind(videoController));
router.get('/:id', videoController.getVideoById.bind(videoController));
router.put('/:id', authenticateToken, videoController.updateVideo.bind(videoController));
router.delete('/:id', authenticateToken, videoController.deleteVideo.bind(videoController));
router.post('/:id/hide', authenticateToken, videoController.hideVideo.bind(videoController));
router.delete('/:id/hide', authenticateToken, videoController.unhideVideo.bind(videoController));

module.exports = router;

