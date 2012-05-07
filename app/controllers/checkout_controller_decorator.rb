CheckoutController.class_eval do
  before_filter :check_authorization
  before_filter :check_registration, :except => [:registration, :update_registration]
  before_filter :load_order
  rescue_from Spree::GatewayError, :with => :rescue_from_spree_gateway_error
  $e1={"status_code"=>"2038","status_message"=>"parameter errors"}
  $e2={"status_code"=>"2037","status_message"=>"Record not found"}
  $e3={"status_code"=>"2036","status_message"=>"Payment failed check the details entered"}
  $e4={"status_code"=>"2035","status_message"=>"destroyed"}
  $e5={"status_code"=>"2030","status_message"=>"Undefined method request check the url"}
  $e7={"status_code"=>"2031","status_message"=>"No items to checkout "}
  helper :users
  #To Register new user
  def registration
    @user = User.new
  end
  #To register user before checkout
  def update_registration
    if current_order.update_attributes(:email => params[:order][:email], :state => "one_page")
      redirect_to checkout_path
    else
      @user = User.new
      render 'registration'
    end
  end
  #To authorize to check user permission
  def authorize!(*args)
    @_authorized = true
    current_ability.authorize!(*args)
  end
  #To authorize the current order
  def check_authorization
    authorize!(:edit, current_order, session[:access_token])
  end

  # Introduces a registration step whenever the +registration_step+ preference is true.
  def check_registration
    return unless Spree::Auth::Config[:registration_step]
    return if current_user or current_order.email
    store_location
    redirect_to checkout_registration_path
  end

  # Overrides the equivalent method defined in spree_core.  This variation of the method will ensure that users
  # are redirected to the tokenized order url unless authenticated as a registered user.
  def completion_route
    return order_path(@order) if current_user
    token_order_path(@order, @order.token)
  end
  #To set current user
  def current_ability
    if !params[:format].nil? && params[:format] == "json"
      user= current_user || User.find_by_authentication_token(params[:authentication_token])
      @current_ability ||= Ability.new(user)
    else
      @current_ability ||= ::Ability.new(current_user)
    end
  end
  #To Checkout the cart
  def update
    if !params[:format].nil? && params[:format] == "json"
      begin
        if @order.update_attributes(object_params)
          if @order.next
            state_callback(:after)
          else
            flash[:error] = I18n.t(:payment_processing_failed)
            error=error_response_method($e3)
            render:json=>error
            return
          end
          if @order.state == "complete" || @order.completed?
            flash[:notice] = I18n.t(:order_processed_successfully)
            flash[:commerce_tracking] = "nothing special"
            render :json => @order.to_json, :status => 201
          else
            render :json => @order.to_json, :status => 201
          end
        else
          error=error_response_method($e1)
          render:json=>error
        end
      rescue Exception=>e
        render :json => error_response_method($e7)
    
      end
    else
      if @order.update_attributes(object_params)
        if @order.next
          state_callback(:after)
        else
          flash[:error] = I18n.t(:payment_processing_failed)
          respond_with(@order, :location => checkout_state_path(@order.state))
          return
        end

        if @order.state == "complete" || @order.completed?
          flash[:notice] = I18n.t(:order_processed_successfully)
          flash[:commerce_tracking] = "nothing special"
          respond_with(@order, :location => completion_route)
        else
          respond_with(@order, :location => checkout_state_path(@order.state))
        end
      else
        respond_with(@order) { |format| format.html { render :edit } }
      end

    end
  end
  #To set address before checkout
  def before_one_page
    @order.bill_address ||= Address.default
    @order.ship_address ||= Address.default
    
    @order.shipping_method ||= (@order.rate_hash.first && @order.rate_hash.first[:shipping_method])
    @order.payments.destroy_all if request.put?
  end

  # change this to alias / spree
  def object_params
    if params[:payment_source].present? && source_params = params.delete(:payment_source)[params[:order][:payments_attributes].first[:payment_method_id].underscore]
      params[:order][:payments_attributes].first[:source_attributes] = source_params
    end
    if (params[:order][:payments_attributes])
      params[:order][:payments_attributes].first[:amount] = @order.total
    end
    params[:order]
  end
   #To show error message   
  def error_response_method(error)
    @error = {}
    @error["code"]=error["status_code"]
    @error["message"]=error["status_message"]
    return @error
  end
  
  private
  #To load current order
  def load_order
    if !params[:format].nil? && params[:format] == "json"
      if session[:order_id]==nil
        current_user=User.find_by_authentication_token(params[:authentication_token])
        if current_user.present?
          current_order = Order.find_all_by_user_id(current_user.id).last
        end
      end
      @order = current_order
      if !@order.nil? and @order.state != "complete"
        render :json => error_response_method($e7) and return unless @order and @order.checkout_allowed?
        redirect_to cart_path and return if @order.completed?
        @order.state = params[:state] if params[:state]
        state_callback(:before)
      elsif !@order.nil? and @order.state == "complete"
        render :json => error_response_method($e7) and return if  @order.checkout_allowed?
        redirect_to cart_path and return if @order.completed?
        @order.state = params[:state] if params[:state]
        state_callback(:before)
      else
        render :json => error_response_method($e7) and return if  @order.nil?
        redirect_to cart_path and return if @order.nil?
      end
    end
  else
    @order = current_order(true)
    redirect_to cart_path and return unless @order and @order.checkout_allowed?
    redirect_to cart_path and return if @order.completed?
    @order.state = params[:state] if params[:state]
    state_callback(:before)
  end
end