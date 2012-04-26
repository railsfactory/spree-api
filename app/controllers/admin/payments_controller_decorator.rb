Admin::PaymentsController.class_eval do
	 before_filter :load_order, :only => [:create, :new, :index, :fire]
  before_filter :load_payment, :except => [:create, :new, :index]
  before_filter :load_data
	$e15={"status_code"=>"2039","status_message"=>"payments cannot be captured"}
	def current_ability
    user= current_user || User.find_by_authentication_token(params[:authentication_token])
    @current_ability ||= Ability.new(user)
  end
	def index
		  @payments = @order.payments
		  if !params[:format].nil? && params[:format] == "json"
 render :json => @payments.to_json, :status => 201
   else
   respond_with(@payments)
	 end
  end

  def new
    @payment = @order.payments.build
			  if !params[:format].nil? && params[:format] == "json"
    render :json => @payment.to_json, :status => 201
		else
    respond_with(@payment)
		end
  end

  def fire
    # TODO: consider finer-grained control for this type of action (right now anyone in admin role can perform)
    return unless event = params[:e] and @payment.payment_source
    if @payment.payment_source.send("#{event}", @payment)
			
				      flash.notice = t('payment_updated')
					
	
						else
							 flash[:error] = t('cannot_perform_operation')
							 end
  rescue Spree::GatewayError => ge
    flash[:error] = "#{ge.message}"
  ensure
	 if !params[:format].nil? && params[:format] == "json"
		 	render :json => @payment.to_json, :text=>"payment sucess",:status => 201
  
	else
 respond_with(@payment) { |format| format.html { redirect_to admin_order_payments_path(@order) } }
	end
end
def load_order
	 if !params[:format].nil? && params[:format] == "json"
		  if session[:order_id]==nil
		 current_user=User.find_by_authentication_token(params[:authentication_token])
   current_order = Order.find_all_by_user_id(current_user.id).last
	 if current_order.state !="cart"&&current_order.payments.count != 0 && current_order.payments.first.state !="completed"
	 @order=current_order
	 else
		 error = error_response_method($e15)
      render :json => error
	 end
	 else
    @order ||= Order.find_by_number! params[:order_id]
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