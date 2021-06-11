users ----------------> id --------------> {username,address,email,phone,isSeller,hasOrdered,kitchenid*}
kitchens --------------------------------->[] {id,kname,userId,username,email,phone,address,isVeg,rating,createdAt,noOfRating}
food--------------------->id (i.e kitchenid*)---------------->[items] {id,name,price,image,isVeg,createdAt}
cart------------------> id(i.e userId)---------->[] {id,foodid}
orders---------------> id (i.e kitchenid)--------------> {id,userid,username,address,[]foodid*}


legend:
[] -------> subcollection
* --------> reference
{} --------> fields inside