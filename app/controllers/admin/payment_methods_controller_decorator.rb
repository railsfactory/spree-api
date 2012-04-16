Admin::TaxRatesController.class_eval do
  $e1={"status_code"=>"500","status_message"=>"Your request parameters are incorrect."}
$e2={"status_code"=>"500","status_message"=>"Record not found"}
$e3={"status_code"=>"500","status_message"=>"Payment failed check the details entered"}
$e4={"status_code"=>"200","status_message"=>"destroyed"}
$e5={"status_code"=>"202","status_message"=>"Undefined method request check the url"}
     require 'spree_core/action_callbacks'
  before_filter :check_http_authorization
  before_filter :load_resource
  skip_before_filter :verify_authenticity_token, :if => lambda { admin_token_passed_in_headers }
  authorize_resource
  attr_accessor :parent_data
  attr_accessor :callbacks
  helper_method :new_object_url, :edit_object_url, :object_url, :collection_url
 # respond_to :html
  respond_to :js, :except => [:show, :index]
   def index
     if !params[:format].nil? && params[:format] == "json"
					respond_with(@collection) do |format|
      format.html
      format.json { render :json => @collection}
			end
			else
				@payments = @order.payments

    respond_with(@payments)
    end

  end
   def collection
       if !params[:format].nil? && params[:format] == "json"
          return @search unless @search.nil?      
      params[:search] = {} if params[:search].blank?
      params[:search][:meta_sort] = 'created_at.desc' if params[:search][:meta_sort].blank?
      
      scope = parent.present? ? parent.send(controller_name) : model_class.scoped
     
      @search = scope.metasearch(params[:search]).relation.limit(100)
      @search
      else
          return parent.send(controller_name) if parent_data.present?

    if model_class.respond_to?(:accessible_by) && !current_ability.has_block?(params[:action], model_class)
      model_class.accessible_by(current_ability)
    else
      model_class.scoped
    end
		end
    end
    def collection_serialization_options
     if !params[:format].nil? && params[:format] == "json"
      {}
      end
    end

    def object_serialization_options
       if !params[:format].nil? && params[:format] == "json"
      {}
      end
    end

    def eager_load_associations
       if !params[:format].nil? && params[:format] == "json"
      nil
      end
    end

    def object_errors
       if !params[:format].nil? && params[:format] == "json"
      {:errors => object.errors.full_messages}
      end
    end
  def object_url(object = nil, options = {})
     if !params[:format].nil? && params[:format] == "json"
      target = object ? object : @object
      if parent.present? && object_name == "state"
          send "api_country_#{object_name}_url", parent, target, options
      elsif parent.present? && object_name == "taxon"
          send "api_taxonomy_#{object_name}_url", parent, target, options
      elsif parent.present?
          send "api_#{parent[:model_name]}_#{object_name}_url", parent, target, options
      else
        send "api_#{object_name}_url",parent, target, options
      end
      else
          target = object ? object : @object
    if parent_data.present?
      send "admin_#{parent_data[:model_name]}_#{object_name}_url", parent, target, options
    else
      send "admin_#{object_name}_url", target, options
    end
      end
    end
     def collection_url(options = {})
    if parent_data.present?
      polymorphic_url([:admin, parent, model_class], options)
    else
      polymorphic_url([:admin, model_class], options)
    end
  end
  private
  def check_http_authorization
         if !params[:format].nil? && params[:format] == "json"
      if current_user.authentication_token!=params[:authentication_token]
        render :text => "Access Denied\n", :status => 401
    end if current_user
  end
end  
  
  
  
  
  
  end