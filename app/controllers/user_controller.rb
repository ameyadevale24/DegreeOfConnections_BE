require 'csv'

class UserController < ApplicationController
  def index
    render json: User.order(:name).to_a
  end

  def store
    csv = CSV.parse(params[:file].read, :headers => true)
    csv.each do |user|
      User.create(:id=>user['userid'], :name=>user['name'])
    end
  end
end
