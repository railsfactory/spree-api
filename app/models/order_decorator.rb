Order.class_eval do
  before_update:create_shipment!
	 def create_shipment!
       if self.state!="cart"
    shipping_method(true)
    if shipment.present?
      shipment.update_attributes(:shipping_method => shipping_method)
    else
      self.shipments << Shipment.create(:order => self,
                                        :shipping_method => shipping_method,
                                        :address => self.ship_address)
    end
end
  end

	end