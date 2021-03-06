Spree::UserRegistrationsController.class_eval do
  #include Spree::Base
  #~ helper :users, 'spree/base'
  include Spree::Core::ControllerHelpers
  helper 'spree/users', 'spree/base'
  ssl_required
  after_filter :associate_user, :only => :create
  before_filter :check_permissions, :only => [:edit, :update]
  skip_before_filter :require_no_authentication
  $e6={"status_code"=>"2034","status_message"=>"Sorry email already taken"}
  $e18={"status_code"=>"2046","status_message"=>"Password miss match"}
  $e19={"status_code"=>"2049","status_message"=>"Please enter valid email"}
  $e30={"status_code"=>"2011","status_message"=>"Please enter a Password"}
  $e31={"status_code"=>"2012","status_message"=>"Please enter a Confirm password"}
  #To create new user
  def create
    if !params[:format].nil? && params[:format] == "json"
      if params[:user][:email]!=nil&&params[:user][:email]!=""&&params[:user][:email].match(/^(|(([A-Za-z0-9]+_+)|([A-Za-z0-9]+\-+)|([A-Za-z0-9]+\.+)|([A-Za-z0-9]+\++))*[A-Za-z0-9]+@((\w+\-+)|(\w+\.))*\w{1,63}\.[a-zA-Z]{2,6})$/i)
        if params[:user][:password]==""
          error=error_response_method($e30)
          render:json=>error
        else
          if params[:user][:password_confirmation]==""
            error=error_response_method($e31)
            render:json=>error
          else
            if params[:user][:password]==params[:user][:password_confirmation] && params[:user][:password]!=""&&params[:user][:password_confirmation]!=""
              @user=Spree::User.new(params[:user])
              if @user.save
                render :json =>@user
              else
                error=error_response_method($e6)
                render:json=>error
              end
            else
              error=error_response_method($e96)
              render:json=>error
            end
          end
        end
      else
        error=error_response_method($e19)
        render:json=>error
      end
      
    else
      @user = build_resource(params[:user])
      if resource.save
        set_flash_message(:notice, :signed_up)
        sign_in(:user, @user)
        fire_event('spree.user.signup', :user => @user, :order => current_order(true))
        sign_in_and_redirect(:user, @user)
      else
        clean_up_passwords(resource)
        render :new
      end
    end
    
  end
  def check_permissions
    authorize!(:create, resource)
  end

  def associate_user #To find the user
    return unless current_user and current_order
    current_order.associate_user!(current_user)
    session[:guest_token] = nil
  end
  def save_user_role #To save the user roles 
    return unless params[:user]

    @user.roles << admin

  end
  def error_response_method(error) #To display the error message
    @error = {}
    @error["code"]=error["status_code"]
    @error["message"]=error["status_message"]
    return @error
  end
end
