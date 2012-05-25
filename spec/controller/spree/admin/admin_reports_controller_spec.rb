require 'spec_helper'

describe Spree::Admin::ReportsController , :type => "controller" do
  
  def mock_user(stubs={})
    @mock_user ||= mock_model(Spree::User, stubs).as_null_object
  end
  
  before(:each) do
    #~ @product = Spree::Product.create(:name=>"railscfactory",:description=>"software concern",:price =>19.99,:cost_price=>17.00,:sku=> "ABC")
    #~ @product_one = Spree::Product.create(:name=>"railscfactory_one",:description=>"software concern_one",:price =>19.99,:cost_price=>17.00,:sku=> "ABC_one")
    #~ @variant = @product.variants.build(:sku=>"top size", :price=>19.99, :cost_price=>17.00,:weight=>12, :height=>96, :width=>36, :depth=>"")
    #~ @variant_one = @product_one.variants.build(:sku=>"top size", :price=>19.99, :cost_price=>17.00,:weight=>12, :height=>96, :width=>36, :depth=>"")
    controller.stub!(:check_http_authorization).and_return(true)
    request.env['warden'] = mock(Warden, :authenticate => mock_user,:authenticate! => mock_user)
    @current_user = 1
  end
  
  describe "GET best_selling_products" do
    it "To list OptionTypes units" do
      get :best_selling_products, :format=>:json
      response.code.should == "201"
    end
  end
  
  describe "GET gross_selling_products" do
    it "To gross_selling_products" do
      get :best_selling_products, :format=>:json
      response.code.should == "201"
    end
  end
  
  describe "GET top_spenders" do
    it "To top_spenders" do
      get :top_spenders, :format=>:json
      response.code.should == "201"
    end
  end
  
  describe "GET out_of_stock" do
    it "To out_of_stock" do
      get :out_of_stock, :format=>:json
      response.code.should == "201"
    end
  end
  
  describe "GET day_order_count" do
    it "To day_order_count" do
      get :day_order_count, :format=>:json
      response.code.should == "201"
    end
  end
  
  describe "GET day_order_value" do
    it "To day_order_value" do
      get :day_order_value, :format=>:json
      response.code.should == "201"
    end
  end

  #~ describe "GET month_order_value" do
  #~ it "To month_order_value" do
  #~ get :month_order_value, :format=>:json
  #~ response.code.should == "201"
  #~ end
  #~ end

  #~ describe "GET month_order_count" do
  #~ it "To month_order_count" do
  #~ get :month_order_count, :format=>:json
  #~ response.code.should == "201"
  #~ end
  #~ end
  
end
