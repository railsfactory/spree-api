module Spree
  module Admin
VariantsController.class_eval do
  $e1={"status_code"=>"500","status_message"=>"Your request parameters are incorrect."}
  $e2={"status_code"=>"500","status_message"=>"Record not found"}
  $e3={"status_code"=>"500","status_message"=>"Payment failed check the details entered"}
  $e4={"status_code"=>"200","status_message"=>"destroyed"}
  $e5={"status_code"=>"202","status_message"=>"Undefined method request check the url"}
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
#To create new record
  def new
    respond_with(@object) do |format|
      format.html { render :layout => !request.xhr? }
      format.js { render :layout => false }
    end
  end
  #To display the record
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
        invoke_callbacks(:create, :before)
        if @object.save
          invoke_callbacks(:create, :after)
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
        invoke_callbacks(:update, :before)
        if @object.update_attributes(params[object_name])
          invoke_callbacks(:update, :after)
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
      @object=Spree::Variant.find_by_id(params[:id])
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
      @variant = Spree::Variant.find(params[:id])
      @variant.deleted_at = Time.now()
      if @variant.save
        flash.notice = I18n.t("notice_messages.variant_deleted")
      else
        flash.notice = I18n.t("notice_messages.variant_not_deleted")
      end
      respond_with(@variant) do |format|
        format.html { redirect_to admin_product_variants_url(params[:product_id]) }
        format.js  { render_js_for_destroy }
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
      p @object
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
  def parent_data
         self.class.parent_data
  end
  #To find the parent
  def parent
       if parent_data.present?
      @parent ||= parent_data[:model_class].where(parent_data[:find_by] => params["#{model_name}_id"]).first
      instance_variable_set("@#{model_name}", @parent)
    else
      nil
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
        p parent
      else
        model_class.find(params[:id])
        p model_class
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
  def location_after_save
    collection_url
  end
  def invoke_callbacks(action, callback_type)
    callbacks = self.class.callbacks || {}
    return if callbacks[action].nil?
    case callback_type.to_sym
    when :before then callbacks[action].before_methods.each {|method| send method }
    when :after  then callbacks[action].after_methods.each  {|method| send method }
    when :fails  then callbacks[action].fails_methods.each  {|method| send method }
    end
  end

  # URL helpers
  def new_object_url(options = {})
    if parent_data.present?
      new_polymorphic_url([:admin, parent, model_class], options)
    else
      new_polymorphic_url([:admin, model_class], options)
    end
  end
  def edit_object_url(object, options = {})
    if parent_data.present?
      send "edit_admin_#{parent_data[:model_name]}_#{object_name}_url", parent, object, options
    else
      send "edit_admin_#{object_name}_url", object, options
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
