 UsersController.class_eval do
    $e6={"status_code"=>"2034","status_message"=>"sorry email already taken"}
 prepend_before_filter :load_object, :only => [:show, :edit, :update]
  prepend_before_filter :authorize_actions, :only => :new
def create
	  if !params[:format].nil? && params[:format] == "json"
    @user = User.new(params[:user])
    if @user.save
  render :json =>@user
  else 
    error=error_response_method($e6)
        render:json=>error
 end
else
	@user = User.new(params[:user])
    if @user.save

      if current_order
        current_order.associate_user!(@user)
        session[:guest_token] = nil
      end

      redirect_back_or_default(root_url)
    else
      render 'new'
    end

	end
end
 def error_response_method(error)
    @error = {}
    @error["code"]=error["status_code"]
    @error["message"]=error["status_message"]
    #@error["Code"] = error["error_code"]
    return @error
  end
end