const jwt=require("jsonwebtoken");

//middleware hai
//user pehle se logged in hai ki nhi
//agar logged in hai to hi info show krni hai 
//jaise docs and other user information
//auth ek function hai
const auth=async (req,res,next)=>{
    try{
        //token nikalo
const token=req.header("x-auth-token");
//token nhi h ki nhi check kro
if(!token)
//401 means no authorisation
return res.status(401).json({msg:"No auth token,access denied"});
//ab verify kro jwt sahi h ki nhi...pr kyuki jwt gibberish format mei hai to function use krna pdega
//verify() decode krke deta hai {id:user._id} return krega
const verified=jwt.verify(token,"passwordKey");
if(!verified)
{
    return res.status(401).json({msg:"Token verification failed,authorization failed"});
}
//agar verify ho gya
//token bnate tym payload mei user._id di thi to ab wahi id leke req.user mei daldi
req.user=verified.id;
req.token=token;
//middleware ko batao ki bhaiya sara kam ho gya hai ab jao server pr
next();
}
    catch(e){
res.status(500).json({error:e.message});
    }
}

module.exports=auth;

//sabse pehle check karre token hi ki nhi
//fir check kre token verified hi ki nhi
//agr verified nhi hai to return krdo error k saath
//agr verified h to next() ka use krke server pr bhejdo