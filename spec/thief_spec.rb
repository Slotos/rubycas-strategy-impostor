require File.dirname(__FILE__) + '/spec_helper'

describe "thief strategy" do
  it "should ignore anonymous" do
    truncate_database
    get '/impostor/something'
    clear_cookies
    app.any_instance.should_not_receive(:establish_session!)
    last_response.should be_redirect
    follow_redirect!
    last_request.path.should eq('/login')
  end

  it "should provide new requested identity for logged in user that has required role" do
    truncate_database
    add_user("admin", :roles => ["admin"])
    add_user("someone")
    clear_cookies
    set_cookie 'tgt=random'

    tgt = double('tgt')
    tgt.stub!(:username).and_return('admin')
    app.any_instance.should_receive(:validate_ticket_granting_ticket).with('random').and_return [tgt, nil]
    app.any_instance.should_receive(:establish_session!).with('someone')

    get '/impostor/someone'
  end

  it "should ignore users without required roles" do
    truncate_database
    add_user("admin")
    add_user("someone")
    clear_cookies
    set_cookie 'tgt=random'

    tgt = double('tgt')
    tgt.stub!(:username).and_return('admin')
    app.any_instance.should_receive(:validate_ticket_granting_ticket).with('random').and_return [tgt, nil]
    app.any_instance.should_not_receive(:establish_session!).with('someone')

    get '/impostor/someone'
  end
end
