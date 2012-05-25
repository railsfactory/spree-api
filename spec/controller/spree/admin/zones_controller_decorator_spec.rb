require 'spec_helper' 

describe   Spree::Admin::ZonesController,:type=>"controller" do
  #include Devise::TestHelpers
  describe " ZonesController" do
    def valid_attributes
      {:name=>"southxy", :description=>"tamilnadu123"
      }
    end
    
    def mock_user(stubs={})
      @mock_user ||= mock_model(Spree::User, stubs).as_null_object
    end
    before(:each) do
      controller.stub!(:check_http_authorization).and_return(true)
      request.env['warden'] = mock(Warden, :authenticate => mock_user,:authenticate! => mock_user)
      @current_user = 1
    end
    describe "To get the index of the Zones controller" do
      it "should be successful" do
        get :index,:format=>:json
        response.code.should == "200"
      end
      it "should get the zone" do
        store = Spree::Zone.create! valid_attributes
        get :show, {:id => store.to_param, :format => :json}
        response.code.should == "200"
      end
      it "should get the zone" do
        store = Spree::Zone.create! valid_attributes
        get :show, {:id => 1, :format => :json}
        response.code.should == "200"
      end
      it "should be successful create zone" do
        post :create , :zone => {:name=>"production",:description=>"pd",:kind=>"country"}, :format => :json
        response.code.should == "201"
      end
      it "should be successful create zone" do
        post :create , :zone => {:description=>"pd",:kind=>"country"}, :format => :json
        response.code.should == "200"
      end
      it "should be successful create zone" do
        store = Spree::Zone.create! valid_attributes
        put :update , :id=>store.to_param,:zone => {:name=>"production",:description=>"pd"}, :format => :json
        response.code.should == "201"
      end
      it "should be successful create zone" do
        store = Spree::Zone.create! valid_attributes
        put :update , :id=>7,:zone => {:name=>"production",:description=>"pd"}, :format => :json
        response.code.should == "200"
      end
      
      it "should delete the zone" do
        store = Spree::Zone.create! valid_attributes
        get :destroy, {:id => store.to_param,:format => :json}
        response.code.should == "200"
      end
      it "should delete the zone" do
        store = Spree::Zone.create! valid_attributes
        get :destroy, {:id => 6,:format => :json}
        response.code.should == "200"
      end
    end
  end 
end	
