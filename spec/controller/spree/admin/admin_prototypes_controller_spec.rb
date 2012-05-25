require 'spec_helper'

describe Spree::Admin::PrototypesController , :type => "controller" do
  
  def mock_user(stubs={})
    @mock_user ||= mock_model(Spree::User, stubs).as_null_object
  end
  
  
  before(:each) do
    controller.stub!(:check_http_authorization).and_return(true)
    @proto_type_new = Spree::Prototype.new
    @proto_type = Spree::Prototype.create(:name => "Rajendran")
    request.env['warden'] = mock(Warden, :authenticate => mock_user,:authenticate! => mock_user)
    @current_user = 1
  end
  
  
  describe "POST create" do
    it "user To create a Prototypes" do
      post :create, :prototype => { :name => "Free" },  :property => { :id => ["905834903", "905834905", "905834904", "901906169", "591802549"]}, :option_type => { :id => ["935339118", "935339119"]}, :authentication_token => "NvQuOmwkXWL712awuWSz" , :format=> :json 
      response.code.should == "201"
    end
    
    it "user To create a Prototypes with wrong paramater" do
      post :create, :prototype => { :name => "Free" },  :property => { :id => ["905834903", "905834905", "905834904", "901906169", "591802549"]}, :option_type => { :id => ["935339118", "935339119"]}, :authentication_token => "NvQuOmwkXWL712awuWSz" 
      response.code.should == "302"
    end
    
  end	
  
  describe "GET index" do
    it "user To list Prototypes" do
      get :index, :format=>:json
      response.code.should == "200"
    end
    
    it "user To list Prototypes with wrong id" do
      get :index
      response.code.should == "200"
    end
    
  end
  
  describe "POST update" do
    it "user To update a particular Prototype" do
      post :update, :id => @proto_type.id , :prototype => { :name => "Free list" }, :property => { :id => ["905834903", "905834905", "905834904", "901906169", "591802549"]}, :option_type => { :id => ["935339118", "935339119"]}, :authentication_token => "NvQuOmwkXWL712awuWSz", :format=>:json
      response.code.should == "201"
    end
    
    it "user To update a particular Prototype with wrong value" do
      post :update, :id => 20 , :prototype => { :name => "Free list" }, :property => { :id => ["905834903", "905834905", "905834904", "901906169", "591802549"]}, :option_type => { :id => ["935339118", "935339119"]}, :authentication_token => "NvQuOmwkXWL712awuWSz", :format=>:json
      response.code.should == "200"
    end
    
  end
  
  
  describe "DELETE destroy" do
    it "user To delete a particular Prototypeype" do
      delete :destroy, :id => @proto_type.id, :prototype => { :name => "Free list" }, :property => { :id => ["905834903", "905834905", "905834904", "901906169", "591802549"]}, :option_type => { :id => ["935339118", "935339119"]}, :authentication_token => "NvQuOmwkXWL712awuWSz", :format=>:json
      response.code.should == "200"
    end
    it "user To delete a particular Prototypeype with wrong id value" do
      delete :destroy, :id => 20, :prototype => { :name => "Free list" }, :property => { :id => ["905834903", "905834905", "905834904", "901906169", "591802549"]}, :option_type => { :id => ["935339118", "935339119"]}, :authentication_token => "NvQuOmwkXWL712awuWSz", :format=>:json
      response.code.should == "200"
    end
  end

end
