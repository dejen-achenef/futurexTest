module.exports = (sequelize, DataTypes) => {
  const HiddenVideo = sequelize.define('HiddenVideo', {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true
    },
    userId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      field: 'user_id',
      references: {
        model: 'users',
        key: 'id'
      }
    },
    videoId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      field: 'video_id',
      references: {
        model: 'videos',
        key: 'id'
      }
    }
  }, {
    tableName: 'hidden_videos',
    timestamps: true,
    underscored: true,
    indexes: [
      {
        unique: true,
        fields: ['user_id', 'video_id'],
        name: 'unique_user_video_hide'
      }
    ]
  });

  HiddenVideo.associate = function(models) {
    HiddenVideo.belongsTo(models.User, {
      foreignKey: 'userId',
      as: 'user'
    });
    HiddenVideo.belongsTo(models.Video, {
      foreignKey: 'videoId',
      as: 'video'
    });
  };

  return HiddenVideo;
};

