 UserRegistrationsController.class_eval do
    include SpreeBase
  helper :users, 'spree/base'

  ssl_required
  after_filter :associate_user, :only => :create
  before_filter :check_permissions, :only => [:edit, :update]
  skip_before_filter :require_no_authentication
    $e6={"status_code"=>"500","status_message"=>"sorry email already taken"}
    $e14={"status_code"=>"500","status_message"=>"password miss match"}
 #~ prepend_before_filter :load_object, :only => [:show, :edit, :update]
  #~ prepend_before_filter :authorize_actions, :only => :new
def create
  if !params[:format].nil? && params[:format] == "json"
    if params[:user][:email]!=nil
    if params[:user][:password]==params[:user][:password_confirmation]
    @user=User.new(params[:user])
    if @user.save
    render :json =>@user
    else
      error=error_response_method($e6)
      render:json=>error
    end
    else
      error=error_response_method($e14)
      render:json=>error
    end
    else
       error=error_response_method($e1)
      render:json=>error
      end
    else
       @user = build_resource(params[:user])
    logger.debug(@user)
    if resource.save
      set_flash_message(:notice, :signed_up)
      sign_in_and_redirect(:user, @user)
    else
      clean_up_passwords(resource)
      render_with_scope(:new)
    end
  end
	  
end
def check_permissions
    authorize!(:create, resource)
  end

  def associate_user
    return unless current_user and current_order
    current_order.associate_user!(current_user)
    session[:guest_token] = nil
  end
def save_user_role
   return unless params[:user]

      @user.roles << admin

  end
 def error_response_method(error)
    @error = {}
    @error["code"]=error["status_code"]
    @error["message"]=error["status_message"]
    #@error["Code"] = error["error_code"]
    return @error
  end
end