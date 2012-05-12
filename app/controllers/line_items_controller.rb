class LineItemsController< Spree::BaseController
  $e1={"status_code"=>"2038","status_message"=>"parameter errors"}
  $e2={"status_code"=>"2037","status_message"=>"Record not found"}
  $e3={"status_code"=>"2036","status_message"=>"Payment failed check the details entered"}
  $e4={"status_code"=>"2035","status_message"=>"destroyed"}
  $e5={"status_code"=>"2030","status_message"=>"Undefined method request check the url"}
#To set current user
  def current_ability
    user= current_user || Spree::User.find_by_authentication_token(params[:authentication_token])
    @current_ability ||= Ability.new(user)
  end
#To create line_item
  def create
    if !params[:line_item].nil?
      if !params[:line_item][:quantity].nil?&&!params[:line_item][:variant_id].nil?
        quantity = params[:line_item][:quantity].to_i
          if (quantity <=> 0) >= 0
        @variant = Spree::Variant.find_by_id(params[:line_item][:variant_id])
        if !@variant.nil?
          user=Spree::User.find_by_authentication_token(params[:authentication_token])
          if user.present?
            @order = current_order(true,params[:authentication_token])
            @order.add_variant(@variant, quantity.to_i) if quantity.to_i > 0
            @response = Spree::Order.find_by_id(@order.id)
            render :json => @response.to_json, :status => 201
          else
            error=error_response_method($e13)
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

  end
  #To display error message
  def error_response_method(error)
    @error = {}
    @error["code"]=error["status_code"]
    @error["message"]=error["status_message"]
    return @error
  end
  protected
  def model_class
    if !params[:format].nil? && params[:format] == "json"
      controller_name.classify.constantize
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
  #To Collect data to list
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
  #To load resource for creating or finding
  def load_resource_instance
    if !params[:format].nil? && params[:format] == "json"
      if new_actions.include?(params[:action].to_sym)
        build_resource
      elsif params[:id]
        find_resource
      end
    end
  end
    #To find the parent
  def parent
    if !params[:format].nil? && params[:format] == "json"
      nil
    end
  end
#To find the record 
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
  def parent
    if params[:order_id]
      @parent ||= Order.find_by_param(params[:order_id])
    end
  end
  
  def parent_data
    params[:order_id]
  end
    
  def collection_serialization_options
    { :include => [:variant], :methods => [:description] }
  end

  def object_serialization_options
    collection_serialization_options
  end
  
  def check_http_authorization
    if !params[:format].nil? && params[:format] == "json"
      if current_user.authentication_token!=params[:authentication_token]
        error = error_response_method($e13)
        render :json => error
      end if current_user
    end
  end
end
