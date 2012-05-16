Spree::OrdersController.class_eval do
  $e1={"status_code"=>"2038","status_message"=>"parameter errors"}
  $e52={"status_code"=>"2052","status_message"=>"quantity cannot be negative"}
  $e2={"status_code"=>"2037","status_message"=>"Record not found"}
  $e3={"status_code"=>"2036","status_message"=>"Payment failed check the details entered"}
  $e4={"status_code"=>"2035","status_message"=>"destroyed"}
  $e5={"status_code"=>"2030","status_message"=>"Undefined method request check the url"}
  before_filter :check_http_authorization
  before_filter :load_resource
  respond_to :json
  #To set current user
  def set_current_user
    Spree::User.current = current_user
  end
  #To set and find current user
  def current_ability
    if !params[:format].nil? && params[:format] == "json"
      user= current_user || Spree::User.find_by_authentication_token(params[:authentication_token])

      @current_ability ||= Spree::Ability.new(user)
    else
      @current_ability ||= Spree::Ability.new(current_user)
    end
  end
  #To display the order list
  def index
    respond_with(@collection) do |format|
      format.json { render :json => @collection.to_json(collection_serialization_options) }
    end
  end
  # To display particular order
  def show
    if !params[:format].nil? && params[:format] == "json"
      respond_with(@object) do |format|
        format.json { render :json => @object.to_json(object_serialization_options) }
      end
    else
      @order = Spree::Order.find_by_number(params[:id])
    end
  end
  #To display the error message
  def error_response_method(error)
    @error = {}
    @error["code"]=error["status_code"]
    @error["message"]=error["status_message"]
    return @error
  end
  #To update the order
  def update
    if !params[:format].nil? && params[:format] == "json"
      if !params[:line_item].nil?
        if !params[:line_item][:quantity].nil?&&!params[:line_item][:variant_id].nil?
          quantity = params[:line_item][:quantity].to_i

          if (quantity <=> 0) >= 0
            @variant = Spree::Variant.find_by_id(params[:line_item][:variant_id])
            if !@variant.nil?
              @order = Spree::Order.find_by_param(params[:id])
              if @order.present?
                @order.add_variant(@variant, quantity.to_i) if quantity.to_i > 0
                @response = Spree::Order.find_by_id(@order.id)
                render :json => @response.to_json, :status => 201
              else
                error=error_response_method($e2)
                render:json=>error
              end
            else
              error=error_response_method($e2)
              render:json=>error
            end
          else
            error=error_response_method($e52)
            render:json=>error
          end
        else
          error=error_response_method($e1)
          render:json=>error
        end
      else
        error = error_response_method($e1)
        render :json => error
      end
    else
      @order = current_order
      if @order.update_attributes(params[:order])
        @order.line_items = @order.line_items.select {|li| li.quantity > 0 }
        respond_with(@order) { |format| format.html { redirect_to cart_path } }
      else
        respond_with(@order)
      end
    end
  end
  #To delete the order
  def destroy
    @object=Spree::Order.find_by_id(params[:id])
    if !@object.nil?
      @object.destroy
      if @object.destroy
        error=error_response_method($e4)
        render:json=>error
      end
    else
      error=error_response_method($e2)
      render:json=>error
    end
  end
  protected
  def model_class
    if !params[:format].nil? && params[:format] == "json"
      "Spree::#{controller_name.classify}".constantize
    end
  end

  def object_name
    if !params[:format].nil? && params[:format] == "json"
      controller_name.singularize
    end
  end
  #To load resource
  def load_resource
    if !params[:format].nil? && params[:format] == "json"
      if member_action?
        @object ||= load_resource_instance
        instance_variable_set("@#{object_name}", @object)
      else
        @collection ||= collection
        instance_variable_set("@#{controller_name}", @collection)
      end
    end
  end
  # To collect the data for index
  def collection
    if !params[:format].nil? && params[:format] == "json"
      return @search unless @search.nil?
      params[:search] = {} if params[:search].blank?
      params[:search][:meta_sort] = 'created_at.desc' if params[:search][:meta_sort].blank?

      scope = parent.present? ? parent.send(controller_name) : model_class.scoped

      @search = scope
      @search
    end
  end
  #To load resource instance
  def load_resource_instance
    if !params[:format].nil? && params[:format] == "json"
      if new_actions.include?(params[:action].to_sym)
        build_resource
      elsif params[:id]
        find_resource
      end
    end
  end
  #To find the parent record
  def parent
    if !params[:format].nil? && params[:format] == "json"
      nil
    end
  end
  #To find the data or record during edit and update method
  def find_resource
    if !params[:format].nil? && params[:format] == "json"
      begin
        if parent.present?
          parent.send(controller_name).find(params[:id])
        else
          model_class.includes(eager_load_associations).find(params[:id])
        end
      rescue Exception => e
        error = error_response_method($e2)
        render :json => error
      end
    end
  end

  def collection_serialization_options
    if !params[:format].nil? && params[:format] == "json"
      {}
    end
  end

  def eager_load_associations
    if !params[:format].nil? && params[:format] == "json"
      nil
    end
  end

  def collection_actions
    if !params[:format].nil? && params[:format] == "json"
      [:index]
    end
  end

  def member_action?
    if !params[:format].nil? && params[:format] == "json"
      !collection_actions.include? params[:action].to_sym
    end
  end

  def new_actions
    if !params[:format].nil? && params[:format] == "json"
      [:new, :create]
    end
  end

  private
  def check_http_authorization
    if !params[:format].nil? && params[:format] == "json"
      if params[:authentication_token].present?
        user=Spree::User.find_by_authentication_token(params[:authentication_token])
        if user.present?
          #~ role=Spree::.find_by_id(user.id)
          if !user.roles
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
  #To find data
  def find_resource
    Spree::Order.find_by_param(params[:id])
  end

  def object_serialization_options
    { :include => {
        :bill_address => {:include => [:country, :state]},
        :ship_address => {:include => [:country, :state]},
        :shipments => {:include => [:shipping_method, :address]},
        :line_items => {:include => [:variant]}
      }
    }
  end
end
