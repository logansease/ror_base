class TokensController < ApplicationController

  def create
    user = User.authenticate params[:username],params[:password]
    if(user)
      Token.where(:user => user).delete_all
      token = Token.generate (user)
    else
      render :json => {:errors => "invalid login"}
      return
    end


    if token.save
      render json: token
    else
      render :json => {:errors => "invalid login"}
    end
  end

  def refresh
    token = Token.refresh(params[:refresh_token])
    if token.save
      render json: token
    else
      render :json => {:errors => "refresh token invalid"}
    end
  end

  def index
    @objects = Token.paginate(:page => params[:page])
  end

  def destroy
    Token.find_by_access_token(params[:access_token]).delete
    render :json => {:result => "success"}
  end

end
