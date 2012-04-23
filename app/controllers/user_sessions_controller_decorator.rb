UserSessionsController.class_eval do 
     include ApiHelper
   #~ before_filter :set_current_user
  $e8={"status_code"=>"2032","status_message"=>"Username/Password is incorrect"}
  $e9={"status_code"=>"2033","status_message"=>"logged out sucessfully"}
 include SpreeBase
  helper :users, 'spree/base'

  include Spree::CurrentOrder

  after_filter :associate_user, :only => :create

  ssl_required :new, :create, :destroy, :update
  ssl_allowed :login_bar

def create
    authenticate_user!

    if user_signed_in?
      api_key = current_user.generate_api_key!
      user_response = Hash.new
      user_response[:user] = Hash.new
      user_response[:user][:email]=current_user.email
      user_response[:user][:authentication_token]=current_user.authentication_token
      user_response[:user][:sign_in_count]=current_user.sign_in_count
      #session[:authentication_token]=current_user.authentication_token
      respond_to do |format|
        format.html {
          flash.notice = t(:logged_in_succesfully)
          redirect_back_or_default(products_path)
        }
        format.json {
          render :json => user_response.to_json
        }
      end
    else
        if !params[:format].nil? && params[:format] == "json"
          error=error_response_method($e8)
        render:json=>error
          else
      flash.now[:error] = t('devise.failure.invalid')
      render :new
    end
    end
  end
  def error_response_method(error)
    if !params[:format].nil? && params[:format] == "json"
    @error = {}
    @error["code"]=error["status_code"]
    @error["message"]=error["status_message"]
    #@error["Code"] = error["error_code"]
    return @error
    end
  end
   def destroy
     current_user.authentication_token=nil if current_user && (!params[:format].nil? && params[:format] == "json")
     current_user.save if current_user && (!params[:format].nil? && params[:format] == "json")
    session.clear
   # super
    if !params[:format].nil? && params[:format] == "json"
     error=error_response_method($e9)
        render:json=>error
        else
        super
    
  end
  end
  end