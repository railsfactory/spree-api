module Spree
  module Admin
    PaymentsController.class_eval do
      before_filter :check_http_authorization
      before_filter :load_order, :only => [:create, :new, :index, :fire]
      before_filter :load_payment, :except => [:create, :new, :index]
      before_filter :load_data
      $e15={"status_code"=>"2039","status_message"=>"payments cannot be captured check payment id"}
      #To set current user
      def current_ability
        user= current_user || Spree::User.find_by_authentication_token(params[:authentication_token])
        @current_ability ||= Ability.new(user)
      end
      #To list the datas
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
      #To capture the payment
      def fire
        # TODO: consider finer-grained control for this type of action (right now anyone in admin role can perform)
        return unless event = params[:e] and @payment.payment_source
        event = "void_transaction" if event == "void"
        if @payment.send("#{event}!")

          flash.notice = t('payment_updated')


        else
          flash[:error] = t('cannot_perform_operation')
        end
      rescue Spree::GatewayError => ge
        flash[:error] = "#{ge.message}"
      ensure
        if !params[:format].nil? && params[:format] == "json"
          final_pay=[]
          final_pay<<@payment
          final_pay<<@payment.order.shipment
          render :json => final_pay.to_json, :text=>"payment sucess",:status => 201

        else
          respond_with(@payment) { |format| format.html { redirect_to admin_order_payments_path(@order) } }
        end
      end
      # To load the current order
      def load_order
        if !params[:format].nil? && params[:format] == "json"
          if session[:order_id]==nil
            current_user=Spree::User.find_by_authentication_token(params[:authentication_token])
            if current_user.present?
              current_order = Spree::Order.find_by_number(params[:order_id])
              if current_order.present?
                payment=Spree::Payment.find_by_order_id(current_order.id)
                if payment.present?
                  @order=current_order
                else
                  error = error_response_method($e15)
                  render :json => error
                end
              else
                error = error_response_method($e24)
                render :json => error
              end
            else
              error = error_response_method($e13)
              render :json => error
            end
          end
        else
          @order ||= Spree::Order.find_by_number! params[:order_id]
          #end
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
      def check_http_authorization
        if !params[:format].nil? && params[:format] == "json"
          if params[:authentication_token].present?
            user=Spree::User.find_by_authentication_token(params[:authentication_token])
            if user.present?
              role=user.roles
              r=role.map(&:name)
              if user.roles.empty?&&r!='admin'
                error = error_response_method($e12)
                render :json => error
              end
            else
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
  end
end