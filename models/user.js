const mongoose = require("mongoose");

const userSchema = new mongoose.Schema({
  username: {
    type: String,
    required: true,
  },
  email: {
    type: String,
    required: true,
  },
  password: {
    type: String,
    required: true,
  },
  phoneNumber: {
    type: String,
    required: true,
  },/*
  profileImage: {
    type: String,
  },
  cv: {
    type: String,
  },*/
  isBlocked: {
    type: Boolean,
    default: false,
  },
  role: {
    type: String,
    enum: ["user", "admin"],
    default: "user",
  }/*,
  similarityFactor: {
    type: [Number],
    default: [],
  }, */
});

const User = mongoose.model("User", userSchema);

module.exports = User;
