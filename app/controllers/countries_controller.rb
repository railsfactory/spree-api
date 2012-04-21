class CountriesController <Spree::BaseController
    include ApiHelper
   before_filter :set_current_user
  before_filter :access_denied, :except => [:index, :show,:create,:update,:delete]
  before_filter :check_http_authorization
  before_filter :load_resource
  skip_before_filter :verify_authenticity_token, :if => lambda { admin_token_passed_in_headers }
  authorize_resource
  
  respond_to :json

   def index
    respond_with(@collection) do |format|
      format.json { render :json => @collection.to_json(collection_serialization_options) }
    end
  end

  def show
    respond_with(@object) do |format|
      format.json { render :json => @object.to_json(object_serialization_options) }
    end
  end

  def create
    begin
    if @object.save
     # render :text => "Resource created\n", :status => 201, :location => object_url
     render :json => @object.to_json, :status => 201
      else
      #respond_with(@object.errors, :status => 422)
       error = error_response_method($e1)
      render :json => error
    end
    rescue Exception=>e
     #render :text => "#{e.message}", :status => 500
      error = error_response_method($e11)
      render :json => error
      end
  end

  def update
    begin
      if @object.update_attributes(params[object_name])
          render :json => @object.to_json, :status => 201
    else
      error = error_response_method($e1)
      render :json => error
      #respond_with(@object.errors, :status => 422)
    end
     rescue Exception=>e
      error = error_response_method($e11)
      render :json => error
     #render :text => "#{e.message}", :status => 500
      end

    end
 
  def admin_token_passed_in_headers
    request.headers['HTTP_AUTHORIZATION'].present?
  end

  def access_denied
    #render :text => 'access_denied', :status => 401
     error = error_response_method($e12)
      render :json => error
  end

  # Generic action to handle firing of state events on an object
  def event
    valid_events = model_class.state_machine.events.map(&:name)
    valid_events_for_object = @object ? @object.state_transitions.map(&:event) : []

    if params[:e].blank?
      errors = t('api.errors.missing_event')
    elsif valid_events_for_object.include?(params[:e].to_sym)
      @object.send("#{params[:e]}!")
      errors = nil
    elsif valid_events.include?(params[:e].to_sym)
      errors = t('api.errors.invalid_event_for_object', :events => valid_events_for_object.join(','))
    else
      errors = t('api.errors.invalid_event', :events => valid_events.join(','))
    end

    respond_to do |wants|
      wants.json do
        if errors.blank?
          render :nothing => true
        else
          #error = error_response_method($e10001)
          render :json => errors.to_json, :status => 422
          #render :json => error
        end
      end
    end
  end

  def error_response_method(error)
    @error = {}
    @error["code"]=error["status_code"]
    @error["message"]=error["status_message"]
    #@error["Code"] = error["error_code"]
    return @error
  end

  protected
    def model_class
      controller_name.classify.constantize
    end
    
    def object_name
      controller_name.singularize
    end
    
    def load_resource
      if member_action?
        @object ||= load_resource_instance
        instance_variable_set("@#{object_name}", @object)
      else
        @collection ||= collection
        instance_variable_set("@#{controller_name}", @collection)
      end
    end
    
    def load_resource_instance
      if new_actions.include?(params[:action].to_sym)
      build_resource
      elsif params[:id]
        find_resource
      end
    end
    
    def parent
      nil
    end

    def find_resource
      begin
        if parent.present?
          parent.send(controller_name).find(params[:id])
      else
        model_class.includes(eager_load_associations).find(params[:id])
      end
      rescue Exception => e
       error = error_response_method($e2)
      render :json => error
    #render :text => "Resource not found (#{e.message})", :status => 500
      end
    end
    
    def build_resource
      begin
      if parent.present?
      parent.send(controller_name).build(params[object_name])
      else
      model_class.new(params[object_name])
      end
      rescue Exception=> e
       error = error_response_method($e11)
      render :json => error
      #render :text => " #{e.message}", :status => 500
      end
    end
    
    def collection
          return @search unless @search.nil?      
      params[:search] = {} if params[:search].blank?
      params[:search][:meta_sort] = 'created_at.desc' if params[:search][:meta_sort].blank?
      
      scope = parent.present? ? parent.send(controller_name) : model_class.scoped
     
      @search = scope.metasearch(params[:search]).relation.limit(100)
      @search
    end

    def collection_serialization_options
      {}
    end

    def object_serialization_options
      {}
    end

    def eager_load_associations
      nil
    end

    def object_errors
      {:errors => object.errors.full_messages}
    end

  def object_url(object = nil, options = {})
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
    end
    
    def collection_actions
      [:index]
    end

    def member_action?
      !collection_actions.include? params[:action].to_sym
    end

    def new_actions
      [:new, :create]
    end

  private
  def check_http_authorization
    #~ if request.headers['HTTP_AUTHORIZATION'].blank?
      #~ render :text => "Access Denied\n", :status => 401
    #~ end
      if current_user.authentication_token!=params[:authentication_token]
      # if request.headers['HTTP_AUTHORIZATION'].blank?
        #render :text => "Access Denied\n", :status => 401
         error = error_response_method($e13)
      render :json => error
    end if current_user
  end
end
