const User = require("../models/user");
//const FavoriteList = require("../models/favoriteList");
const jwt = require("jsonwebtoken");
const bcrypt = require("bcryptjs");
const fs = require("fs");

const createUser = async (req, res) => {
  const { username, email, password, phoneNumber } = req.body;

  if (
    !username ||
    !email ||
    !password ||
    !phoneNumber 
    /*
    || !req.files.cv ||
    !req.files.image
    */
  ) {
    return res
      .status(400)
      .json({ message: "Please provide all required fields" });
  }

  try {
    console.log('inside');
    
    const existUser = await User.findOne({ email: email });
    if (existUser) {
      return res.status(400).json({ message: "User already exist" });
    }
    /*
    let image;
    let cv;
    if (req.files) {
      image = req.files.image[0].path;
      cv = req.files.cv[0].path;
    }
    console.log(image);
    console.log(cv);
    */
    const hashedPassowrd = await bcrypt.hash(password, 12);

    const newUser = new User({
      username: username,
      email: email,
      password: hashedPassowrd,
      phoneNumber: phoneNumber,
      //profileImage: image,
      //cv: cv,
    });

    await newUser.save();
console.log(newUser);
/*
    const favoriteList = new FavoriteList({ userId: newUser._id });
    await favoriteList.save();
*/
    return res
      .status(201)
      .json({ message: "User created successfully", user: newUser });
  } catch (error) {
    return res
      .status(500)
      .json({ message:  error.message });
  }
};
//////////

const loginUser = async (req, res) => {
  const { email, password } = req.body;

  try {
    const user = await User.findOne({ email: email });

    if (!user) {
      return res.status(400).json({ message: "User not found" });
    }
    const isEqual = await bcrypt.compare(password, user.password);
    if (!isEqual) {
      return res.status(400).json({ message: "Invalid password" });
    }
    const token = jwt.sign(
      { email: user.email },
      process.env.ACCESS_TOKEN_SECRET
    );
    return res.status(200).json({ message: "Login successful", user, token });
  } catch (error) {
    return res
      .status(500)
      .json({ message: "Failed to login", error: error.message });
  }
};

//////////

const getUserById = async (req, res) => {
  const id = req.params.id;
  const user = await User.findById(id);

  if (!user) {
    return res.status(404).json({ message: "User not found" });
  }
  const image = await fs.promises.readFile(
    `${process.cwd()}\\${user.profileImage}`
  );
  /*
  const base64Image = Buffer.from(image, "binary").toJSON();
  console.log(base64Image);
  const cv = await fs.promises.readFile(`${process.cwd()}\\${user.cv}`);
  const base64Cv = Buffer.from(cv, "binary").toJSON();
  const jsonUser = user.toJSON();
  delete jsonUser.password;
  jsonUser.profileImage = base64Image;
  jsonUser.cv = base64Cv;
  */
  console.log(jsonUser);
  return res.status(200).json(jsonUser);
};

////////

const updateUserProfile = async (req, res) => {
  const userId = req.params.id;
  const username = req.body.username;
  const phoneNumber = req.body.phoneNumber;
  let user = await User.findById(userId);
  if (!user) {
    return res.status(404).json({ message: "User not found" });
  }
  if (username) {
    user.username = username;
  }
  if (phoneNumber) {
    user.phoneNumber = phoneNumber;
  }
  user = await user.save();
  return res.status(200).json({
    user,
  });
};

//////////
/*
const updateUserImage = async (req, res) => {
  try {
    const userId = req.params.id;
    const profileImagePath = req.files.image[0].path;
    const user = await User.findById(userId);
    console.log(user);
    fs.unlink(`${process.cwd()}\\${user.profileImage}`, (err) => {
      console.log(err);
    });
    user.profileImage = profileImagePath;
    await user.save();

    return res.json(user);
  } catch (err) {
    return res.status(400).json({ error: err.message });
  }
};

//////

const updateCv = async (req, res) => {
  try {
    const userId = req.params.id;
    const cvPath = req.files.cv[0].path;
    const user = await User.findById(userId);
    fs.unlink(`${process.cwd()}\\${user.cv}`, (err) => {
      console.log(err);
    });
    user.cv = cvPath;
    await user.save();
    return res.json(user);
  } catch (err) {
    return res.status(400).json({ error: err.message });
  }
};
*/

module.exports = {
  createUser,
  loginUser,
  getUserById,
  updateUserProfile,
  //updateUserImage,
 // updateCv,
};
