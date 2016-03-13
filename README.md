[ ![Codeship Status for callzhang/EetNowServer](https://codeship.com/projects/296f05a0-d5b6-0132-a9ce-26dfd4cc1a97/status?branch=master)](https://codeship.com/projects/78149)

#URL
eat-now.herokuapp.com/

# API
route | parameters or payload | notes
---- | ---- | ---- 
__GET__  /search | username, latitude, longitude, time, radius, mood | time is optional if not given,time would be server local time, please use something like `encodeURI(new Date())` as the string parameter . Radius is also optional, if not given, will call foursquare API without radius paramter and will use radius = 500 when compute the distance score. __Returns__ list of sorted restaurants
__GET__  /user/:username | | history will contain actual restaurant object instead of restaurant id. __Returns__ a user object with his history and preference|
__PUT__  /restaurant/:id | img_url(array of image urls) | duplicated urls won't be inserted. __Returns__ the updated restaurant
__POST__  /select | username, restaurantId, like, date, rating, location |  like should be 1 or 0, rating is a number(1~5), location should be an object contains latitude, longitude and distance , date should be like "2015-04-18T21:16:18+0800" which contains UTC offset. __Returns__ status 200 OK
__DELTE__  /user /:username /history /:id | | delete history from user. __Returns__ updated user
__PUT__  /user /:name /history /:id|like| update history. __Returns__ updated history
__POST__  /user | token, provider, [username], [name], [sex], [city], [password] | Create a user with third party information and __returns__ the created user object. 
__POST__ /user/search |the pay load should have provider and token | query a user with token and provider: facebook, google, wechat... __Returns__ user object
__GET__ /image/| url=imageUrl | __Returns__ image binary
__PUT__ /user/:username | {key: value} | __Returns__ user object
__DELETE__ /user/:username | username | delete user by username
__PUT__ /user/:username/reportLocation | username, {label, updated, coordinates,radius} | update location history
