module Spree
  module Admin
ShipmentsController.class_eval do
  before_filter :load_order
  before_filter :load_shipment, :only => [:destroy, :edit, :update, :fire]
  before_filter :load_shipping_methods, :except => [:country_changed, :index]
  $e22={"status_code"=>"2031","status_message"=>"sorry! backordered items cant be shipped Once stock updated this action could be done"}
  $e23={"status_code"=>"2050","status_message"=>"shipment id invalid"}
  $e24={"status_code"=>"2051","status_message"=>"order id invalid"}
  #To set current user
  def current_ability
    user= current_user || Spree::User.find_by_authentication_token(params[:authentication_token])
    @current_ability ||=  Spree::Ability.new(user)
  end
  #To list the datas
  def index
        @shipments = @order.shipments
    respond_with(@shipments) do |format|
      format.html
      format.json { render :json => @shipments }
    end
   
 end
 #To fire the shipment
  def fire
    if !params[:format].nil? && params[:format] == "json"
      current_user=Spree::User.find_by_authentication_token(params[:authentication_token])
      if current_user.present?
        if @shipment.present?
          if @shipment.send("#{params[:e]}")
            flash.notice = t('shipment_updated')
          else
            flash[:error] = t('cannot_perform_operation')
          end
                if @shipment.state=="shipped"
            render :json => @shipment.to_json, :status => 201
          else
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
  #To display the error message
  def error_response_method(error)
    @error = {}
    @error["code"]=error["status_code"]
    @error["message"]=error["status_message"]
       return @error
  end
  private
  # To load the current order
  def load_order
    begin
      @order = Spree::Order.find_by_number(params[:order_id])
         rescue Exception=>e
      error=error_response_method($e24)
      render:json=>error
    end
  end
  # To load the load_shipping_methods
  def load_shipping_methods
      if @order.present?
      @shipping_methods = Spree::ShippingMethod.all_available(@order, :back_end)
    else
      error=error_response_method($e24)
      render:json=>error
    end
  end
   # To load the load_shipment
  def load_shipment
    begin
      @shipment = Spree::Shipment.find_by_number(params[:id])
      p @shipment
    rescue Exception=>e
      error=error_response_method($e23)
      render:json=>error
    end
  end
end
end
end
