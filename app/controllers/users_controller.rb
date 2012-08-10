class UsersController < ApplicationController

  def create
    @user = User.new(params[:user])
    if @user.save
       flash[:notice] = "User with login #{@user.email} created successfully!"
       redirect_to '/'
    else
       render 'new'
    end
  end

  def index
    @users = User.all
  end
  
  def show
    @user = User.find(params[:id])
  end
  
  def new
    @user = User.new
  end

end
