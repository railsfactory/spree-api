class SearchController< Spree::BaseController
  rescue_from ActiveRecord::RecordNotFound, :with => :render_404
  helper 'spree/products'
  def search
    @taxon = Spree::Taxon.find_by_permalink!(params[:id])
    return unless @taxon

    @searcher = Spree::Config.searcher_class.new(params.merge(:taxon => @taxon.id))
    @products = @searcher.retrieve_products
    if !params[:format].nil? && params[:format] == "json"
      render :json => @products.to_json, :status => 201
    else
      respond_with(@taxon)
    end
  end
 
  def taxon
    if !params[:id].present?
      @taxon=Spree::Taxon.where("parent_id IS NULL")
      render :json => @taxon.to_json, :status => 201
    else
      #@taxon=Spree::Taxon.find(:all,:conditions=>["parent_id  like ?","%#{params[:id]}%"])
      @taxon=Spree::Taxon.find_all_by_parent_id(params[:id])
      render :json => @taxon.to_json, :status => 201
    end
  end
  #~ def child_taxon
  #~ @taxon=Spree::Taxon.find_by_id
end
