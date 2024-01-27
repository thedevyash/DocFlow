
//nodeJS ki import lines aisi hote hai
const express=require("express");
//chahte to uid se bhi krlete magar hacker wgera local storage se uid nikalkr info le skte isliye jwt use krre security rhegi
const jwt=require("jsonwebtoken");
const User = require("../models/user");
const auth = require("../middlewares/auth");

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
//jwt is like a wrapper which gives us random generated token 
//id pass krdi
//passwordKey ek key h jo ki password access krne mei help kregi yani ki jwt ko ccess krne mei
const token= jwt.sign({id:user._id},"passwordKey");
//return data to client side
res.json({user:user,token:token});

}catch(e){
res.status(500).json({error:e.message});
}
});
//get the user ke liye route
//auth ek middleware hai
authRouter.get('/',auth,async(req,res)=>{
    //user verify ho chuka hai aur ab uss id ke user ki info server se uthao aur leke client pr jao
    //req.user mei user ki id hai jo verify kia auth middleware mei
    const user = await User.findById(req.user);
    res.json({user,token:req.token});

});

module.exports=authRouter;
