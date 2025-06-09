const jwt = require("jsonwebtoken");
const User = require("../models/user");

const authenticateToken = async (req, res, next) => {
  const authHeader = req.get("Authorization");

  console.log(authHeader);
  if (!authHeader)
    return res.status(401).json({ message: "user not logged in" });

  const token = authHeader.split(" ")[1];
  let decodedToken;
  try {
    decodedToken = jwt.verify(token, process.env.ACCESS_TOKEN_SECRET);
  } catch (err) {
    err.statusCode = 500;
    throw err;
  }

  const user = await User.findOne({ email: decodedToken.email });
  req.user = user;
  next();
};



module.exports = authenticateToken;
