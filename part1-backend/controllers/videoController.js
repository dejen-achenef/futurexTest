const videoService = require('../services/videoService');

class VideoController {
  async createVideo(req, res) {
    try {
      const video = await videoService.createVideo(req.body, req.user.id);
      res.status(201).json({
        message: 'Video created successfully',
        video
      });
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

  async getVideos(req, res) {
    try {
      // Get userId from token if authenticated, otherwise null
      const userId = req.user ? req.user.id : null;
      const result = await videoService.getVideos(req.query, userId);
      res.json(result);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }

  async getVideoById(req, res) {
    try {
      const video = await videoService.getVideoById(req.params.id);
      res.json(video);
    } catch (error) {
      res.status(404).json({ error: error.message });
    }
  }

  async updateVideo(req, res) {
    try {
      const video = await videoService.updateVideo(
        req.params.id,
        req.body,
        req.user.id
      );
      res.json({
        message: 'Video updated successfully',
        video
      });
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

  async deleteVideo(req, res) {
    try {
      const result = await videoService.deleteVideo(req.params.id, req.user.id);
      res.json(result);
    } catch (error) {
      res.status(404).json({ error: error.message });
    }
  }

  async hideVideo(req, res) {
    try {
      const result = await videoService.hideVideo(req.params.id, req.user.id);
      res.json(result);
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }

  async unhideVideo(req, res) {
    try {
      const result = await videoService.unhideVideo(req.params.id, req.user.id);
      res.json(result);
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  }
}

module.exports = new VideoController();

