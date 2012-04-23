  Admin::ReportsController.class_eval do
		def current_ability
    user= current_user || User.find_by_authentication_token(params[:authentication_token])
    @current_ability ||= Ability.new(user)
  end
	def best_selling_products
	  return_data=Hash.new
	  prod_array=Array.new
	  best=ActiveRecord::Base.connection.execute("Select A.id,A.name,sum(C.quantity) qty from products A, variants B, line_items C,orders D where A.id=B.product_id and B.id=C.variant_id and C.order_id=D.id and D.payment_state in ('paid','completed','payment','complete') group by A.id,A.name order by 3,1")
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
	
	def gross_selling_products
	  return_data=Hash.new
	  prod_array=Array.new
	  best=ActiveRecord::Base.connection.execute("Select A.id,A.name,sum(B.cost_price * C.quantity) amount from products A, variants B, line_items C,orders D where A.id=B.product_id and B.id=C.variant_id and C.order_id=D.id and D.payment_state in ('paid','completed','payment','complete') group by A.id,A.name order by 3,1")
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
	
def top_spenders
	 return_data=Hash.new
	  prod_array=Array.new
	  best=ActiveRecord::Base.connection.execute("Select A.id,A.email,sum(C.quantity),sum(B.cost_price * C.quantity) from users A, variants B, line_items C, orders D where A.id=D.user_id and B.id=C.variant_id and C.order_id=D.id and D.payment_state in ('paid','completed','payment','complete') group by A.id,A.email order by 4,1")
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
	def  recent_orders
		 return_data=Hash.new
	  prod_array=Array.new
	  best=ActiveRecord::Base.connection.execute("Select A.id,A.email,D.id,D.number,D.created_at,D.total from users A, orders D where A.id=D.user_id and D.payment_state in ('paid','completed','payment','complete') order by 4,3")
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
def out_of_stock
	 return_data=Hash.new
	  prod_array=Array.new
	  best=ActiveRecord::Base.connection.execute("Select A.id,A.name,B.count_on_hand from products A, variants B where A.id=B.product_id and B.count_on_hand <=0 order by 1,2")
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
def day_order_count
	 return_data=Hash.new
	  prod_array=Array.new
	  best=ActiveRecord::Base.connection.execute("Select DATE(created_at),count(*) from orders where payment_state in ('paid','completed','payment','complete') group by DATE(created_at) order by 1 DESC")
	  best.each do |pr|
		  prod_dtl=Hash.new
		  prod_dtl[:order_date]=pr[0]
		  prod_dtl[:order_count]=pr[1]
		  prod_array.push prod_dtl
	  end
	  return_data[:orders] = prod_array
	  render :json => return_data.to_json, :status => 201
end
def day_order_value
	 return_data=Hash.new
	  prod_array=Array.new
	  best=ActiveRecord::Base.connection.execute("Select DATE(created_at),sum(total) from orders where payment_state in ('paid','completed','payment','complete') group by DATE(created_at) order by 1 DESC")
	  best.each do |pr|
		  prod_dtl=Hash.new
		  prod_dtl[:order_date]=pr[0]
		  prod_dtl[:total_order_value]=pr[1]
		  prod_array.push prod_dtl
	  end
	  return_data[:orders] = prod_array
	  render :json => return_data.to_json, :status => 201
end
def month_order_value
	 return_data=Hash.new
	  prod_array=Array.new
	  best=ActiveRecord::Base.connection.execute("Select Month(created_at),Year(created_at),sum(total) from orders where payment_state in ('paid','completed','payment','complete') group by Month(created_at),Year(created_at) order by 2 DESC ,1 DESC")
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
def month_order_count
	 return_data=Hash.new
	  prod_array=Array.new
	  best=ActiveRecord::Base.connection.execute("Select Month(created_at),Year(created_at),count(*) from orders where payment_state in ('paid','completed','payment','complete') group by Month(created_at),Year(created_at) order by 2 DESC ,1 DESC")
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
	
end