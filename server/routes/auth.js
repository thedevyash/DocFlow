
//nodeJS ki import lines aisi hote hai
const express=require("express");
const User = require("../models/user");

//express use krne ke liye uska instance bn dia authRouter
const authRouter=express.Router();

//expressRouter ke andar kafi requests hai unka use kro
//ek pi ka endpoint set kia aur uska function bnaya
//async isliye hai kyuki external service use krre like mongoDB to time differ krega
authRouter.post('/api/signup',async (req,res)=>{
try{
    //req.body mei se name email profilepic nikaal li aur check kia kahi pehle kya krna hai
const {name,email,profilePic}=req.body;
//email alredy exists or not??

//ab check krre kahi pehle se koi hai to nhi
//find an email with the email property that we got from our client side
//await kyuki external service
//let = var
//jao jakr user cllection mei dekho mail h ki nhi
let user=await User.findOne({email:email});

//agar user exist nhi krta
if(!user){
    //ek naya user bna dia
    user=new User({
        email:email,
        name:name,
        profilePic:profilePic,
    });
    //user ka data mongoose mei sve krlia, .save() mongoose ka function hai
    //user ko wapis asign isliye krre kyuki mongoDB ek id return krta hai bnakr jiska use hum krenge identify krne mei isliye wais se save krliye
    user=await user.save();
}
//return data to client side
res.json({user:user});

}catch(e){
res.status(500).json({error:e.message});
}
});

module.exports=authRouter;
