module Spree
  module Admin
PromotionsController.class_eval do
  $e1={"status_code"=>"2038","status_message"=>"parameter errors"}
  $e2={"status_code"=>"2037","status_message"=>"Record not found"}
  $e3={"status_code"=>"2036","status_message"=>"Payment failed check the details entered"}
  $e4={"status_code"=>"2035","status_message"=>"destroyed"}
  $e5={"status_code"=>"2030","status_message"=>"Undefined method request check the url"}
  $e26={"status_code"=>"2062","status_message"=>"please enter valid date"}
  require 'spree/core/action_callbacks'
  before_filter :check_http_authorization
  before_filter :load_resource
  #skip_before_filter :verify_authenticity_token, :if => lambda { admin_token_passed_in_headers }
  #authorize_resource
  attr_accessor :parent_data
  attr_accessor :callbacks
  helper_method :new_object_url, :edit_object_url, :object_url, :collection_url
  respond_to :js, :except => [:show, :index]
  	#To set current user
  def current_ability
    user= current_user || Spree::User.find_by_authentication_token(params[:authentication_token])
        @current_ability ||= Ability.new(user)
      end
      #To list the datas  
  def index
    if !params[:format].nil? && params[:format] == "json"
      respond_with(@collection) do |format|
        format.html
        format.json { render :json => @collection}
      end
    end
  end
   #To display the record
  def show
    if !params[:format].nil? && params[:format] == "json"
      respond_with(@object) do |format|
        format.json { render :json => @object.to_json(object_serialization_options) }
      end
    end
  end
#To create new record
  def create
       if !params[:format].nil? && params[:format] == "json"
      begin
              if @object.starts_at.to_date>=Date.today && @object.expires_at.to_date>Date.today
                   if @object.save
            render :json => @object.to_json, :status => 201
          else
            error = error_response_method($e1)
            render :json => error
          end
        else
                   error = error_response_method($e26)
          render :json => error
        end
      rescue Exception=>e
               error = error_response_method($e11)
        render :json => error
      end
    else
      invoke_callbacks(:create, :before)
           if @object.save
        if controller_name == "taxonomies"
          @object.create_image(:attachment=>params[:taxon][:attachement])
        end
        invoke_callbacks(:create, :after)
        flash[:notice] = flash_message_for(@object, :successfully_created)
        respond_with(@object) do |format|
          format.html { redirect_to location_after_save }
          format.js   { render :layout => false }
        end
      else
        invoke_callbacks(:create, :fails)
        respond_with(@object)
      end
    end
  end
 #To update the existing record
  def update
    if !params[:format].nil? && params[:format] == "json"
      begin
               if params[:promotion][:starts_at].to_date>=Date.today && params[:promotion][:expires_at].to_date>Date.today
          if @object.update_attributes(params[object_name])
            render :json => @object.to_json, :status => 201
          else
            error = error_response_method($e1)
            render :json => error
                      end
        else
                  error = error_response_method($e26)
          render :json => error
        end
      rescue Exception=>e
               error = error_response_method($e11)
        render :json => error
      end
    else
           invoke_callbacks(:update, :before)
      if controller_name == "taxonomies"
        @image_object=@object.image
        @image_object.update_attributes(:attachment => params[:taxon][:attachement])
      end

      if @object.update_attributes(params[object_name])
        invoke_callbacks(:update, :after)
        flash[:notice] = flash_message_for(@object, :successfully_updated)
        respond_with(@object) do |format|
          format.html { redirect_to location_after_save }
          format.js   { render :layout => false }
        end
      else
        invoke_callbacks(:update, :fails)
        respond_with(@object)
      end
    end
  end
  #To destroy existing record
  def destroy
    if !params[:format].nil? && params[:format] == "json"
      @object=Spree::Promotion.find_by_id(params[:id])
      if !@object.nil?
        @object.destroy
        if @object.destroy
          render :text => 'Destroyed'
        end
      else
        error=error_response_method($e2)
        render:json=>error
      end
    else
      invoke_callbacks(:destroy, :before)
      if @object.destroy
        invoke_callbacks(:destroy, :after)
        flash[:notice] = flash_message_for(@object, :successfully_removed)
        respond_with(@object) do |format|
          format.html { redirect_to collection_url }
          format.js   { render :partial => "/admin/shared/destroy" }
        end
      else
        invoke_callbacks(:destroy, :fails)
        respond_with(@object) do |format|
          format.html { redirect_to collection_url }
        end
      end
    end
  end
 
  def admin_token_passed_in_headers
    if !params[:format].nil? && params[:format] == "json"
      request.headers['HTTP_AUTHORIZATION'].present?
    end
  end
#To check access
  def access_denied
    if !params[:format].nil? && params[:format] == "json"
           error = error_response_method($e12)
      render :json => error
    end
  end

  # Generic action to handle firing of state events on an object
  def event
    if !params[:format].nil? && params[:format] == "json"
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
                      render :json => errors.to_json, :status => 422
                     end
        end
      end
    end
  end
  #To display the error message
  def error_response_method(error)
    if !params[:format].nil? && params[:format] == "json"
      @error = {}
      @error["code"]=error["status_code"]
      @error["message"]=error["status_message"]
            return @error
    end
  end

  protected
  #To load resource for listing and editing
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
    else
      if parent_data.present?
        parent.send(controller_name).find(params[:id])
      else
        model_class.find(params[:id])
      end
    end
  end
  #To collect the list of datas
  def collection
    if !params[:format].nil? && params[:format] == "json"
      return @search unless @search.nil?
      params[:search] = {} if params[:search].blank?
      params[:search][:meta_sort] = 'created_at.desc' if params[:search][:meta_sort].blank?
            scope = parent.present? ? parent.send(controller_name) : model_class.scoped
           @search = scope
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
end
end
end