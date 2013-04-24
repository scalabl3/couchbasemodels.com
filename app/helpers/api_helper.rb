module ApiHelper

	def pubnub_message(msg)
		@pubnub = Pubnub.new(
        "pub-14860739-170f-420f-b635-4d70bd34f913",  ## PUBLISH_KEY
        "sub-15f15733-33f4-11e1-9378-279bdc9061aa",  ## SUBSCRIBE_KEY
        "sec-bed878f8-a429-4019-969f-74ab85a8c962",  ## SECRET_KEY
        "",      ## CIPHER_KEY (Cipher key is Optional)
        false    ## SSL_ON?
    )

		@publish_callback = lambda { |message| Rails.logger.debug "Pubnub Publish: #{message}" }

    @pubnub.publish({
        'channel' => 'couchbasemodels',
        'message' => msg,
        'callback' => @publish_callback
    })
  rescue 
    Rails.logger.debug "Rescue after pubnub.publish"
  end

  def pubnub_userinfo(user)
		msg = { 'user' => user, 'message' => 'User Info' }
		pubnub_message(msg)
	end
    
  def pubnub_comment(page, comment_text, user = nil)
		msg = { 'page' => page, 'user' => user, 'comment' => comment_text }
		pubnub_message(msg)
	end

	def pubnub_login(user)
		msg = { 'user' => user, 'message' => "User Logged In" }
		pubnub_message(msg)
	end
	
	def pubnub_logout(user)
		msg = { 'user' => user, 'message' => "User Logged Out" }
		pubnub_message(msg)
	end
	
	def pubnub_exception(exception_name, msg)
		msg ={ 'exception' => exception_name, 'message' => msg }
		pubnub_message(msg)
	end
	
end