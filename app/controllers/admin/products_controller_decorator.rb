module Spree

  Admin::ProductsController.class_eval do
    $e1={ "status_code"=>"2038","status_message"=>"parameter errors" }
    $e2={ "status_code"=>"2037","status_message"=>"Record not found" }
    $e3={ "status_code"=>"2036","status_message"=>"Payment failed check the details entered" }
    $e4={ "status_code"=>"2035","status_message"=>"destroyed" }
    $e5={ "status_code"=>"2030","status_message"=>"Undefined method request check the url" }
    $e12={ "status_code"=>"2041","status_message"=>"You do not have permission to make this API call" }
    $e13={ "status_code"=>"2042","status_message"=>"authentication token is not valid " }
    helper 'spree/products'
    require 'spree/core/action_callbacks'
    before_filter :check_json_authenticity, :only => :index
    before_filter :load_data, :except => :index
    create.before :create_before
    update.before :update_before
    helper_method :new_object_url, :edit_object_url, :object_url, :collection_url
    prepend_before_filter :load_resource
    rescue_from ActiveRecord::RecordNotFound, :with => :resource_not_found
    #To set current user
    def current_ability
      user= current_user || Spree::User.find_by_authentication_token(params[:authentication_token])
      @current_ability ||= Spree::Ability.new(user)
    end
    def create
      if !params[:format].nil? && params[:format] == "json"
        begin
          if @object.save
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
          invoke_callbacks(:create, :after)
          flash.notice = flash_message_for(@object, :successfully_created)
          respond_with(@object) do |format|
            format.json  { render :json => @object.to_json, :layout => false }
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
          format.json { render :json => @object.to_json }
        end
      else
        respond_with(@object) do |format|
          format.html { render :layout => !request.xhr? }
          format.js { render :layout => false }
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
          end
        rescue Exception=>e
          error = error_response_method($e11)
          render :json => error
        end
      else
        invoke_callbacks(:update, :before)
        if @object.update_attributes(params[object_name])
          invoke_callbacks(:update, :after)
          flash.notice = flash_message_for(@object, :successfully_updated)
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
        @object=Spree::Product.find_by_id(params[:id])
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
        @product = Product.find_by_permalink!(params[:id])
        @product.update_attribute(:deleted_at, Time.now)

        @product.variants_including_master.update_all(:deleted_at => Time.now)

        flash.notice = I18n.t('notice_messages.product_deleted')

        respond_with(@product) do |format|
          format.html { redirect_to collection_url }
          format.js  { render_js_for_destroy }
        end
      end
    end

    #To display error message
    def error_response_method(error)
      if !params[:format].nil? && params[:format] == "json"
        @error = { }
        @error["code"]=error["status_code"]
        @error["message"]=error["status_message"]
        return @error
      end
    end

    protected
    def model_class
      "Spree::#{ controller_name.classify }".constantize
    end
    def object_name
      controller_name.singularize
    end
    #To load resource
    def load_resource
      if member_action?
        @object ||= load_resource_instance
        instance_variable_set("@#{ object_name }", @object)
      else
        @collection ||= collection
        instance_variable_set("@#{ controller_name }", @collection)
      end
    end
    #To load resource instance
    def load_resource_instance
      if new_actions.include?(params[:action].to_sym)
        build_resource
      elsif params[:id]
        find_resource
      end
    end
    def parent_data
      self.class.parent_data
    end

    def parent
      if parent_data.present?
        @parent ||= parent_data[:model_class].where(parent_data[:find_by] => params["#{ model_name }_id"]).first
        instance_variable_set("@#{ model_name }", @parent)
      else
        nil
      end
    end

    #To find the resource
    def find_resource
      if !params[:format].nil? && params[:format] == "json"
        begin
          p "i came in"
          p params[:id]
          Product.find_by_id(params[:id])
        rescue Exception => e
          error = error_response_method($e2)
          render :json => error
        end
      else
        Product.find_by_permalink!(params[:id])
      end
    end
    #To build resource
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

    def collection
      return @collection if @collection.present?

      unless request.xhr?
        params[:q] ||= { }
        params[:q][:deleted_at_null] ||= "1"

        params[:q][:s] ||= "name asc"

        @search = super.search(params[:q])
        @collection = @search.result.
          group_by_products_id.
          includes([:master, { :variants => [:images, :option_values] }]).
          page(params[:page]).
          per(Spree::Config[:admin_products_per_page])

        if params[:q][:s].include?("master_price")
          # By applying the group in the main query we get an undefined method gsub for Arel::Nodes::Descending
          # It seems to only work when the price is actually being sorted in the query
          # To be investigated later.
          @collection = @collection.group("spree_variants.price")
        end
      else
        includes = [{ :variants => [:images,  { :option_values => :option_type }] }, { :master => :images }]

        @collection = super.where(["name #{ LIKE } ?", "%#{ params[:q] }%"])
        @collection = @collection.includes(includes).limit(params[:limit] || 10)

        tmp = super.where(["#{ Variant.table_name }.sku #{ LIKE } ?", "%#{ params[:q] }%"])
        tmp = tmp.includes(:variants_including_master).limit(params[:limit] || 10)
        @collection.concat(tmp)
      end
      @collection
    end
  end

  #end
end