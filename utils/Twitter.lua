-- Project: Twitter sample app
--
-- File name: Twitter.lua
--
-- Author: Corona Labs
-- Modified by: Vellum Interactive, Inc
-- Modified by: Vivek Kaushal, Click Labs Pvt. Ltd.
-- Abstract: Demonstrates how to connect to Twitter using Oauth Authenication.
--
-- Sample code is MIT licensed, see http://www.coronalabs.com/links/code/license
-- Copyright (C) 2010 Corona Labs Inc. All Rights Reserved.
-----------------------------------------------------------------------------------------

module(..., package.seeall)

local oAuth = require "utils.oAuth"

-- Fill in the following fields from your Twitter app account
consumer_key = ""			-- key string goes here
consumer_secret = ""		-- secret string goes here

-- The web URL address below can be anything
-- Twitter sends the webaddress with the token back to your app and the code strips out the token to use to authorise it
--
webURL = ""

-- Note: Once logged on, the access_token and access_token_secret should be saved so they can
--	     be used for the next session without the user having to log in again.
-- The following is returned after a successful authenications and log-in by the user
--

-- Local variables used in the tweet
local postMessage
local postImage
local delegate
local auth_attempts = 0
local sn

-- set up consumer key and secret, and webURL
function setUpConsumer(consumerKey, consumerSecret, web_url)
	consumer_key = consumerKey
	consumer_secret = consumerSecret
	webURL = web_url
end

-----------------------------------------------------------------------------------------
-- Twitter Authorization Listener FOR TWEETS
-----------------------------------------------------------------------------------------
--
local function listener(event)
	print("listener: ", event.url)
	local remain_open = true
	local url = event.url

	if url:find("oauth_token") and url:find(webURL) then
		url = url:sub(url:find("?") + 1, url:len())

		local authorize_response = responseToTable(url, {"=", "&"})
		remain_open = false

		local access_response = responseToTable(oAuth.getAccessToken(authorize_response.oauth_token,
			authorize_response.oauth_verifier, twitter_request_token_secret,
			consumer_key, consumer_secret, "http://api.twitter.com/oauth/access_token"), {"=", "&"})
		
		settings.game.twitter.access_token = access_response.oauth_token
		settings.game.twitter.access_token_secret = access_response.oauth_token_secret
		settings.game.twitter.user_id = access_response.user_id
		settings.game.twitter.screen_name = access_response.screen_name
		settings:save()
		
		print( "Tweeting" )
		
			-- API CALL:
		------------------------------
		--change the message posted
		local params = {}
		params[1] =
		{
			key = 'status',
			value = postMessage
		}
		
		request_response = oAuth.makeRequest("http://api.twitter.com/1/statuses/update.json",
			params, consumer_key, settings.game.twitter.access_token, consumer_secret, settings.game.twitter.access_token_secret, "POST")
			
		--`print("req resp ",request_response)
		
		delegate.twitterSuccess()

	elseif url:find(webURL) then
		-- Logon was canceled
		remain_open = false
		delegate.twitterCancel()
	elseif not url:find("twitter") then
		remain_open = false
		delegate.twitterCancel()		
	end

	return remain_open
end
-----------------------------------------------------------------------------------------
-- Twitter Authorization Listener FOR FREINDS
-----------------------------------------------------------------------------------------
--
local function listener_friend(event)
	print("listener: ", event.url)
	local remain_open = true
	local url = event.url

	if url:find("oauth_token") and url:find(webURL) then
		url = url:sub(url:find("?") + 1, url:len())

		local authorize_response = responseToTable(url, {"=", "&"})
		remain_open = false

		local access_response = responseToTable(oAuth.getAccessToken(authorize_response.oauth_token,
			authorize_response.oauth_verifier, twitter_request_token_secret,
			consumer_key, consumer_secret, "http://api.twitter.com/oauth/access_token"), {"=", "&"})
		
		settings.game.twitter.access_token = access_response.oauth_token
		settings.game.twitter.access_token_secret = access_response.oauth_token_secret
		settings.game.twitter.user_id = access_response.user_id
		settings.game.twitter.screen_name = access_response.screen_name
		settings:save()
		
		print( "Tweeting" )
		
			-- API CALL:
		------------------------------
		--change the message posted
		local params = {}
		params[1] =
		{
			key = 'screen_name',
			value = sn
		}
		params[2] = 
		{
			key = 'follow',
			value = "true"
		}
		

		request_response = oAuth.makeRequest("http://api.twitter.com/1/friendships/create.json",
			params, consumer_key, settings.game.twitter.access_token, consumer_secret, settings.game.twitter.access_token_secret, "POST")

	elseif url:find(webURL) then
		-- Logon was canceled
		remain_open = false
		delegate.twitterCancel()
	elseif not url:find("twitter") then
		remain_open = false
		delegate.twitterCancel()		
	end

	return remain_open
end
-----------------------------------------------------------------------------------------
-- Twitter Authorization Listener FOR PICTURE UPLOADS
-----------------------------------------------------------------------------------------
--
local function listener_media(event)
	print("listener: ", event.url)
	local remain_open = true
	local url = event.url

	if url:find("oauth_token") and url:find(webURL) then
		url = url:sub(url:find("?") + 1, url:len())

		local authorize_response = responseToTable(url, {"=", "&"})
		remain_open = false

		local access_response = responseToTable(oAuth.getAccessToken(authorize_response.oauth_token,
			authorize_response.oauth_verifier, twitter_request_token_secret,
			consumer_key, consumer_secret, "http://api.twitter.com/oauth/access_token"), {"=", "&"})
		
		settings.game.twitter.access_token = access_response.oauth_token
		settings.game.twitter.access_token_secret = access_response.oauth_token_secret
		settings.game.twitter.user_id = access_response.user_id
		settings.game.twitter.screen_name = access_response.screen_name
		settings:save()
		print( "Tweeting" )
		
			-- API CALL:
		------------------------------
		--change the message posted
		
		local imgPath = system.pathForFile( postImage, system.DocumentsDirectory)
--		local imgFile = io.open(imgPath, "r")
--		local imgData = ""
--		if imgFile then
--			imgData = imgFile:read("*a")
--			io.close(imgFile)
--			
--		end
		
		--print("file length: ", string.len(imgData))
		
		local params = {}
		params[1] =
		{
			key = 'status',
			value = postMessage
		}
		
--t-	request_response = oAuth.makeRequest("http://requestb.in/rllkvvrl", 
		
		request_response = oAuth.makeRequestWithMedia("http://upload.twitter.com/1/statuses/update_with_media.json",
			params, postImage, consumer_key, settings.game.twitter.access_token, consumer_secret, settings.game.twitter.access_token_secret, "POST")
			
		if request_response == 200 then
			delegate.twitterSuccess()
		else
			delegate.twitterFailed()
		end

	elseif url:find(webURL) then
		-- Logon was canceled
		remain_open = false
		delegate.twitterCancel()
	elseif not url:find("twitter") then
		remain_open = false
		delegate.twitterCancel()	
	end

	return remain_open
end

-----------------------------------------------------------------------------------------
-- Twitter Authorization Listener FOR VERIFYING CREDENTIALS 
-----------------------------------------------------------------------------------------
--
local function listener_info(event)
	print("listener: ", event.url)
	local remain_open = true
	local url = event.url

	if url:find("oauth_token") and url:find(webURL) then
		url = url:sub(url:find("?") + 1, url:len())

		local authorize_response = responseToTable(url, {"=", "&"})
		remain_open = false

		local access_response = responseToTable(oAuth.getAccessToken(authorize_response.oauth_token,
			authorize_response.oauth_verifier, twitter_request_token_secret,
			consumer_key, consumer_secret, "http://api.twitter.com/oauth/access_token"), {"=", "&"})
		
		settings.game.twitter.access_token = access_response.oauth_token
		settings.game.twitter.access_token_secret = access_response.oauth_token_secret
		settings.game.twitter.user_id = access_response.user_id
		settings.game.twitter.screen_name = access_response.screen_name
		settings:save()
		print( "Tweeting" )
		
			-- API CALL:
		------------------------------
		
		
		local params = {}
--		params[1] =
--		{
--			key = 'status',
--			value = postMessage
--		}
		
--t-	request_response = oAuth.makeRequest("http://requestb.in/rllkvvrl", 
		
		request_response = oAuth.makeRequest("https://api.twitter.com/1/account/verify_credentials.json",
			params, consumer_key, settings.game.twitter.access_token, consumer_secret, settings.game.twitter.access_token_secret, "POST")
			
		--if request_response then
--			delegate.twitterSuccess()
--		else
--			delegate.twitterFailed()
--		end

	elseif url:find(webURL) then
		-- Logon was canceled
		remain_open = false
		delegate.twitterCancel()
	elseif not url:find("twitter") then
		remain_open = false
		delegate.twitterCancel()	
	end

	return remain_open
end

-- Local variables for all_requests
local request_url
local request_method
local parameters

-----------------------------------------------------------------------------------------
-- Twitter Authorization Listener FOR ALL REQUESTS
-----------------------------------------------------------------------------------------
--
local function listener_request(event)
	print("listener: ", event.url)
	local remain_open = true
	local url = event.url

	if url:find("oauth_token") and url:find(webURL) then
		url = url:sub(url:find("?") + 1, url:len())

		local authorize_response = responseToTable(url, {"=", "&"})
		remain_open = false

		local access_response = responseToTable(oAuth.getAccessToken(authorize_response.oauth_token,
			authorize_response.oauth_verifier, twitter_request_token_secret,
			consumer_key, consumer_secret, "http://api.twitter.com/oauth/access_token"), {"=", "&"})
		
		settings.game.twitter.access_token = access_response.oauth_token
		settings.game.twitter.access_token_secret = access_response.oauth_token_secret
		settings.game.twitter.user_id = access_response.user_id
		settings.game.twitter.screen_name = access_response.screen_name
		settings:save()
		print( "Tweeting" )
		
			-- API CALL:
		------------------------------
		
		
		--local params = {}
--		params[1] =
--		{
--			key = 'status',
--			value = postMessage
--		}
		
--t-	request_response = oAuth.makeRequest("http://requestb.in/rllkvvrl", 
		
		request_response = oAuth.makeRequest("https://api.twitter.com/1.1/"..request_url..".json",
			parameters, consumer_key, settings.game.twitter.access_token, consumer_secret, settings.game.twitter.access_token_secret, request_method)
			
		if request_response then
			delegate.twitterSuccess(request_response)
		else
			delegate.twitterFailed()
		end

	elseif url:find(webURL) then
		-- Logon was canceled
		remain_open = false
		delegate.twitterCancel()
	elseif not url:find("twitter") then
		remain_open = false
		delegate.twitterCancel()	
	end

	return remain_open
end

local function listener_info(event)
	print("listener: ", event.url)
	local remain_open = true
	local url = event.url

	if url:find("oauth_token") and url:find(webURL) then
		url = url:sub(url:find("?") + 1, url:len())

		local authorize_response = responseToTable(url, {"=", "&"})
		remain_open = false

		local access_response = responseToTable(oAuth.getAccessToken(authorize_response.oauth_token,
			authorize_response.oauth_verifier, twitter_request_token_secret,
			consumer_key, consumer_secret, "http://api.twitter.com/oauth/access_token"), {"=", "&"})
		
		settings.game.twitter.access_token = access_response.oauth_token
		settings.game.twitter.access_token_secret = access_response.oauth_token_secret
		settings.game.twitter.user_id = access_response.user_id
		settings.game.twitter.screen_name = access_response.screen_name
		settings:save()
		print( "Tweeting" )
		
			-- API CALL:
		------------------------------
		
		
		local params = {}
--		params[1] =
--		{
--			key = 'status',
--			value = postMessage
--		}
		
--t-	request_response = oAuth.makeRequest("http://requestb.in/rllkvvrl", 
		
		request_response = oAuth.makeRequest("https://api.twitter.com/1/account/verify_credentials.json",
			params, consumer_key, settings.game.twitter.access_token, consumer_secret, settings.game.twitter.access_token_secret, "POST")
			
		--if request_response then
--			delegate.twitterSuccess()
--		else
--			delegate.twitterFailed()
--		end
		delegate.twitterSuccess(request_response)
	
	elseif url:find(webURL) then
		-- Logon was canceled
		remain_open = false
		delegate.twitterCancel()
	elseif not url:find("twitter") then
		remain_open = false
		delegate.twitterCancel()	
	end

	return remain_open
end

-----------------------------------------------------------------------------------------
-- RESPONSE TO TABLE
--
-- Strips the token from the web address returned
-----------------------------------------------------------------------------------------
--
function responseToTable(str, delimeters)
	local obj = {}

	while str:find(delimeters[1]) ~= nil do
		if #delimeters > 1 then
			local key_index = 1
			local val_index = str:find(delimeters[1])
			local key = str:sub(key_index, val_index - 1)
	
			str = str:sub((val_index + delimeters[1]:len()))
	
			local end_index
			local value
	
			if str:find(delimeters[2]) == nil then
				end_index = str:len()
				value = str
			else
				end_index = str:find(delimeters[2])
				value = str:sub(1, (end_index - 1))
				str = str:sub((end_index + delimeters[2]:len()), str:len())
			end
			obj[key] = value
			--print(key .. ":" .. value)		-- **debug
		else	
			local val_index = str:find(delimeters[1])
			str = str:sub((val_index + delimeters[1]:len()))
	
			local end_index
			local value
	
			if str:find(delimeters[1]) == nil then
				end_index = str:len()
				value = str
			else
				end_index = str:find(delimeters[1])
				value = str:sub(1, (end_index - 1))
				str = str:sub(end_index, str:len())
			end
			
			obj[#obj + 1] = value
			--print(value)					-- **debug
		end
	end
	
	return obj
end

-----------------------------------------------------------------------------------------
-- Tweet
--
-- Sends the tweet. Authorizes if no access token
-----------------------------------------------------------------------------------------
--
function tweet(del, msg)
	postMessage = msg
	delegate = del
	
	-- Check to see if we are authorized to tweet
	if not settings.game.twitter.access_token then
		print("Authorizing Account")
	
		if not consumer_key or not consumer_secret then
			-- Exit if no API keys set (avoids crashing app)
			print("FAILED")
			delegate.twitterFailed()
			return
		end
		local twitter_request = (oAuth.getRequestToken(consumer_key, webURL,
				"http://api.twitter.com/oauth/request_token", consumer_secret))
		local twitter_request_token = twitter_request.token
		local twitter_request_token_secret = twitter_request.token_secret
	
		if not twitter_request_token then
			-- No valid token received. Abort
			delegate.twitterFailed()
			return
		end
		timer.performWithDelay(200, function() native.setActivityIndicator( false ) end )
		-- Request the authorization
		native.showWebPopup(0, 0, display.contentWidth, display.contentHeight, "http://api.twitter.com/oauth/authorize?oauth_token="..twitter_request_token, {urlRequest = listener})
	else
		print( "Tweeting" )
		
		------------------------------
		-- API CALL:
		------------------------------
		--change the message posted
		local params = {}
		params[1] =
		{
			key = 'status',
			value = postMessage
		}
		
		request_response = oAuth.makeRequest("http://api.twitter.com/1/statuses/update.json",
			params, consumer_key, settings.game.twitter.access_token, consumer_secret, settings.game.twitter.access_token_secret, "POST")
			
		delegate.twitterSuccess()
	end
end

function authorize_twitter_media(cb)

	print("Authorizing Account")
	
	if not consumer_key or not consumer_secret then
		-- Exit if no API keys set (avoids crashing app)
		delegate.twitterFailed()
		return
	end
	
	local twitter_request = (oAuth.getRequestToken(consumer_key, webURL,
			"http://api.twitter.com/oauth/request_token", consumer_secret))
	local twitter_request_token = twitter_request.token
	local twitter_request_token_secret = twitter_request.token_secret

	if not twitter_request_token then
		-- No valid token received. Abort
		delegate.twitterFailed()
		return
	end
	timer.performWithDelay(200, function() native.setActivityIndicator( false ) end )
	-- Request the authorization
	native.showWebPopup(0, 0, display.contentWidth, display.contentHeight, "http://api.twitter.com/oauth/authorize?oauth_token="
		.. twitter_request_token, {urlRequest = listener_media})
	
end
-----------------------------------------------------------------------------------------
-- Tweet_With_Image
--
-- Sends the tweet. Authorizes if no access token
-----------------------------------------------------------------------------------------
--
function tweet_media(del, msg, img)
	postMessage = msg
	postImage = img
	delegate = del
	
	-- Check to see if we are authorized to tweet
	if not settings.game.twitter.access_token then
		
		authorize_twitter_media(listener_media)
		
	else
--		print( "Tweeting" )

		local params = {}
		params[1] =
		{
			key = 'status',
			value = postMessage
		}
		

		request_response = oAuth.makeRequestWithMedia("http://upload.twitter.com/1/statuses/update_with_media.json",
			params, postImage, consumer_key, settings.game.twitter.access_token, consumer_secret, settings.game.twitter.access_token_secret, "POST")
		if request_response == 401 then
			authorize_twitter_media()
			return
		end
		if request_response == 200 then
			delegate.twitterSuccess()
		else
			delegate.twitterFailed()
		end
	end
end

local function authorize_twitter_friendship()
	if not consumer_key or not consumer_secret then
		-- Exit if no API keys set (avoids crashing app)
		delegate.twitterFailed()
		return
	end
	
	local twitter_request = (oAuth.getRequestToken(consumer_key, webURL,
			"http://api.twitter.com/oauth/request_token", consumer_secret))
	local twitter_request_token = twitter_request.token
	local twitter_request_token_secret = twitter_request.token_secret

	if not twitter_request_token then
		-- No valid token received. Abort
		delegate.twitterFailed()
		return
	end
	timer.performWithDelay(200, function() native.setActivityIndicator( false ) end )
	-- Request the authorization
	native.showWebPopup(0, 0, display.contentWidth, display.contentHeight, "http://api.twitter.com/oauth/authorize?oauth_token="
		.. twitter_request_token, {urlRequest = listener_friend})
end

function create_friendship(del, screen_name)
	delegate = del
	sn = screen_name
	local code
	
	if not settings.game.twitter.access_token then
		
		authorize_twitter_friendship()
		
	else
		local params = {}
		params[1] =
		{
			key = 'screen_name',
			value = sn
		}
		params[2] = 
		{
			key = 'follow',
			value = "true"
		}
		
		request_response, code = oAuth.makeRequest("http://api.twitter.com/1/friendships/create.json",
			params, consumer_key, settings.game.twitter.access_token, consumer_secret, settings.game.twitter.access_token_secret, "POST")
		if code == 401 then
			print("Received 401")
			authorize_twitter_friendship()
			return
		end

		if code == 200 or code == 403 then
			delegate.twitterSuccess()
		else
			delegate.twitterFailed()
		end	

	end
end

local function authorize_user_info()
	if not consumer_key or not consumer_secret then
		-- Exit if no API keys set (avoids crashing app)
		delegate.twitterFailed()
		return
	end
	
	local twitter_request = (oAuth.getRequestToken(consumer_key, webURL,
			"http://api.twitter.com/oauth/request_token", consumer_secret))
	local twitter_request_token = twitter_request.token
	local twitter_request_token_secret = twitter_request.token_secret

	if not twitter_request_token then
		-- No valid token received. Abort
		delegate.twitterFailed()
		return
	end
	timer.performWithDelay(200, function() native.setActivityIndicator( false ) end )
	-- Request the authorization
	native.showWebPopup(0, 0, display.contentWidth, display.contentHeight, "http://api.twitter.com/oauth/authorize?oauth_token="
		.. twitter_request_token, {urlRequest = listener_info})
end

function get_user_info(del)
	delegate = del
	local code
	
	if not settings.game.twitter.access_token then
		
		authorize_user_info()
		
	else
	
		local params = {}
--		params[1] =
--		{
--			key = 'status',
--			value = postMessage
--		}
		
--t-	request_response = oAuth.makeRequest("http://requestb.in/rllkvvrl", 
		
		request_response = oAuth.makeRequest("http://api.twitter.com/1/account/verify_credentials.json",
			params, consumer_key, settings.game.twitter.access_token, consumer_secret, settings.game.twitter.access_token_secret, "GET")
		if code == 401 then
			print("Received 401")
			authorize_user_info()
			return
		end
		
		--if request_response then
--			delegate.twitterSuccess()
--		else
--			delegate.twitterFailed()
--		end
		
		--if code == 200 or code == 403 then
			delegate.twitterSuccess(request_response)
--		else
--			delegate.twitterFailed()
--		end	

	end
end

local function authorize_twitter_request()
	if not consumer_key or not consumer_secret then
		-- Exit if no API keys set (avoids crashing app)
		delegate.twitterFailed()
		return
	end
	
	local twitter_request = (oAuth.getRequestToken(consumer_key, webURL,
			"http://api.twitter.com/oauth/request_token", consumer_secret))
	local twitter_request_token = twitter_request.token
	local twitter_request_token_secret = twitter_request.token_secret

	if not twitter_request_token then
		-- No valid token received. Abort
		delegate.twitterFailed()
		return
	end
	timer.performWithDelay(200, function() native.setActivityIndicator( false ) end )
	-- Request the authorization
	native.showWebPopup(0, 0, display.contentWidth, display.contentHeight, "http://api.twitter.com/oauth/authorize?oauth_token="
		.. twitter_request_token, {urlRequest = listener_request})
end

-- To send any other request, use this method
function twitter_request(del, request, r_method, params)
	delegate = del
	local code
	
	if not settings.game.twitter.access_token then
		
		request_url = request
		request_method = r_method
		parameters = params
		
		authorize_twitter_request()
		
	else
	
		--local params = {}
--		params[1] =
--		{
--			key = 'status',
--			value = postMessage
--		}

		print("LLLL: "..request.." "..r_method)
		
--t-	request_response = oAuth.makeRequest("http://requestb.in/rllkvvrl", 
		
		request_response = oAuth.makeRequest("http://api.twitter.com/1.1/"..request..".json",
			params, consumer_key, settings.game.twitter.access_token, consumer_secret, settings.game.twitter.access_token_secret, r_method)
		if code == 401 then
			print("Received 401")
			authorize_twitter_request()
			return
		end
		
		--if request_response then
--			delegate.twitterSuccess()
--		else
--			delegate.twitterFailed()
--		end
		
		--if code == 200 or code == 403 then
			delegate.twitterSuccess(request_response)
--		else
--			delegate.twitterFailed()
--		end	

	end
end