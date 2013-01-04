twitter-sdk-corona
==================

Twitter SDK for Corona


How To Use:

1. Add contents of 'twitter-sdk-corona' folder to your project.
2. In 'main.lua' file, import 'sqlite' and 'settings':
	require "sqlite"
	settings = require("settings")
3. In 'main.lua' file, initialize settings:
	settings:init()
4. Import 'Twitter' class in the file from which Twitter API needs to be called:
	local twitter = require "utils.Twitter"
5. Methods to be used:

-- To be called initially before any other method call

	twitter.setUpConsumer('Consumer Key', 'Consumer Secret', 'Web URL')


-- To send a tweet

	twitter.tweet('callback - delegate method', 'Message to tweet')


-- To send a tweet with Image (upload an Image)

	twitter.tweet_media('callback - delegate method', 'Message to tweet', 'Image Name - in Documents Directory')


-- To start following someone

	twitter.create_friendship('callback - delegate method', 'Screen Name of the person whom to follow')


-- To get user information such as: name, screen name, id, image_url, etc.

	twitter.get_user_info('callback - delegate method')


-- To send any other request using Twitter REST API v1.1 : For eg - If 'https://api.twitter.com/1.1/friends/ids.json?cursor=-1&screen_name=twitterapi' is to be used, the resource is 'friends/ids', method will be 'GET' (according to Twitter API) and parameters can be set like this:

		local params = {}
		params[1] =
      	{
        	key = 'cursor',
            value = '-1'
      	}
        params[2] =
        {
            key = 'screen_name',
            value = 'twitterapi'
        }

	twitter.twitter_request('callback - delegate method', 'resource', 'request method - GET, POST, etc', 'params - Parameters to be passed')

6. 'callback - delegate method' used in all methods above, is a delegate method to get response:

-- Declare this local variable on the top
	local callback = {}


-- Use these delegate methods with methods above (in STEP 5) for receiving response or checking for Success, Failure and Cancel events of a request

-- Success Delegate

	function callback.twitterSuccess(response)  
		-- Override this method to perform specific tasks needed in your app.    
		-- 'response' is a JSON string and will only be returned when 'get_user_info' or 'twitter_request' methods are called.
	end


-- Failure Delegate

	function callback.twitterFailed()
		-- Override this method to perform specific tasks needed in your app.
	end


-- Cancel Delegate

	function callback.twitterCancel()
		-- Override this method to perform specific tasks needed in your app.
	end