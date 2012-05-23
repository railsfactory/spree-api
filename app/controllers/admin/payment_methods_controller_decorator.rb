module Spree
  module Admin
PaymentMethodsController.class_eval do
	require 'spree/core/action_callbacks'
  before_filter :check_http_authorization
  skip_before_filter :load_resource, :only => [:create]
  before_filter :load_data
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
  #To display the payment methods
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
         @payment_method = params[:payment_method].delete(:type).constantize.new(params[:payment_method])
        @object = @payment_method
        invoke_callbacks(:create, :before)
        if @payment_method.save
          invoke_callbacks(:create, :after)
          render :json => @payment_method.to_json, :status => 201
        else
          error = error_response_method($e1)
          render :json => error
        end
      rescue Exception=>e
        error = error_response_method($e11)
        render :json => error
      end
    else
    @payment_method = params[:payment_method].delete(:type).constantize.new(params[:payment_method])
        @object = @payment_method
        invoke_callbacks(:create, :before)
        if @payment_method.save
          invoke_callbacks(:create, :after)
          flash.notice = I18n.t(:successfully_created, :resource => I18n.t(:payment_method))
          respond_with(@payment_method, :location => edit_admin_payment_method_path(@payment_method))
        else
          invoke_callbacks(:create, :fails)
          respond_with(@payment_method)
        end
    end
  end
#To update the existing record
  def update
    if !params[:format].nil? && params[:format] == "json"
      begin
        invoke_callbacks(:update, :before)
        payment_method_type = params[:payment_method].delete(:type)
        if @payment_method['type'].to_s != payment_method_type
          @payment_method.update_attribute(:type, payment_method_type)
          @payment_method = Spree::PaymentMethod.find(params[:id])
        end
        payment_method_params = params[@payment_method.class.name.underscore.gsub("/", "_")] || {}
        if @object.update_attributes(params[object_name])
          render :json => @object.to_json, :status => 201
        else
          error = error_response_method($e1)
          render :json => error
        end
      rescue Exception=>e
        error = error_response_method($e11)
        render :json => error
      end
    else
      invoke_callbacks(:update, :before)
      payment_method_type = params[:payment_method].delete(:type)
      if @payment_method['type'].to_s != payment_method_type
        @payment_method.update_attribute(:type, payment_method_type)
        @payment_method = Spree::PaymentMethod.find(params[:id])
      end
      payment_method_params = params[@payment_method.class.name.underscore.gsub("/", "_")] || {}
      if @payment_method.update_attributes(params[:payment_method].merge(payment_method_params))
        invoke_callbacks(:update, :after)
        flash[:notice] = I18n.t(:successfully_updated, :resource => I18n.t(:payment_method))
        respond_with(@payment_method, :location => edit_admin_payment_method_path(@payment_method))
      else
        invoke_callbacks(:update, :fails)
        respond_with(@payment_method)
      end
    end
  end
  #To destroy existing record
  def destroy
    if !params[:format].nil? && params[:format] == "json"
      @object=Spree::PaymentMethod.find_by_id(params[:id])
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
    else
      invoke_callbacks(:destroy, :before)
      if @object.destroy
        invoke_callbacks(:destroy, :after)
        flash[:notice] = flash_message_for(@object, :successfully_removed)
        respond_with(@object) do |format|
          format.html { redirect_to collection_url }
          format.js   { render :partial => "spree/admin/shared/destroy" }
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
  def model_class
    "Spree::#{controller_name.classify}".constantize
  end
    
  def object_name
    controller_name.singularize
  end
  #To load resource for listing and editing
  def load_resource
    if member_action?
      @object ||= load_resource_instance
      instance_variable_set("@#{object_name}", @object)
    else
      @collection ||= collection
      instance_variable_set("@#{controller_name}", @collection)
    end
  end
     #To load resource insatnce  for creating and finding
  def load_resource_instance
    if new_actions.include?(params[:action].to_sym)
      build_resource
    elsif params[:id]
      find_resource
    end
  end
    #To find the parent
  def parent
    if !params[:format].nil? && params[:format] == "json"
      nil
    else
      self.class.parent_data
    end
  end
#To find the data while updating and listing
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
  #To build new resources
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
         if !params[:format].nil? && params[:format] == "json"
      if params[:authentication_token].present?
        user=Spree::User.find_by_authentication_token(params[:authentication_token])
        if user.present?
          #~ role=Spree::.find_by_id(user.id)
          role=user.role
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