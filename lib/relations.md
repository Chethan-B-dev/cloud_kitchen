users ----------------> id --------------> {username,address,email,phone,isSeller,hasOrdered,kitchenid*,orderStatus}
kitchens --------------------------------->[] {id,kname,userId,username,email,phone,address,isVeg,rating,createdAt,noOfRating}
food--------------------->id (i.e kitchenid*)---------------->[items] {id,name,price,image,isVeg,createdAt}
cart------------------> id(i.e userId) ----------> [items] {id,quantity,foodid*}
orders---------------> id (i.e kitchenid)-------------->[orders] {id,userid,username,address,[items]{id,foodid*}}


legend:
[] -------> subcollection
* --------> reference
{} --------> fields inside