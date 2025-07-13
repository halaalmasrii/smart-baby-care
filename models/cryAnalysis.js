const mongoose = require('mongoose');

const cryAnalysisSchema = new mongoose.Schema({
  reason: {
    type: String,
    required: true,
    enum: ['belly pain', 'burping', 'cold_hot', 'discomfort', 'tired'] // الأسباب الثابتة من الواجهة
  },
  timestamp: {
    type: Date,
    default: Date.now
  },
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },babyId: {
       type: mongoose.Schema.Types.ObjectId,
        ref: 'Baby',
        required: true
      },
});

module.exports = mongoose.model('CryAnalysis', cryAnalysisSchema);