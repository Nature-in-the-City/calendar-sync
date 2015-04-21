require 'rails_helper'

describe EventsController do
  before :each do
    @user = User.create(:provider => "Meetup", :uid => "12345",
                        :email => "example@example.com",
                        :password => "changeme", :token => "abc",
                        :expires_at => 0, :refresh_token => "def")
    sign_in @user
  end

  let(:event) {Event.create(name: 'coyote appreciation',
                                    organization: 'nature loving',
                                    start: '8-mar-2016',
                                    description: 'watch coyotes')}
  describe 'Checking Show' do
    it "should render 'show' page" do
      allow_any_instance_of(Meetup).to receive(:pull_rsvps).and_return(nil)
      get :show, id: event.id
      expect(response).to render_template(:show)
    end
  end

  describe 'Getting page to add new events' do
    it "should render 'new' page" do
      get :new
      expect(response).to render_template(:new)
    end
  end

  describe 'Creating New Event' do
    it 'should redirect to calendar' do
      allow(event).to receive(:merge_meetup_rsvps).and_return(nil)
      allow_any_instance_of(Meetup).to receive(:push_event).and_return(nil)
      post :create, { event: { name: 'coyote appreciation',
                               organization: 'nature loving',
                               start: '8-mar-2016',
                               description: 'watch coyotes' }
                    }
      expect(response).to redirect_to(calendar_path)
    end
  end

  describe 'Getting page to edit event info' do
    it "should render to 'edit' page" do
      Event.create(name: 'coyote appreciation',
                   organization: 'nature loving',
                   start: '8-mar-2016',
                   description: 'watch coyotes')
      get :edit, { id: 1 }
      expect(response).to render_template(:edit)
    end
  end

  describe 'Updating Event' do
    it 'should redirect to index' do
      event = Event.create(name: 'coyote appreciation',
                           organization: 'nature loving',
                           start: '8-mar-2016',
                           description: 'watch coyotes')
      put :update, { id: 1, event: { name: 'Dog Watch',
                                     organization: 'Nature Loving',
                                     start: '8-mar-2016',
                                     description: 'Pet Puppies' }
                   }
      expect(response).to redirect_to(calendar_path)
    end
  end

  describe 'Destroying Event' do
    it 'should delete the selected event' do
      Event.create(name: 'coyote appreciation',
                   organization: 'nature loving',
                   start: '8-mar-2016',
                   description: 'watch coyotes')
      delete :destroy, { id: 1 }
      expect(response).to redirect_to(calendar_path)
    end
  end


  describe 'pulling rsvps in #show' do
    let(:meetup_event_id) {'219648262'}
    let(:event) {Event.create(name: 'coyote appreciation',
                              organization: 'nature loving',
                              start: '8-mar-2016',
                              description: 'watch coyotes',
                              meetup_id: meetup_event_id)}
    let(:rsvp) {[{:event_id=>"qdwhxgytgbxb", :meetup_id=>82190912, :meetup_name=>"Amber Hasselbring", :invited_guests=>0}]}


    before(:each) do
      allow(Event).to receive(:find).and_return(event)
      allow_any_instance_of(Meetup).to receive(:pull_rsvps).with(event_id: meetup_event_id).and_return(rsvp)
    end

    context 'for existing meetup event' do

      it 'should call merge_rsvps with valid event' do
        expect(event).to receive(:merge_meetup_rsvps)
        get :show, id: event.id
      end

      it 'should indirectly call get_remote_rsvps with valid event' do
        expect(event).to receive(:get_remote_rsvps)
        get :show, id: event.id
      end

      it 'should indirectly call pull_rsvps with valid event_id' do
        expect_any_instance_of(Meetup).to receive(:pull_rsvps).with(event_id: meetup_event_id)
        get :show, id: event.id
      end

      it 'should set the flash to display if new rsvps are pulled' do
        get :show, id: event.id
        expect(flash[:notice]).to eq("The RSVP list for this event has been updated." +
                 " Amber Hasselbring has joined. The total number of participants," +
                 " including invited guests, so far is: 1.")
      end

    end

    context 'with no new rsvp to pull for a given article' do

      it 'should display that no new rsvps are pulled' do
        allow(event).to receive(:merge_meetup_rsvps).and_return([])
        get :show, id: event.id
        expect(flash[:notice]).to eq("The RSVP list is synched with Meetup." +
                       " The total number of participants, including invited guests, so far is: 0.")
      end
    end

    context 'with failed result' do

      it 'should display a failure message' do
        allow(event).to receive(:merge_meetup_rsvps).and_return(nil)
        get :show, id: event.id
        expect(flash[:notice]).to eq('Could not merge the RSVP list for this event.')
      end
    end
  end



  describe "pulls 3rd party events" do
    let(:ids) {['event123', 'event1456', 'eventABC']}
    let(:events) {[Event.new(name: 'nature'), Event.new(name: 'gardening'), Event.new(name: 'butterflies')]}

    before(:each) do
      allow(Event).to receive(:get_remote_events).and_return(nil)
      allow(Event).to receive(:make_events_local).and_return(events)
    end

    context 'for some requested ids' do
      before(:each) do
        allow(Event).to receive(:get_requested_ids).and_return(ids)
      end

      it "should return a message with the added events" do
        get :pull_third_party
        expect(flash[:notice]).to eq(Event.display_message(events))
      end

      it "should redirect to the calendar" do
        get :pull_third_party
        expect(response).to redirect_to(calendar_path)
      end
    end

    context 'no requested ids' do
      before(:each) do
        allow(Event).to receive(:get_requested_ids).and_return([])
      end

      it "should redirect back to third party" do
        get :pull_third_party
        expect(response).to redirect_to(third_party_events_path)
      end

      it "should return no pulled event names" do
        get :pull_third_party
        expect(flash[:notice]).to eq('You must select at least one event. Please retry.')
      end
    end
  end

  describe "#third_party" do
    context "get" do
      it "renders the third_party template" do
        get :third_party
        expect(response).to render_template('third_party')
      end

      it "assigns empty events" do
        get :third_party
        expect(assigns(:events)).to eq([])
      end
    end

    context "post" do
      let(:event) {[Event.new]}

      before(:each) do
        allow(Event).to receive(:get_remote_events).and_return(event)
      end

      it "renders the third_party template" do
        post :third_party
        expect(response).to render_template('third_party')
      end

      it "assigns events for posted id" do
        get :third_party, id: "123"
        expect(assigns(:events)).to eq(event)
      end

      it "assigns events for posted group_urlname" do
        get :third_party, group_urlname: "gruppetto"
        expect(assigns(:events)).to eq(event)
      end
    end
  end


end
