module Spree
  module Admin
    ReportsController.class_eval do
      before_filter :check_http_authorization
      #To set current user
      def current_ability
        user= current_user || Spree::User.find_by_authentication_token(params[:authentication_token])
        @current_ability ||= Spree::Ability.new(user)
			end
			#To find best_selling_products
      def best_selling_products
        return_data=Hash.new
        prod_array=Array.new
        best=ActiveRecord::Base.connection.execute("Select A.id,A.name,sum(C.quantity) qty from spree_products A, spree_variants B, spree_line_items C,spree_orders D where A.id=B.product_id and B.id=C.variant_id and C.order_id=D.id and D.payment_state in ('paid','completed','payment','complete') group by A.id,A.name order by 3,1")
        best.each do |pr|
          prod_dtl=Hash.new
          prod_dtl[:id]=pr[0]
          prod_dtl[:name]=pr[1]
          prod_dtl[:qty]=pr[2]
          prod_array.push prod_dtl
        end
        return_data[:products] = prod_array
        render :json => return_data.to_json, :status => 201
      end
      #To find gross_selling_products
      def gross_selling_products
        return_data=Hash.new
        prod_array=Array.new
        best=ActiveRecord::Base.connection.execute("Select A.id,A.name,sum(B.cost_price * C.quantity) amount from spree_products A, spree_variants B, spree_line_items C,spree_orders D where A.id=B.product_id and B.id=C.variant_id and C.order_id=D.id and D.payment_state in ('paid','completed','payment','complete') group by A.id,A.name order by 3,1")
        best.each do |pr|
          prod_dtl=Hash.new
          prod_dtl[:id]=pr[0]
          prod_dtl[:name]=pr[1]
          prod_dtl[:amount]=pr[2]
          prod_array.push prod_dtl
        end
        return_data[:products] = prod_array
        render :json => return_data.to_json, :status => 201
      end
      #To find top_spenders
      def top_spenders
        return_data=Hash.new
        prod_array=Array.new
        best=ActiveRecord::Base.connection.execute("Select A.id,A.email,sum(C.quantity),sum(B.cost_price * C.quantity) from spree_users A, spree_variants B, spree_line_items C, spree_orders D where A.id=D.user_id and B.id=C.variant_id and C.order_id=D.id and D.payment_state in ('paid','completed','payment','complete') group by A.id,A.email order by 4,1")
        best.each do |pr|
          prod_dtl=Hash.new
          prod_dtl[:id]=pr[0]
          prod_dtl[:email]=pr[1]
          prod_dtl[:qty]=pr[2]
          prod_dtl[:value]=pr[3]
          prod_array.push prod_dtl
        end
        return_data[:spenders] = prod_array
        render :json => return_data.to_json, :status => 201
      end
      #To find recent_orders
      def  recent_orders
        return_data=Hash.new
        prod_array=Array.new
        best=ActiveRecord::Base.connection.execute("Select A.id,A.email,D.id,D.number,D.created_at,D.total from spree_users A, spree_orders D where A.id=D.user_id and D.payment_state in ('paid','completed','payment','complete') order by 4,3")
        best.each do |pr|
          prod_dtl=Hash.new
          prod_dtl[:user_id]=pr[0]
          prod_dtl[:email]=pr[1]
          prod_dtl[:order_id]=pr[2]
          prod_dtl[:order_number]=pr[3]
          prod_dtl[:order_date]=pr[4]
          prod_dtl[:order_total]=pr[5]
          prod_array.push prod_dtl
        end
        return_data[:orders] = prod_array
        render :json => return_data.to_json, :status => 201
      end
      #To find out_of_stock
      def out_of_stock
        return_data=Hash.new
        prod_array=Array.new
        best=ActiveRecord::Base.connection.execute("Select A.id,A.name,B.count_on_hand from spree_products A, spree_variants B where A.id=B.product_id and B.count_on_hand <=0 order by 1,2")
        best.each do |pr|
          prod_dtl=Hash.new
          prod_dtl[:id]=pr[0]
          prod_dtl[:name]=pr[1]
          prod_dtl[:count_on_hand]=pr[2]
          prod_array.push prod_dtl
        end
        return_data[:products] = prod_array
        render :json => return_data.to_json, :status => 201
      end
      #To find day_order_count
      def day_order_count
        return_data=Hash.new
        prod_array=Array.new
        best=ActiveRecord::Base.connection.execute("Select DATE(created_at),count(*) from spree_orders where payment_state in ('paid','completed','payment','complete') group by DATE(created_at) order by 1 DESC")
        best.each do |pr|
          prod_dtl=Hash.new
          prod_dtl[:order_date]=pr[0]
          prod_dtl[:order_count]=pr[1]
          prod_array.push prod_dtl
        end
        return_data[:orders] = prod_array
        render :json => return_data.to_json, :status => 201
      end
      #To find day_order_value
      def day_order_value
        return_data=Hash.new
        prod_array=Array.new
        best=ActiveRecord::Base.connection.execute("Select DATE(created_at),sum(total) from spree_orders where payment_state in ('paid','completed','payment','complete') group by DATE(created_at) order by 1 DESC")
        best.each do |pr|
          prod_dtl=Hash.new
          prod_dtl[:order_date]=pr[0]
          prod_dtl[:total_order_value]=pr[1]
          prod_array.push prod_dtl
        end
        return_data[:orders] = prod_array
        render :json => return_data.to_json, :status => 201
      end
      #To find month order value
      def month_order_value
        return_data=Hash.new
        prod_array=Array.new
        best=ActiveRecord::Base.connection.execute("Select Month(created_at),Year(created_at),sum(total) from spree_orders where payment_state in ('paid','completed','payment','complete') group by Month(created_at),Year(created_at) order by 2 DESC ,1 DESC")
        best.each do |pr|
          prod_dtl=Hash.new
          prod_dtl[:order_month]=pr[0]
          prod_dtl[:order_year]=pr[1]
          prod_dtl[:total_order_value]=pr[2]
          prod_array.push prod_dtl
        end
        return_data[:orders] = prod_array
        render :json => return_data.to_json, :status => 201
      end
      #To find month order count
      def month_order_count
        return_data=Hash.new
        prod_array=Array.new
        best=ActiveRecord::Base.connection.execute("Select Month(created_at),Year(created_at),count(*) from spree_orders where payment_state in ('paid','completed','payment','complete') group by Month(created_at),Year(created_at) order by 2 DESC ,1 DESC")
        best.each do |pr|
          prod_dtl=Hash.new
          prod_dtl[:order_month]=pr[0]
          prod_dtl[:order_year]=pr[1]
          prod_dtl[:order_count]=pr[2]
          prod_array.push prod_dtl
        end
        return_data[:orders] = prod_array
        render :json => return_data.to_json, :status => 201
      end
      #To display the error message
      def error_response_method(error)
        if !params[:format].nil? && params[:format] == "json"
          @error = { }
          @error["code"]=error["status_code"]
          @error["message"]=error["status_message"]
          return @error
        end
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