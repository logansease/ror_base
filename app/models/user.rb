
# == Schema Information
#
# Table name: users
#
#  id                 :integer         not null, primary key
#  name               :string(255)
#  email              :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  encrypted_password :string(255)
#  salt               :string(255)
#  admin              :boolean         default(FALSE)
#  fb_user_id         :integer
#

class User < ActiveRecord::Base      
  attr_accessor  :password, :fb_access_token  #defines new getter and setter
  attr_accessible :name, :email, :password, :password_confirmation, :fb_user_id, :fb_access_token

  #validation
  email_reg_ex = /\A[\w+\-.]+@[a-z\d.]+\.[a-z]+\z/i
  
  validates :name, :presence => true,
                    :length => { :maximum => 50 }
  validates :email, :presence => true,  
                    :format => { :with => email_reg_ex},
                    :uniqueness => { :case_sensitive => false}
  
  validates :password, :presence => true,
                       :confirmation => true,
                       :length => { :within => 6..40 }   
                       
  before_save :encrypt_password



  #relationships
  has_many :relationships, :dependent => :destroy,
           :foreign_key => "follower_id" #since relationship table does not have user_id, must specify key to join to
  has_many :user_reverse_relationships, -> { where relationship_type: RELATIONSHIP_TYPE_USER }, :dependent => :destroy,
                           :foreign_key => "followed_id",
                           :class_name => "Relationship"
  has_many :user_relationships, -> { where relationship_type: RELATIONSHIP_TYPE_USER }, :dependent => :destroy,
                           :foreign_key => "follower_id",
                           :class_name => "Relationship"
  has_many :following_users,:through => :relationships, :source => :followed_users
  has_many :followers, :through => :user_reverse_relationships, :source => :follower

   ## or class << self
   ## def authenticate(       
  def User.authenticate(email, submitted_password)
     user = User.find_by_email(email); 
      
     (user && user.has_password?(submitted_password)) ? user : nil
       
  end                  
  
  def User.authenticate_with_salt(id, cookie_salt)
     user = find_by_id(id)
     (user && user.salt == cookie_salt) ? user : nil
  end
           
  def has_password?(submitted_password)
     encrypted_password == encrypt(submitted_password)
  end    


  def activate (key)
    if key == salt
      self.update_attribute( :activated, true)
    end
  end



  #relationship methods
  def follow(followed, type)
     Relationship.create(:follower_id => self.id, :followed_id => followed.id, :relationship_type => type)
  end

  def unfollow(followed, type)
    Relationship.where(:follower_id => self.id, :followed_id => followed.id, :relationship_type => type).delete_all
  end

  def follower_count
    if !followers
      0
    else
      followers.count
    end
  end

  def following? object
    if object.kind_of? User
       return self.following_users.include? object
    else
      return false
    end
  end

  def fb_connections
    User.where("fb_user_id in (?)",self.fb_friend_ids)
  end

  def fb_friend_ids

    begin
      graph = Koala::Facebook::API.new(self.fb_access_token)
      results = graph.get_connections('me', 'friends?fields=installed')
    rescue Exception  => e
      results = []
      puts "An error occurred, #{e}"
    end

    #for each id, insert to fb_friends, fb_id, id
    friends = []
    results.each do |result|
       friends << result["id"]
    end

    friends
  end

  private

  def image_url
    if self.fb_user_id
      "http://graph.facebook.com/#{self.fb_user_id}/picture?type=large"
    end
  end

    def encrypt_password      
       self.salt = make_salt if new_record?
       if(self.password && !password.blank?)
        self.encrypted_password = encrypt(self.password)
       end
    end        
    
    def encrypt(string)
       secure_hash("#{salt}--#{string}")
    end  
                
    def make_salt
       secure_hash("#{Time.now.utc}--#{password}")
    end
    
    def secure_hash(string)
       Digest::SHA2.hexdigest(string)
    end         
  
end








