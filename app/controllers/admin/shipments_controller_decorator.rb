  Admin::ShipmentsController.class_eval do
before_filter :load_order
  before_filter :load_shipment, :only => [:destroy, :edit, :update, :fire]
  before_filter :load_shipping_methods, :except => [:country_changed, :index]
  $e22={"status_code"=>"2031","status_message"=>"sorry! backordered items cant be shipped Once stock updated this action could be done"}
  $e23={"status_code"=>"2050","status_message"=>"shipment id invalid"}
  $e24={"status_code"=>"2051","status_message"=>"order id invalid"}
  def current_ability
   user= current_user || User.find_by_authentication_token(params[:authentication_token])
    
    @current_ability ||= Ability.new(user)
  end
def index
   #if !params[:format].nil? && params[:format] == "json"
     @shipments = @order.shipments
     		respond_with(@shipments) do |format|
      format.html
      format.json { render :json => @shipments }
    end
   
  end
def fire
  if !params[:format].nil? && params[:format] == "json"
   current_user=User.find_by_authentication_token(params[:authentication_token])
		 if current_user.present?
    if @shipment.present?
    if @shipment.send("#{params[:e]}")
      flash.notice = t('shipment_updated')
    else
      flash[:error] = t('cannot_perform_operation')
    end

    #respond_with(@shipment) { |format| format.html { redirect_to :back } }
    if @shipment.state=="shipped"
        render :json => @shipment.to_json, :status => 201
        else 
          #render :json => {:text=>"sucess payment updated",:status=>401}
          #render :json=>{:text=>"sorry! backordered items cant be shipped Once stock updated this action could be done",:status=>401}
           error=error_response_method($e22)
        render:json=>error

  end
  else
    error=error_response_method($e23)
        render:json=>error
      end
      else
         error=error_response_method($e13)
        render:json=>error
        end
  else
     if @shipment.send("#{params[:e]}")
      flash.notice = t('shipment_updated')
    else
      flash[:error] = t('cannot_perform_operation')
    end

    respond_with(@shipment) { |format| format.html { redirect_to :back } }
  end
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
    begin
    @order = Order.find_by_number(params[:order_id])
    p @order
    rescue Exception=>e
     error=error_response_method($e24)
        render:json=>error
end
  end
def load_shipping_methods
  p "2222222222222222222222222222222222222222222222222"
  if @order.present?
    @shipping_methods = ShippingMethod.all_available(@order, :back_end)
    else
       error=error_response_method($e24)
        render:json=>error
        end
  end
  def load_shipment
      begin
    @shipment = Shipment.find_by_number(params[:id])
    p @shipment
     rescue Exception=>e
      error=error_response_method($e23)
        render:json=>error
end
  end
end
