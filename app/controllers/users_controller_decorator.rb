UsersController.class_eval do
  $e20={"status_code"=>"2034","status_message"=>"password is wrong "}
  $e21={"status_code"=>"2034","status_message"=>"please sign in to login"}
  include SpreeBase
  helper :users, 'spree/base'
  include Spree::CurrentOrder
  ssl_required :new, :create, :destroy, :update
  ssl_allowed :login_bar
  #To login the user and generate_api_key
  def create
    if !params[:format].nil? && params[:format] == "json"
      if params[:user][:email]!=""&&params[:user][:email]!=nil
        user=User.find_by_email(params[:user][:email])
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
    end
	  
  end
  #To respond the error message
  def error_response_method(error)
    @error = {}
    @error["code"]=error["status_code"]
    @error["message"]=error["status_message"]
    return @error
  end
end