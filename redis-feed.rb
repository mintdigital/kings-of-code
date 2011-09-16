Bundler.require

$: << File.join(File.dirname(__FILE__), 'lib')

require 'friending'
require 'online_status'
require 'user'
require 'update'

set :sessions => true

$redis = Redis.new

before do
  @current_user = User.new(session[:user_id]) if session[:user_id]
end

# Homepage
get '/' do
  if @current_user
    @online_friends = @current_user.online_friends
    @feed = @current_user.feed
    @friends = @current_user.friends
  end
  erb :index
end

# User profile
get '/users/:name' do
  if @user = User.find_by_name(params[:name])
    @both_following = @current_user.both_follow(@user.id) if @current_user
    @user.profile_viewed!  # set profile views
    erb :show
  else
    status 404
  end
end

# All users
get '/users' do
  @users = User.all
  erb :users  
end

# Signin
post '/signin' do
  if user = User.find_by_name(params[:name])
    session[:user_id] = user.id
    OnlineStatus.online!(user)
    redirect '/'
   else
     status 404
  end
end

# Signout
post '/signout' do
  session[:user_id] = nil
  redirect '/'
end

# Signup
post '/signup' do
  if User.create(params[:name])
    redirect '/'
  else
    400
  end
end

# Create comment
post '/updates' do
  if update = Update.create(@current_user, params[:update])
    redirect '/'
  else
    500
  end
end

# Create friend
post '/friends' do
  if @user = User.find(params[:id])
    Friending.create(@current_user, @user)
    redirect "/users/#{@user.name}"
  else
    status 404
  end
end

error 404 do
  'Object not found!'
end
