const mongoose = require("mongoose");

const userSchema = new mongoose.Schema({
  username: {
    type: String,
    required: true,
  },
  userType: {  
    type: String,
    enum: ['Mother', 'Father', 'Other'],
    default: 'Mother'
  },
  email: {
    type: String,
    required: true,
  },
  password: {
    type: String,
    required: true,
  },

  profileImage: {
    type: String,
  },

  isBlocked: {
    type: Boolean,
    default: false,
  },
  role: {
    type: String,
    enum: ["user", "admin"],
    default: "user",
  },
  babyId: {
       type: mongoose.Schema.Types.ObjectId,
        ref: 'Baby',
      },/*,
  similarityFactor: {
    type: [Number],
    default: [],
  }, */
});

const User = mongoose.model("User", userSchema);

module.exports = User;
