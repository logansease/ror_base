require 'base64'
require 'openssl'
require 'rails'
require 'json'



module SessionsHelper
  
  def fb_user?(facebook_id)
    reset_session
     user = User.find_by_fb_user_id(facebook_id);
     user != nil
  end
  
  def sign_in(user)
    cookies.permanent.signed[:remember_token] = [user.id, user.salt] 
    current_user = user
    current_user.update_attribute(:recover_password,false)
  end

  def fb_access_token
    session[:fb_access_token]
  end

  def set_access_token (token)
    session[:fb_access_token] = token
  end
  
  def current_user=(user)
    @current_user = user
  end
  
  def current_user    
    #||= says if current user is null, return user_from_remember_token AND assign it to 
    #@current_user
     @current_user ||= user_from_remember_token
  end  

  def signed_in?
     !current_user.nil?
  end    
  
  def sign_out     
    cookies.delete(:remember_token)
     current_user =  nil
    reset_session
  end                 
          
  def deny_access  
      store_location
      redirect_to signin_path, :notice => "Please sign in"
  end   

  def redirect_back_or(default)
     redirect_to (session[:return_to] || default)  
     clear_return_to 
  end        
          
  def clear_return_to
    session[:return_to] = nil 
  end  

  def store_location(path = request.fullpath)
      session[:return_to] = path  
    end   
    
    def current_user?(user) 
      #TODO , why is isn't this @current user
       return user == current_user
    end    
    
    def authenticate  
     # flash[:notice] = "Please sign in to access this page" or below
     deny_access unless signed_in?
    end

  def check_admin
    redirect_to root_path unless signed_in? and current_user.admin?
  end

  def valid_facebook_cookie_or_signed_request?(signed_request = nil) 

    if(!signed_request)
      signed_request = cookies["fbsr_432701290149585"]
    end
    
    if signed_request && !signed_request.blank?

      secret = "29006173bb560571176ce021f8978005"
  
      #decode data
      encoded_sig, payload = signed_request.split('.')
      sig = base64_url_decode(encoded_sig).unpack("H*")[0]
      data = JSON.parse base64_url_decode(payload)
  
      if data['algorithm'].to_s.upcase != 'HMAC-SHA256'
        Rails.logger.error 'Unknown algorithm. Expected HMAC-SHA256'
        return false
      end
  
      #check sig
      expected_sig = OpenSSL::HMAC.hexdigest('sha256', secret, payload)
      if expected_sig != sig
      # Rails.logger.error 'Bad Signed JSON signature!'
        return false
      end
      
      @fb_id = data['user_id']
    end
  end
  
  def generated_password
    Digest::SHA1.hexdigest("--#{Time.now.to_s}----")[0,8]
  end


  private 
  
    def user_from_remember_token   
      # Note the * below "unwraps" the array and turns it from [i,j] to i , j to match mtd args
      User.authenticate_with_salt(*remember_token) 
    end                            
  
    def remember_token
      cookies.signed[:remember_token] || [nil, nil]
    end   
    
    def base64_url_decode str
      if str
        encoded_str = str.gsub('-','+').gsub('_','/')
        encoded_str += '=' while !(encoded_str.size % 4).zero?
        Base64.decode64(encoded_str)
      end
    end
   
end
