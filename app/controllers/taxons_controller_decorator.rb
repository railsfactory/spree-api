module Spree
TaxonsController.class_eval do
	rescue_from ActiveRecord::RecordNotFound, :with => :render_404
    helper 'spree/products'
def show
	p "222222222222222222222222666666666666666666666666666666666666622222222222222222222"
      @taxon = Taxon.find_by_permalink!(params[:id])
      return unless @taxon

      p @searcher = Spree::Config.searcher_class.new(params.merge(:taxon => @taxon.id))
			p @products = @searcher.retrieve_products
 if !params[:format].nil? && params[:format] == "json"
      render :json => @products.to_json, :status => 201
			else
				respond_with(@taxon)
				end
    end
    end
		end