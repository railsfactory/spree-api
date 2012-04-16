  Admin::ShipmentsController.class_eval do
before_filter :load_order
  before_filter :load_shipment, :only => [:destroy, :edit, :update, :fire]
  before_filter :load_shipping_methods, :except => [:country_changed, :index]
  $e7={"status_code"=>"200","status_message"=>"sorry! backordered items cant be shipped Once stock updated this action could be done"}
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
           error=error_response_method($e7)
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
end
