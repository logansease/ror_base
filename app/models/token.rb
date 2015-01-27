class Token < ActiveRecord::Base
  attr_accessible :refresh_token, :access_token, :expires_on, :user_id, :refresh_by
  belongs_to :user

  def Token.generate(user)
    t = Token.new
    t.user = user
    t.access_token = SecureRandom.hex
    t.refresh_token = SecureRandom.hex
    t.expires_on = Time.zone.now + 7.days
    t.refresh_by = Time.zone.now + 30.days
    t
  end

  def Token.refresh(refresh_token)
    token = Token.find_by_refresh_token(refresh_token)
    if token and token.refresh_by > Time.zone.now
      token.delete
      token = Token.generate(token.user)
    else
      nil
    end
  end

  def Token.user_for_token(access_token)
    token = Token.find_by_access_token(access_token)
    if token and token.refresh_by > Time.zone.now
      token.user
    else
      nil
    end
  end

end
