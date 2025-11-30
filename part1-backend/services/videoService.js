const { Video, User, HiddenVideo } = require('../models');
const { Op } = require('sequelize');

class VideoService {
  async createVideo(videoData, userId) {
    const video = await Video.create({
      ...videoData,
      userId
    });

    return await Video.findByPk(video.id, {
      include: [{
        model: User,
        as: 'user',
        attributes: ['id', 'name', 'email', 'avatar']
      }]
    });
  }

  async getVideos(query = {}, userId = null) {
    const { search, category, page = 1, limit = 10 } = query;
    const offset = (page - 1) * limit;

    const where = {};
    
    if (search) {
      where[Op.or] = [
        { title: { [Op.like]: `%${search}%` } },
        { description: { [Op.like]: `%${search}%` } }
      ];
    }

    if (category) {
      where.category = category;
    }

    // If user is authenticated, exclude videos they've hidden
    if (userId) {
      const hiddenVideoIds = await HiddenVideo.findAll({
        where: { userId },
        attributes: ['videoId']
      }).then(hidden => hidden.map(h => h.videoId));
      
      if (hiddenVideoIds.length > 0) {
        where.id = { [Op.notIn]: hiddenVideoIds };
      }
    }

    const { count, rows } = await Video.findAndCountAll({
      where,
      include: [{
        model: User,
        as: 'user',
        attributes: ['id', 'name', 'email', 'avatar']
      }],
      limit: parseInt(limit),
      offset: parseInt(offset),
      order: [['created_at', 'DESC']]
    });

    return {
      videos: rows,
      pagination: {
        total: count,
        page: parseInt(page),
        limit: parseInt(limit),
        totalPages: Math.ceil(count / limit)
      }
    };
  }

  async getVideoById(id) {
    const video = await Video.findByPk(id, {
      include: [{
        model: User,
        as: 'user',
        attributes: ['id', 'name', 'email', 'avatar']
      }]
    });

    if (!video) {
      throw new Error('Video not found');
    }

    return video;
  }

  async updateVideo(id, updateData, userId) {
    const video = await Video.findOne({ where: { id, userId } });
    
    if (!video) {
      throw new Error('Video not found or unauthorized');
    }

    await video.update(updateData);
    return await this.getVideoById(id);
  }

  async deleteVideo(id, userId) {
    const video = await Video.findOne({ where: { id, userId } });
    
    if (!video) {
      throw new Error('Video not found or unauthorized');
    }

    await video.destroy();
    return { message: 'Video deleted successfully' };
  }

  async hideVideo(videoId, userId) {
    const video = await Video.findByPk(videoId);
    if (!video) {
      throw new Error('Video not found');
    }

    const [hiddenVideo, created] = await HiddenVideo.findOrCreate({
      where: { userId, videoId },
      defaults: { userId, videoId }
    });

    if (!created) {
      throw new Error('Video already hidden');
    }

    return { message: 'Video hidden successfully' };
  }

  async unhideVideo(videoId, userId) {
    const hiddenVideo = await HiddenVideo.findOne({
      where: { userId, videoId }
    });

    if (!hiddenVideo) {
      throw new Error('Video not hidden');
    }

    await hiddenVideo.destroy();
    return { message: 'Video unhidden successfully' };
  }

  async isVideoHidden(videoId, userId) {
    if (!userId) return false;
    const hiddenVideo = await HiddenVideo.findOne({
      where: { userId, videoId }
    });
    return !!hiddenVideo;
  }
}

module.exports = new VideoService();

