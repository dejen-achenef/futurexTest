const jwt = require('jsonwebtoken');
const { User } = require('../models');

const optionalAuth = async (req, res, next) => {
  try {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

    if (token) {
      try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        const user = await User.findByPk(decoded.userId);
        if (user) {
          req.user = user;
        }
      } catch (error) {
        // Invalid token, but continue without authentication
        // Don't set req.user
      }
    }
    
    next();
  } catch (error) {
    // Continue without authentication on error
    next();
  }
};

module.exports = { optionalAuth };

