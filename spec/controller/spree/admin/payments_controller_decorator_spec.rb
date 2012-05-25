require 'spec_helper' 

describe   Spree::Admin::PaymentsController,:type=>"controller" do
  
  def mock_user(stubs={})
    @mock_user ||= mock_model(Spree::User, stubs).as_null_object
  end
  
  before(:each) do
    controller.stub!(:check_http_authorization).and_return(true)
    request.env['warden'] = mock(Warden, :authenticate => mock_user,:authenticate! => mock_user)
    @current_user = 1
  end
  
  describe "GET index" do
    it "To get the index of the Payment controller" do
      get :index, :format=>:json
      @user=Spree::User.create(:email => "email@person.com", :password => "secret", :password_confirmation => "secret")
      @auth=@user.authentication_token="16qL-TsdhrJmHGWCC8bS"
      @user.save
      p @order=Spree::Order.create(:email=>@user.email)
      @order.state="complete"
      @order.payment_state="balance_due"
      @order.save
      current_order = Spree::Order.find_by_number(@order.id)
      @order=current_order
      #~ @order=Spree::Payment(:amount=>"100", :order_id=>@order.id, :source_id=>1, :source_type=>"Creditcard", :payment_method_id=>842616224, :state=> "completed", :response_code=>"sedin", :avs_response=> "rails")
      response.code.should == "200"
    end
  end
  
  describe "GET new" do
    it "assign the order" do
      get :new, :format=> :json
      response.code.should == "200"
    end
  end

  describe "GET fire" do
    it "To capture the payment" do
      @user=Spree::User.create(:email => "email@person.com", :password => "secret", :password_confirmation => "secret")
      @auth=@user.authentication_token="16qL-TsdhrJmHGWCC8bS"
      @user.save
      @order=Spree::Order.create(:email=>@user.email)
      p @order
      #~ @payment=Spree::Payment.create(:amount=>100)
      #~ p @payment
      get :fire, {:id=>@order.id, :e=>"capture",:format=> :json}
      response.code.should == "200"
    end
    it "To capture the payment" do
      @user=Spree::User.create(:email => "email@person.com", :password => "secret", :password_confirmation => "secret")
      @auth=@user.authentication_token="16qL-TsdhrJmHGWCC8bS"
      @user.save
      @order=Spree::Order.create(:email=>@user.email)
      p @order
      get :fire, {:e=>"capture",:format=> :json}
      response.code.should == "200"
    end
  end

end	
