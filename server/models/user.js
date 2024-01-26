const mongoose=require("mongoose");

//schema matlab data dikheg kaise ...structure
const userSchema=mongoose.Schema({
//ab schema ka structure define kro types required wgera
name:{
    type:String,
    required:true,
},
email:{
    type:String,
    required:true
},
profilePic:{
    type:String,
    required:true
}
});


//collection ka naam de dia aur schema pass krdia
const User= mongoose.model("User",userSchema);


//taki baki files mei bhi use kr paye
module.exports=User;