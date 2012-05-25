Spree::Core::CurrentOrder.module_eval do
   # This should be overridden by an auth-related extension which would then have the
      # opportunity to associate the new order with the # current user before saving.
      def before_save_new_order
      end

      # This should be overridden by an auth-related extension which would then have the
      # opporutnity to store tokens, etc. in the session # after saving.
      def after_save_new_order
      end

  # Associate the new order with the currently authenticated user before saving
  def current_order(create_order_if_necessary = false,auth=nil)
    if !params[:format].nil? && params[:format] == "json" 
      if  @current_order.nil?
        @current_order = Spree::Order.new
        #before_save_new_order(auth)
        user=Spree::User.find_by_authentication_token(auth)
        @current_order.email = user.email
        @current_order.user_id=user.id
        @current_order.api=1
        @current_order.save()
        #@current_order.send(:create_without_callbacks)
        return @current_order
        #after_save_new_order
      else
        user=Spree::User.find_by_authentication_token(auth)
        @current_order = Order.find_by_user_id(user.id)
      end
    else
      return @current_order if @current_order
      if session[:order_id]
        @current_order = Spree::Order.find_by_id(session[:order_id], :include => :adjustments)
      end
      if create_order_if_necessary and (@current_order.nil? or @current_order.completed?)
        @current_order = Spree::Order.new
        before_save_new_order
        @current_order.save!
        after_save_new_order
      end
      session[:order_id] = @current_order ? @current_order.id : nil
      @current_order
    end
  end
end
