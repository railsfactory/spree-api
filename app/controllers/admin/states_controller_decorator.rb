Admin::StatesController.class_eval do
  $e1={"status_code"=>"2038","status_message"=>"parameter errors"}
$e2={"status_code"=>"2037","status_message"=>"Record not found"}
$e3={"status_code"=>"2036","status_message"=>"Payment failed check the details entered"}
$e4={"status_code"=>"2035","status_message"=>"destroyed"}
$e5={"status_code"=>"2030","status_message"=>"Undefined method request check the url"}
  belongs_to :country
  before_filter :load_data
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
def current_ability
    user= current_user || User.find_by_authentication_token(params[:authentication_token])
    @current_ability ||= Ability.new(user)
  end

   def index
    
    respond_with(@collection) do |format|
        if !params[:format].nil? && params[:format] == "json"
          format.json { render :json => @collection }
          else
      format.html
      format.js  { render :partial => 'state_list.html.erb' }
      end
    end
  end
  def create
      if !params[:format].nil? && params[:format] == "json"
        begin
      if @object.update_attributes(params[object_name])
          render :json => @object.to_json, :status => 201
    else
      error = error_response_method($e1)
      render :json => error
      #respond_with(@object.errors, :status => 422)
    end
     rescue Exception=>e
     #render :text => "#{e.message}", :status => 500
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
  def show
  if !params[:format].nil? && params[:format] == "json"
    respond_with(@object) do |format|
      format.json { render :json => @object.to_json(object_serialization_options) }
    end
    end
   end
   def update
        if !params[:format].nil? && params[:format] == "json"
    begin
      if @object.update_attributes(params[object_name])
          render :json => @object.to_json, :status => 201
    else
      error = error_response_method($e1)
      render :json => error
      #respond_with(@object.errors, :status => 422)
    end
     rescue Exception=>e
     #render :text => "#{e.message}", :status => 500
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
def destroy
  if !params[:format].nil? && params[:format] == "json"
@object=State.find_by_id(params[:id])
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
def error_response_method(error)
    if !params[:format].nil? && params[:format] == "json"
    @error = {}
    @error["code"]=error["status_code"]
    @error["message"]=error["status_message"]
    #@error["Code"] = error["error_code"]
    return @error
    end
  end

  def model_class
    p "1111111111111111111111111111111111111111111111112333333333333333333333333333333333###"
    controller_name.classify.constantize
  end

  def object_name
    p "`````````````````````````````````````````````````````````````````````````~~~"
    controller_name.singularize
  end

  def load_resource
    p "{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{"
    if member_action?
      @object ||= load_resource_instance
      instance_variable_set("@#{object_name}", @object)
    else
      @collection ||= collection
      instance_variable_set("@#{controller_name}", @collection)
    end
  end

  def load_resource_instance
    p "OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO"
    if new_actions.include?(params[:action].to_sym)
      build_resource
    elsif params[:id]
      find_resource
    end
  end
def access_denied
    p "222222222222222222222222222222222222222222222222222222222222"
    if !params[:format].nil? && params[:format] == "json"
    #render :text => 'access_denied', :status => 401
    error = error_response_method($e12)
      render :json => error
  end
  end
  def parent_data
    p "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
    self.class.parent_data
  end

  def parent
    p"4444444444444444444444444444444444444444444444444444444444444444444444444"
    if parent_data.present?
      @parent ||= parent_data[:model_class].where(parent_data[:find_by] => params["#{parent_data[:model_name]}_id"]).first
      instance_variable_set("@#{parent_data[:model_name]}", @parent)
    else
      nil
    end
  end

  def find_resource
    p "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
    if parent_data.present?
      parent.send(controller_name).find(params[:id])
    else
      model_class.find(params[:id])
    end
  end

  def build_resource
    if parent_data.present?
      parent.send(controller_name).build(params[object_name])
    else
      model_class.new(params[object_name])
    end
  end

  def collection
    p ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    return parent.send(controller_name) if parent_data.present?

    if model_class.respond_to?(:accessible_by) && !current_ability.has_block?(params[:action], model_class)
      model_class.accessible_by(current_ability)
    else
      model_class.scoped
    end
  end

  def location_after_save
    collection_url
  end

  def invoke_callbacks(action, callback_type)
    p "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~______________________________________"
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
    p "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    if parent_data.present?
      new_polymorphic_url([:admin, parent, model_class], options)
    else
      new_polymorphic_url([:admin, model_class], options)
    end
  end

  def edit_object_url(object, options = {})
    p"++++++++++++++++++++++++++***************************************************"
    if parent_data.present?
      send "edit_admin_#{parent_data[:model_name]}_#{object_name}_url", parent, object, options
    else
      send "edit_admin_#{object_name}_url", object, options
    end
  end

  def object_url(object = nil, options = {})
    p "????????????????????????????????????????????????????????????????????????????????????"
    target = object ? object : @object
    if parent_data.present?
      send "admin_#{parent_data[:model_name]}_#{object_name}_url", parent, target, options
    else
      send "admin_#{object_name}_url", target, options
    end
  end

  def collection_url(options = {})
    p ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
    if parent_data.present?
      polymorphic_url([:admin, parent, model_class], options)
    else
      polymorphic_url([:admin, model_class], options)
    end
  end

  def collection_actions
    p "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
    [:index]
  end

  def member_action?
    p "PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP"
    !collection_actions.include? params[:action].to_sym
  end

  def new_actions
    p "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
    [:new, :create]
  end
   private
  def check_http_authorization
         if !params[:format].nil? && params[:format] == "json"
      if current_user.authentication_token!=params[:authentication_token]
        #render :text => "Access Denied\n", :status => 401
        error = error_response_method($e13)
      render :json => error
    end if current_user
  end
end
  end
