require 'spec_helper'

describe Spree::Admin::ShippingCategoriesController , :type => "controller" do
  
  def mock_user(stubs={})
    @mock_user ||= mock_model(Spree::User, stubs).as_null_object
  end
  

  before(:each) do
    controller.stub!(:check_http_authorization).and_return(true)		
    @shipping_category = Spree::ShippingCategory.create!(:name => "ShippingCategory 1" )
    request.env['warden'] = mock(Warden, :authenticate => mock_user,:authenticate! => mock_user)
    @current_user = 1
  end

  describe "GET index" do
    it "To list ShippingCategory" do
      get :index, {:format => "json" , :search => {}}
      response.code.should == "200"
    end
  end

  describe "GET show" do
    it "user To display particular ShippingCategory" do
      get :show,{:id=>@shipping_category.id , :format=>:json}
      response.should be_success
    end
  end
  describe "GET show" do
    it "user To display particular ShippingCategory" do
      get :show,{:id=>7 , :format=>:json}
      response.code.should == "200"
    end
  end
  describe "POST create" do
    it "user To create a ShippingCategory" do
      post :create, :shipping_category => { :name => "Dolphin Wayz" }  ,:format  => :json
      response.code.should == "201"
    end
  end	
  describe "POST create" do
    it "user To create a ShippingCategory" do
      post :create, :shipping_category => { :name => "" }  ,:format  => :json
      response.code.should == "200"
    end
  end	
  describe "PUT update" do
    it "user To update a particular ShippingCategory" do
      put :update, :id => @shipping_category.id , :shipping_category => { :name => "aa" } , :format=>:json 
      response.code.should == "201"
    end
  end	
  describe "PUT update" do
    it "user To update a particular ShippingCategory" do
      put :update, :id =>9 , :shipping_category => { :name => "aa" } , :format=>:json 
      response.code.should == "200"
    end
  end	
  describe "DELETE destroy" do
    it "user To delete a particular OptionType" do
      delete :destroy, {:id=>@shipping_category.id , :format=>:json}
      response.code.should == "200"
    end
  end	
  describe "DELETE destroy" do
    it "user To delete a particular OptionType" do
      delete :destroy, {:id=>9 , :format=>:json}
      response.code.should == "200"
    end
  end	
end
