Admin::PaymentsController.class_eval do
	 before_filter :load_order, :only => [:create, :new, :index, :fire]
  before_filter :load_payment, :except => [:create, :new, :index]
  before_filter :load_data
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
end