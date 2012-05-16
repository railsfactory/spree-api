Spree::UserSessionsController.class_eval do 
  $e8={"status_code"=>"2032","status_message"=>"Username/Password is incorrect"}
  $e9={"status_code"=>"2033","status_message"=>"logged out sucessfully"}
   $e20={"status_code"=>"2034","status_message"=>"password is wrong "}
  $e21={"status_code"=>"2034","status_message"=>"please sign up to login"}
  #include Spree::Base
  include Spree::Core::ControllerHelpers
  helper 'spree/users', 'spree/base'

  include Spree::Core::CurrentOrder
  after_filter :associate_user, :only => :create
  ssl_required :new, :create, :destroy, :update
  ssl_allowed :login_bar
# To create user session
  def create
     if !params[:format].nil? && params[:format] == "json"
      if params[:user][:email]!=""&&params[:user][:email]!=nil
        user=Spree::User.find_by_email(params[:user][:email])
        if user.present?
          if user.valid_password?(params[:user][:password]) #To validate the password
            current_user=user
            api_key = current_user.generate_api_key! #To generate api key
            user_response = Hash.new
            user_response[:user] = Hash.new
            user_response[:user][:email]=current_user.email
            user_response[:user][:authentication_token]=current_user.authentication_token
            user_response[:user][:sign_in_count]=current_user.sign_in_count
            respond_to do |format|
              format.json {
                render :json => user_response.to_json
              }
            end
          else
            error=error_response_method($e20)
            render:json=>error
          end
        else
          error=error_response_method($e21)
          render:json=>error
        end
      else
        error=error_response_method($e19)
        render:json=>error
      end
    else
     authenticate_user!

    if user_signed_in?
      respond_to do |format|
        format.html {
          flash.notice = t(:logged_in_succesfully)
          redirect_back_or_default(products_path)
        }
        format.js {
          user = resource.record
          render :json => {:ship_address => user.ship_address, :bill_address => user.bill_address}.to_json
        }
      end
    else
      flash.now[:error] = t('devise.failure.invalid')
      render :new
    end
    end
    #~ authenticate_user!
    #~ if user_signed_in?
      #~ api_key = current_user.generate_api_key! #To generate api key
      #~ user_response = Hash.new
      #~ user_response[:user] = Hash.new
      #~ user_response[:user][:email]=current_user.email
      #~ user_response[:user][:authentication_token]=current_user.authentication_token
      #~ user_response[:user][:sign_in_count]=current_user.sign_in_count
      #~ respond_to do |format|
        #~ format.html {
          #~ flash.notice = t(:logged_in_succesfully)
          #~ redirect_back_or_default(products_path)
        #~ }
        #~ format.json {
          #~ render :json => user_response.to_json
        #~ }
      #~ end
    #~ else
      #~ if !params[:format].nil? && params[:format] == "json"
        #~ error=error_response_method($e8)
        #~ render:json=>error
      #~ else
        #~ flash.now[:error] = t('devise.failure.invalid')
        #~ render :new
      #~ end
    #~ end
  end
  def error_response_method(error) #To display error message
    if !params[:format].nil? && params[:format] == "json"
      @error = {}
      @error["code"]=error["status_code"]
      @error["message"]=error["status_message"]
      return @error
    end
  end
  #To destroy user session
  def destroy 
    if !params[:format].nil? && params[:format] == "json"
       current_user=Spree::User.find_by_authentication_token(params[:authentication_token])
      if current_user.present?
        current_user.authentication_token=nil
        current_user.save
        error=error_response_method($e9)
        render:json=>error
      else
        error=error_response_method($e13)
        render:json=>error
      end
    else
      session.clear
      super
    end
  end
end