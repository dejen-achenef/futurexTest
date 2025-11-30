const { User } = require('../models');
const fs = require('fs');
const path = require('path');

class UserService {
  async getAllUsers(query = {}) {
    const { search, page = 1, limit = 10 } = query;
    const offset = (page - 1) * limit;
    const { Sequelize } = require('sequelize');
    const { Video } = require('../models');

    const where = {};
    if (search) {
      where[Sequelize.Op.or] = [
        { name: { [Sequelize.Op.like]: `%${search}%` } },
        { email: { [Sequelize.Op.like]: `%${search}%` } }
      ];
    }

    // Use a simpler approach: get users first, then count videos for each
    const { count, rows } = await User.findAndCountAll({
      where,
      attributes: { exclude: ['password'] },
      limit: parseInt(limit),
      offset: parseInt(offset),
      order: [['created_at', 'DESC']],
      include: [{
        model: Video,
        as: 'videos',
        attributes: ['id'],
        required: false
      }]
    });

    // Format users with video count
    const usersWithCount = rows.map(user => {
      const userJson = user.toJSON();
      return {
        ...userJson,
        videoCount: userJson.videos ? userJson.videos.length : 0,
        videos: undefined // Remove videos array from response
      };
    });

    return {
      users: usersWithCount,
      pagination: {
        total: count,
        page: parseInt(page),
        limit: parseInt(limit),
        totalPages: Math.ceil(count / limit)
      }
    };
  }

  async getUserById(id) {
    const user = await User.findByPk(id, {
      attributes: { exclude: ['password'] },
      include: [{
        model: require('../models').Video,
        as: 'videos',
        attributes: ['id', 'title', 'description', 'youtube_video_id', 'category', 'duration', 'created_at'],
        order: [['created_at', 'DESC']]
      }]
    });

    if (!user) {
      throw new Error('User not found');
    }

    return user;
  }

  async updateUser(id, updateData, avatarFile) {
    const user = await User.findByPk(id);
    if (!user) {
      throw new Error('User not found');
    }

    // Handle avatar upload
    if (avatarFile) {
      // Delete old avatar if exists
      if (user.avatar) {
        const oldAvatarPath = path.join(process.env.UPLOAD_PATH || './uploads/avatars', user.avatar);
        if (fs.existsSync(oldAvatarPath)) {
          fs.unlinkSync(oldAvatarPath);
        }
      }
      updateData.avatar = avatarFile.filename;
    }

    await user.update(updateData);

    return {
      id: user.id,
      name: user.name,
      email: user.email,
      avatar: user.avatar
    };
  }

  async deleteUser(id) {
    const user = await User.findByPk(id);
    if (!user) {
      throw new Error('User not found');
    }

    // Delete avatar if exists
    if (user.avatar) {
      const avatarPath = path.join(process.env.UPLOAD_PATH || './uploads/avatars', user.avatar);
      if (fs.existsSync(avatarPath)) {
        fs.unlinkSync(avatarPath);
      }
    }

    await user.destroy();
    return { message: 'User deleted successfully' };
  }
}

module.exports = new UserService();

