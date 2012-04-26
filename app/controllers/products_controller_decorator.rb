ProductsController.class_eval do
$e1={"status_code"=>"2038","status_message"=>"parameter errors"}
$e2={"status_code"=>"2037","status_message"=>"Record not found"}
$e3={"status_code"=>"2036","status_message"=>"Payment failed check the details entered"}
$e4={"status_code"=>"2035","status_message"=>"destroyed"}
$e5={"status_code"=>"2030","status_message"=>"Undefined method request check the url"}
  include Spree::Search

  before_filter :check_http_authorization
  before_filter :load_resource
  skip_before_filter :verify_authenticity_token, :if => lambda { admin_token_passed_in_headers }
  authorize_resource
  
  respond_to :json

  rescue_from ActionController::UnknownAction, :with => :render_404
def current_ability
   user= current_user || User.find_by_authentication_token(params[:authentication_token])
    
    @current_ability ||= Ability.new(user)
    
  end
   def index
    if !params[:format].nil? && params[:format] == "json"
      puts "now the cursor in if condition"
      respond_with(@collection) do |format|
        
        format.json { render :json => @collection.to_json(collection_serialization_options) }
      end
      else
          @searcher = Spree::Config.searcher_class.new(params)
    @products = @searcher.retrieve_products
    @new_sales=Product.where("available_on=?",Date.today-5.days)
    @coming_soon=Product.where("available_on > ? and deleted_at is NULL",Date.today)
    respond_with(@products)
    end
  end
  def show
    if !params[:format].nil? && params[:format] == "json"
      puts "now the cursor in if condition"
      p @object
    respond_with(@object) do |format|
      format.json { render :json => @object.to_json(object_serialization_options) }
      end
else
   @product = Product.find_by_permalink!(params[:id])
   p @product
    return unless @product

    @variants = Variant.active.includes([:option_values, :images]).where(:product_id => @product.id)
    @product_properties = ProductProperty.includes(:property).where(:product_id => @product.id)
    @selected_variant = @variants.detect { |v| v.available? }

    referer = request.env['HTTP_REFERER']

    if referer && referer.match(HTTP_REFERER_REGEXP)
      @taxon = Taxon.find_by_permalink($1)
    end

    respond_with(@product)
  
    end
  end
def destroy
@object=Product.find_by_id(params[:id])
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
 def error_response_method(error)
    @error = {}
    @error["code"]=error["status_code"]
    @error["message"]=error["status_message"]
    #@error["Code"] = error["error_code"]
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
    
    def load_resource_instance
        if !params[:format].nil? && params[:format] == "json"
      if new_actions.include?(params[:action].to_sym)
      build_resource
      elsif params[:id]
        find_resource
      end
      end
    end
    
    def parent
        if !params[:format].nil? && params[:format] == "json"
      nil
      end
    end

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
    #render :text => "Resource not found (#{e.message})", :status => 500
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
private
    def collection
      params[:per_page] ||= 100
      @searcher = Spree::Config.searcher_class.new(params)
      @collection = @searcher.retrieve_products
    end

    def object_serialization_options
      { :include => [:master, :variants, :taxons] }
    end
end
