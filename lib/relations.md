users ----------------> id --------------> {username,address,email,phone,isSeller,hasOrdered,kitchenid*}
kitchens --------------------------------->[] {id,kname,userId,username,email,phone,address,isVeg,rating}
food--------------------->id (i.e kitchenid*)---------------->[] {id,name,price,image,isVeg}
cart------------------> id(i.e userId)---------->[] {id,foodid}
orders---------------> id (i.e kitchenid)--------------> {id,userid,username,address,[]foodid*}


legend:
[] -------> subcollection
* ---------> reference
{} --------> fields inside