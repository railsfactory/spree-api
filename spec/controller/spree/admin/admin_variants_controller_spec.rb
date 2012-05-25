require 'spec_helper.rb'

describe Spree::Admin::VariantsController , :type => "controller" do
  
  def mock_user(stubs={})
    @mock_user ||= mock_model(Spree::User, stubs).as_null_object
  end
  
  
  before(:each) do
    controller.stub!(:check_http_authorization).and_return(true)		
    controller.stub!(:invoke_callbacks).and_return(true)		
    @product = Spree::Product.create(:name=>"railscfactory",:description=>"software concern",:price =>19.99,:cost_price=>17.00,:sku=> "ABC")
    @variant= @product.variants.create(:sku=>"top size", :price=>19.99, :cost_price=>17.00,:weight=>12, :height=>96, :width=>36, :depth=>"")
    #p @variant = Spree::Variant.create(:sku=>"top size", :price=>19.99, :cost_price=>17.00,:weight=>12, :height=>96, :width=>36, :depth=>"",:product_id=>@product.to_param)
    request.env['warden'] = mock(Warden, :authenticate => mock_user,:authenticate! => mock_user)
    @current_user = 1
  end

  
  describe "GET index" do
    it "user To list Variants" do
      get :index, :format=>:json
      response.code.should == "200"
    end
  end
  

  describe "GET show" do
    it "user To display particular variant" do
      get :show,{:id=>@variant.to_param , :format=>:json }
      response.should be_success
    end
    it "user To display particular variant with wrong id" do
      get :show,{:id=>20 , :format=>:json }
      response.should be_success
    end
  end
  
  describe "POST create" do
    it "user To create a variant" do
      post :create, {:variant => {:sku=>@variant.sku, :price=>@variant.price, :on_hand => @variant.on_hand ,:cost_price=>@variant.cost_price,:weight=>@variant.weight, :height=>@variant.height, :width=>@variant.width, :depth=>"",:product_id=>@variant.product_id} , :format=>:json }
      response.code.should == "201"
    end
  end	
  
  describe "PUT UPDATE" do 
    it "User To update the variant" do
      put :update ,:id => @variant.to_param ,:variant => {:sku=>@variant.sku, :price=>@variant.price, :on_hand => @variant.on_hand ,:cost_price=>@variant.cost_price,:weight=>12, :height=>96, :width=>36, :depth=>"" } , :format=>:json 
      response.code.should == "201"
    end
    it "User To update the variant with wrong value" do
      put :update ,:id => 20 ,:variant => {:sku=>@variant.sku, :price=>@variant.price, :on_hand => @variant.on_hand ,:cost_price=>@variant.cost_price,:weight=>12, :height=>96, :width=>36, :depth=>"" } , :format=>:json 
      response.code.should == "200"
    end
  end
  
  describe "DELETE destroy" do  
    it "user To display particular variant" do
      delete :destroy,{:id => @variant.id ,:format=>:json }
      response.should be_success
    end
    
    it "user To display particular variant" do
      delete :destroy,{:id => 20 ,:format=>:json }
      response.should be_success
    end
  end
  
  
end
