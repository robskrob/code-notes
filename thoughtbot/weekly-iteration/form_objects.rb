class UsersController < ApplicationController
  def new
    @user = User.new
    @user.build_company
  end

  def create
    @user = User.new(user_params)
    if @user.save
      set_current_user(@user)
      redirect_to root_path
    else
      render :new
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, company_attributes: [:name])
  end
end

class Company < ActiveRecord::Base
  belongs_to :user
end

class User < ActiveRecord::Base
  has_one :company

  accepts_nested_attributes_for :company
end

# Model
class Signup
  include ActiveModel::Model

  attr_accessor :user_email, :company_name, :user

  validates :user_email, presence: true
  validates :company_name, presence: true

  def save
    if valid?
      @user = User.create(email: user_email)
      @user.create_company(name: company_name)
    end
  end
end

class SignupsController < ApplicationController
  def new
    @signup = Signup.new
  end

  def create
    @signup = Signup.new(signup_params)

    if @signup.save
      set_current_user(@signup.user)
      redirect_to root_path
    else
      render :new
    end
  end

  private

  def signup_params
    params.require(:signup).permit(:user_email, :company_name)
  end
end
