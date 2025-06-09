const User = require("../models/user");
//const Opportunity = require("../models/opportunity");
const jwt = require("jsonwebtoken");
const bcrypt = require("bcryptjs");
const fs = require("fs")


const loginAdmin = async (req, res) => {
  const { email, password } = req.body;
  const user = await User.findOne({ email: email });
  console.log(user);

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

  try {
    if (user.role === "admin") {
      return res.status(200).json({ message: "welcome admin", user, token });
    } else return res.status(403).json({ error: "sorry,u r not admin" });
  } catch (error) {
    return res
      .status(500)
      .json({ message: "Failed to login", error: error.message });
  }
};


const getUsers =  async (req ,res )=>{
  const users = await User.find();
  console.log(users);
  
 return res.status(200).json({users})
}

const getUserById = async (req, res) => {
  const id = req.params.id;
  const user = await User.findById(id);

  if (!user) {
    return res.status(404).json({ message: "User not found" });
  }
  const image = await fs.promises.readFile(
    `${process.cwd()}\\${user.profileImage}`
  );
  const base64Image = Buffer.from(image, "binary").toJSON();
  console.log(base64Image);
  const cv = await fs.promises.readFile(`${process.cwd()}\\${user.cv}`);
  const base64Cv = Buffer.from(cv, "binary").toJSON();
  const jsonUser = user.toJSON();
  delete jsonUser.password;
  jsonUser.profileImage = base64Image;
  jsonUser.cv = base64Cv;
  console.log(jsonUser);
  return res.status(200).json(jsonUser);
};



const blockUser = async (req, res) => {
  try {
    const userId = req.params.id;
    const user = await User.findByIdAndUpdate(userId, { isBlocked: true },{new:true});

    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    return res.status(200).json({ message: "User blocked successfully", user });
  } catch (err) {
    return res.status(400).json({ error: err.message });
  }
};
/*
const getOpportunity = async (req, res) => {
  const role = req.params.role;

  if (!role) {
    const op = await Opportunity.find({ isDeleted: false }).populate("user");
    return res.status(200).json(op);
  }
  const op = await Opportunity.find({ role: role, isDeleted: false }).populate(
    "user"
  );
  return res.status(200).json({ op });
};

const getOpportunityById = async (req, res) => {

  let opportunityId = req.params.opportunityId;

  try {
    const opportunity = await Opportunity.findOne({opportunity:opportunityId}).populate("opportunity");

   return  res.status(200).json({ opportunity });
  } catch (error) {
    return res
      .status(500)
      .json({ message: "Failed to get opportunity", error: error.message });
  }
};


const softDeleteOpportunity = async (req, res) => {
  try {
    const opportunitytId = req.params.id;
    const opportunity = await Opportunity.findByIdAndUpdate({
      _id: opportunitytId,
     
    },
  {
    isDeleted:true
  },
{
  new:true
});
    console.log(opportunity);
    return res.status(200).json(opportunity);
  } catch (err) {
    return res.status(400).json({ error: err.message });
  }
};
const getOpportunityByUser = async (req, res) => {
  let userId = req.params.userId;

  let opportunity = await Opportunity.find().populate("user");

  const filteredOp = opportunity.filter((op) => {
    return op.user._id.toString() === userId;
  });
  res.status(200).json({ filteredOp });
};
*/
module.exports = {
  loginAdmin,
  getUserById,
  getUsers,
  blockUser,
  //getOpportunity,
  //getOpportunityById,
  //softDeleteOpportunity,
 // getOpportunityByUser,
};
