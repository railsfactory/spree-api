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
  # To set current user
  def current_ability
    user= current_user || User.find_by_authentication_token(params[:authentication_token])
    @current_ability ||= Ability.new(user)
    
  end
  def retrieve_products #To get the collection of products
    base_scope = get_base_scope
    @products_scope = @product_group.apply_on(base_scope)
    curr_page = manage_pagination && keywords ? 1 : page

    @products = @products_scope.paginate({
        :include  => [:images, :master],
        :per_page => per_page,
        :page     => curr_page
      })
  end
      #To list the products
  def index
    if !params[:format].nil? && params[:format] == "json"
      product_details = Hash.new
      @products=Product.all
      product_details[:products] = Array.new
      if params[:e].present?
          user=User.find_by_authentication_token(params[:authentication_token])
          if user.present?
             page = params[:page]
              size = params[:size]
             page= page.nil? ? 1 : page
             size= size.nil? ? 10 : size
             product_index = 0
             @products.each do | r |
                if (product_index >= (page.to_i-1) * size.to_i && product_index < (page.to_i) * size.to_i)
                  product_detail=Hash.new
                  product_detail[:product_id]=r.id
                  product_detail[:name]=r.name
                  var=Variant.find(:all,:conditions=>["product_id=? and is_master=?",r.id,true])
                  var.each do |r|
                   price=r.price.to_i
                   product_detail[:price]=price
                  end
                  @image=r.images
                  product_detail[:images]= Array.new
                  @image.each do |image|
                    product_image = Hash.new
                    product_image[:image_type]=image.attachment.content_type
                    product_image[:url]='http://spreeapi.railsfactory.com' + image.attachment.url(:original)
                    product_detail[:images].push product_image
                  end
                product_details[:products].push product_detail
              end
              product_index = product_index + 1
             end
      respond_with(product_details) do |format|
        format.json { render :json =>product_details}
      end
      else
         error=error_response_method($e13)
        render:json=>error 
      end
      else
      @products.each do |r|
        product_detail=Hash.new
        product_detail[:product_id]=r.id
        product_detail[:name]=r.name
        product_detail[:description]=r.description
        product_detail[:created_at]=r.created_at
        product_detail[:updated_at]=r.updated_at
        product_detail[:permalink]=r.permalink
        product_detail[:available_on]=r.available_on
        product_detail[:tax_category_id]=r.tax_category_id
        product_detail[:shipping_category_id]=r.shipping_category_id
        product_detail[:deleted_at]=r.deleted_at
        product_detail[:meta_description]=r.meta_description
        product_detail[:meta_keywords]=r.meta_keywords
        product_detail[:count_on_hand]=r.count_on_hand
        var=Variant.find(:all,:conditions=>["product_id=? and is_master=?",r.id,true])
         var.each do |r|
         price=r.price.to_i
        product_detail[:price]=price
        end
        @image=r.images
        product_detail[:images]= Array.new
        @image.each do |image|
          product_image = Hash.new
          product_image[:image_type]=image.attachment.content_type
          product_image[:url]='http://spreeapi.railsfactory.com' + image.attachment.url(:original)
          product_detail[:images].push product_image
        end
        product_details[:products].push product_detail
      end
      respond_with(product_details) do |format|
        format.json { render :json =>product_details}
      end
      end
    else
      @searcher = Spree::Config.searcher_class.new(params)
      @products = @searcher.retrieve_products
      @new_sales=Product.where("available_on=?",Date.today-5.days)
      @coming_soon=Product.where("available_on > ? and deleted_at is NULL",Date.today)
      respond_with(@products)
    end
  end
  
#To display the particular product
  def show
    if !params[:format].nil? && params[:format] == "json"
      if params[:e].present?&&params[:e]=="show"
            user=User.find_by_authentication_token(params[:authentication_token])
          if user.present?
            if @object.present?
       product_details = Hash.new
        product_details[:products] = Array.new
       product_detail=Hash.new
        product_detail[:product_id]=@object.id
        product_detail[:name]=@object.name
         product_detail[:description]=@object.description
        var=Variant.find(:all,:conditions=>["product_id=? and is_master=?",@object.id,true])
         var.each do |r|
         price=r.price.to_i
        product_detail[:price]=price
        end
        @image=@object.images
        product_detail[:images]= Array.new
        @image.each do |image|
          product_image = Hash.new
          product_image[:image_type]=image.attachment.content_type
          product_image[:url]='http://spreeapi.railsfactory.com' + image.attachment.url(:original)
          product_detail[:images].push product_image
        end
        product_details[:products].push product_detail
      respond_with(product_details) do |format|
        format.json { render :json =>product_details}
      end
      else
        error = error_response_method($e2)
        render :json => error
      end
      else
         error=error_response_method($e13)
        render:json=>error 
      end
      else
      respond_with(@object) do |format|
        format.json { render :json => @object.to_json(object_serialization_options) }
      end
      end
    else
      @product = Product.find_by_permalink!(params[:id])
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
  #To destroy the product
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
  #To display the error message
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
      if current_user.authentication_token!=params[:authentication_token]
        error = error_response_method($e13)
        render :json => error
      end if current_user
    end
  end
# To collect the data for index
  def collection
    params[:per_page] ||= 100
    @searcher = Spree::Config.searcher_class.new(params)
    @collection = @searcher.retrieve_products
  end

  def object_serialization_options
    { :include => [:master, :variants, :taxons] }
  end
end
