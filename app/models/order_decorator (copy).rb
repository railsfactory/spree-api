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
state_machines.clear
        state_machines[:state] = StateMachine::Machine.new(Order, :initial => 'cart', :use_transactions => false) do 
          event :next do 
            transition :from => 'cart', :to => 'one_page'
            transition :from => 'one_page', :to => 'complete' 
          end 
          event :cancel do 
            transition :to => 'canceled', :if => :allow_cancel? 
          end 
          event :return do 
            transition :to => 'returned', :from => 'awaiting_return' 
          end 
          event :resume do 
            transition :to => 'resumed', :from => 'canceled', :if => :allow_resume? 
          end 
          event :authorize_return do 
            transition :to => 'awaiting_return' 
          end 
          before_transition :to => 'complete' do |order| 
            begin 
              order.process_payments! 
            rescue Spree::GatewayError 
              if Spree::Config[:allow_checkout_on_gateway_error] 
                true 
              else 
                false 
              end 
            end 
          end 
          after_transition :to => 'complete', :do => :finalize! 
          after_transition :to => 'canceled', :do => :after_cancel
        end 

	end