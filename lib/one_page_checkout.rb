require 'spree_core'
require 'one_page_checkout_hooks'

module OnePageCheckout
  class Engine < Rails::Engine

    config.autoload_paths += %W(#{config.root}/lib)

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), "../app/**/*_decorator*.rb")) do |c|
        Rails.env.production? ? require(c) : load(c)
      end
      #Order.send(:include, OrderDecorator)
      CheckoutController.class_eval do
        def before_one_page
          #~ @order.bill_address ||= Address.new(:country => default_country)
          #~ @order.ship_address ||= Address.new(:country => default_country)
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
      end

      Order.class_eval do 
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
    end

    config.to_prepare &method(:activate).to_proc
  end
end
