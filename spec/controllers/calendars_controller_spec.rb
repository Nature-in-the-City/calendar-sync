require 'rails_helper'

describe CalendarsController do
  before(:each) do
    allow_any_instance_of(Meetup).to receive(:pull_events).and_return(nil)
  end


  describe 'gets the calendar' do
    it 'renders the calendar' do
      allow(Event).to receive(:get_remote_events).and_return([])
      get :show
      expect(response).to render_template(:show)
    end
  end


  describe 'pulling in #show' do
    context 'multiple events' do

      it 'should get remote meetup events' do
        allow(Event).to receive(:get_remote_events).and_return([])
        expect(Event).to receive(:get_remote_events)
        get :show
      end

      it 'should make remote meetup events local' do
        events = double()
        allow(Event).to receive(:get_remote_events).and_return(events)
        allow(events).to receive(:+).and_return(events)
        expect(Event).to receive(:make_events_local).with(events)
        get :show
      end


    end

=begin
      it 'should display the newly added event names in a message' do
        events = [Event.new(name: 'chester'), Event.new(name: 'copperpot')]
        allow(Event).to receive(:make_events_local).and_return(events)
        get :show
        expect(flash[:notice]).to eq("Successfully pulled events: #{events[0][:name]}, #{events[1][:name]} from Meetup")
      end

    end

    context "with failed result" do
      let(:event_names) {nil}

      it "should display a failure message" do
        allow(Event).to receive(:make_events_local).and_return(event_names)
        get :show
        expect(flash[:notice]).to eq("Could not pull events from Meetup")
      end
    end

    context "with zero events returned (i.e. synch status)" do
      let(:event_names) {[]}

      it "should display a failure message" do
        allow(Event).to receive(:make_events_local).and_return(event_names)
        get :show
        expect(flash[:notice]).to eq("The Calendar and Meetup are synched")
      end

    end


    context "with failed result" do
      let(:event_names) {nil}
      before(:each) do
        allow(Event).to receive(:get_remote_events).and_return([])
      end

      it "should display a failure message" do
        allow(Event).to receive(:make_events_local).and_return(event_names)
        get :show
        expect(flash[:notice]).to eq("Could not pull events from Meetup")
      end
    end

    context "with zero events returned (i.e. synch status)" do
      let(:event_names) {[]}

      it "should display a failure message" do
        allow(Event).to receive(:make_events_local).and_return(event_names)
        get :show
        expect(flash[:notice]).to eq("The Calendar and Meetup are synched")
      end
    end
  end
=end

  end
end

