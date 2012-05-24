Spree::CheckoutController.class_eval do
   before_filter :check_http_authorization
  before_filter :load_order
  before_filter :check_authorization
  before_filter :check_registration, :except => [:registration, :update_registration]
 rescue_from Spree::Core::GatewayError, :with => :rescue_from_spree_gateway_error
  $e1={"status_code"=>"2038","status_message"=>"parameter errors"}
  $e2={"status_code"=>"2037","status_message"=>"Record not found"}
  $e3={"status_code"=>"2036","status_message"=>"Payment failed check the details entered"}
  $e4={"status_code"=>"2035","status_message"=>"destroyed"}
  $e5={"status_code"=>"2030","status_message"=>"Undefined method request check the url"}
  $e7={"status_code"=>"2031","status_message"=>"No items to checkout "}
	 def update
    if !params[:format].nil? && params[:format] == "json"
      begin
      p object_params
      p params
        if @order.update_attributes(object_params)
 					 fire_event('spree.checkout.update')
         final_order = []
          if @order.next
            state_callback(:after)
            if params[:state] == "delivery"
              final_order << @order            
              final_order << @order.shipment
            elsif params[:state] == "payment"
              final_order << @order
              final_order << @order.shipment
              final_order << @order.payment
            else
              final_order << @order
            end
          else
            flash[:error] = I18n.t(:payment_processing_failed)
            error=error_response_method($e3)
            render:json=>error
            return
          end
          if @order.state == "complete" || @order.completed?
            flash[:notice] = I18n.t(:order_processed_successfully)
            flash[:commerce_tracking] = "nothing special"
            render :json => final_order.to_json, :status => 201
          else
            render :json => final_order.to_json, :status => 201
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
				 fire_event('spree.checkout.update')
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
   def error_response_method(error)
    @error = {}
    @error["code"]=error["status_code"]
    @error["message"]=error["status_message"]
    #@error["Code"] = error["error_code"]
    return @error
  end
	 def load_order
        if !params[:format].nil? && params[:format] == "json"
      if session[:order_id]==nil
        p current_user=Spree::User.find_by_authentication_token(params[:authentication_token])
        if current_user.present?
          p current_order = Spree::Order.find_all_by_user_id(current_user.id).last
        end
      end
        @order = current_order
        render :json => error_response_method($e7) and return unless @order and @order.checkout_allowed?
        raise_insufficient_quantity and return if @order.insufficient_stock_lines.present?
       render :json => error_response_method($e7) and return if @order.completed?
        @order.state = params[:state] if params[:state]
        state_callback(:before)
        else
        @order = current_order ? current_order  : Spree::Order.find_by_id(session[:order_id], :include => :adjustments)
        redirect_to cart_path and return unless @order and @order.checkout_allowed?
        raise_insufficient_quantity and return if @order.insufficient_stock_lines.present?
        redirect_to cart_path and return if @order.completed?
        @order.state = params[:state] if params[:state]
        state_callback(:before)
      end
		end
		private
    def check_authorization
			 if !params[:format].nil? && params[:format] == "json"
           current_order = ''
        if session[:order_id] == nil
        current_user = Spree::User.find_by_authentication_token(params[:authentication_token])
        if current_user.present?
          current_order = Spree::Order.find_all_by_user_id(current_user.id).last
        end
      end
			else
        current_order = @order
				authorize!(:edit, current_order, session[:access_token])
			end
    end
     private
  def check_http_authorization
        if !params[:format].nil? && params[:format] == "json"
      if params[:authentication_token].present?
        user=Spree::User.find_by_authentication_token(params[:authentication_token])
        if !user.present?
          #~ role=Spree::.find_by_id(user.id)
          error = error_response_method($e13)
        render :json => error
      end 
      else
         error = error_response_method($e13)
        render :json => error
        end
    end
  end
	end