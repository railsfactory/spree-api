CheckoutController.class_eval do
    include ApiHelper
   before_filter :set_current_user
   ssl_required

  before_filter :load_order
  rescue_from Spree::GatewayError, :with => :rescue_from_spree_gateway_error
$e1={"status_code"=>"2038","status_message"=>"parameter errors"}
$e2={"status_code"=>"2037","status_message"=>"Record not found"}
$e3={"status_code"=>"2036","status_message"=>"Payment failed check the details entered"}
$e4={"status_code"=>"2035","status_message"=>"destroyed"}
$e5={"status_code"=>"2030","status_message"=>"Undefined method request check the url"}
$e7={"status_code"=>"2031","status_message"=>"No items to checkout "}
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
        render :json => @order.to_json, :status => 201,:location => completion_route
      else
        render :json => @order.to_json, :status => 201,:location=>checkout_state_path(@order.state)
      end
    else
      error=error_response_method($e1)
        render:json=>error
    end
    rescue Exception=>e
    
     render :text => "#{e.message}", :status => 500
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
      
    def error_response_method(error)
    @error = {}
    @error["code"]=error["status_code"]
    @error["message"]=error["status_message"]
    #@error["Code"] = error["error_code"]
    return @error
  end
  
  private
  def load_order
  if !params[:format].nil? && params[:format] == "json"
    @order = current_order
    #redirect_to cart_path and return unless @order and @order.checkout_allowed?
    render :json => error_response_method($e7) and return unless @order and @order.checkout_allowed?
    redirect_to cart_path and return if @order.completed?
    @order.state = params[:state] if params[:state]
    state_callback(:before)
  end
     else
       @order = current_order
    redirect_to cart_path and return unless @order and @order.checkout_allowed?
    redirect_to cart_path and return if @order.completed?
    @order.state = params[:state] if params[:state]
    state_callback(:before)
       end
	end