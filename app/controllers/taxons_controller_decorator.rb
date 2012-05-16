module Spree
TaxonsController.class_eval do
	rescue_from ActiveRecord::RecordNotFound, :with => :render_404
    helper 'spree/products'
def search
	      @taxon = Taxon.find_by_permalink!(params[:id])
      return unless @taxon

			@searcher = Spree::Config.searcher_class.new(params.merge(:taxon => @taxon.id))
			@products = @searcher.retrieve_products
 if !params[:format].nil? && params[:format] == "json"
      render :json => @products.to_json, :status => 201
			else
				respond_with(@taxon)
				end
    end
    end
		end