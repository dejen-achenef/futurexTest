const Joi = require('joi');

const createVideoSchema = Joi.object({
  title: Joi.string().min(1).max(200).required(),
  description: Joi.string().max(1000).optional().allow(''),
  youtubeVideoId: Joi.string().required(),
  category: Joi.string().min(1).max(50).required(),
  duration: Joi.number().integer().min(0).optional()
});

const validate = (schema) => {
  return (req, res, next) => {
    const { error } = schema.validate(req.body);
    if (error) {
      return res.status(400).json({ 
        error: error.details[0].message 
      });
    }
    next();
  };
};

module.exports = {
  validateCreateVideo: validate(createVideoSchema)
};

