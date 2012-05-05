UserRegistrationsController.class_eval do
  include SpreeBase
  helper :users, 'spree/base'

  ssl_required
  after_filter :associate_user, :only => :create
  before_filter :check_permissions, :only => [:edit, :update]
  skip_before_filter :require_no_authentication
  $e6={"status_code"=>"2034","status_message"=>"sorry email already taken"}
  $e18={"status_code"=>"2046","status_message"=>"password miss match"}
  $e19={"status_code"=>"2049","status_message"=>"please enter valid email"}
  def create
    if !params[:format].nil? && params[:format] == "json"
      p params.inspect
      if params[:user][:email]!=nil&&params[:user][:email]!=""
        if params[:user][:password]==params[:user][:password_confirmation] && params[:user][:password]!=""&&params[:user][:password_confirmation]!=""
          @user=User.new(params[:user])
          if @user.save
            render :json =>@user
          else
            error=error_response_method($e6)
            render:json=>error
          end
        else
          error=error_response_method($e18)
          render:json=>error
        end
      else
        error=error_response_method($e19)
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
    return @error
  end
end