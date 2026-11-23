require 'rails_helper'

RSpec.describe BillettoEventSyncService, type: :model do
  let(:api_client) { instance_double('Billetto::Client') }
  let(:service) { described_class.new(api_client) }

  describe '#sync_all_events' do
    it 'syncs events from API' do
      api_response = [{
        'id' => '123', 'title' => 'Event', 'description' => 'Desc',
        'location' => { 'location_name' => 'NY' }, 'startdate' => 1.day.from_now.iso8601,
        'enddate' => 2.days.from_now.iso8601
      }]
      allow(api_client).to receive(:fetch_events).and_return(api_response)
      
      result = service.sync_all_events
      expect(result[:synced]).to eq(1)
    end

    it 'creates new events' do
      api_response = [{
        'id' => 'new-123', 'title' => 'New Event',
        'location' => { 'city' => 'Boston' }, 'startdate' => 1.day.from_now.iso8601,
        'enddate' => 2.days.from_now.iso8601
      }]
      allow(api_client).to receive(:fetch_events).and_return(api_response)
      
      expect { service.sync_all_events }.to change(Event, :count).by(1)
    end

    it 'updates existing events' do
      event = create(:event, billetto_id: '123', title: 'Old')
      api_response = [{
        'id' => '123', 'title' => 'Updated', 'description' => 'New desc',
        'location' => { 'location_name' => 'NY' }, 'startdate' => 1.day.from_now.iso8601,
        'enddate' => 2.days.from_now.iso8601
      }]
      allow(api_client).to receive(:fetch_events).and_return(api_response)
      
      service.sync_all_events
      expect(event.reload.title).to eq('Updated')
    end

    it 'returns empty stats when no events' do
      allow(api_client).to receive(:fetch_events).and_return([])
      result = service.sync_all_events
      expect(result[:synced]).to eq(0)
    end
  end

  describe '#sync_event' do
    it 'creates new event' do
      event_data = {
        'id' => '123', 'title' => 'Event', 'location' => { 'location_name' => 'NY' },
        'startdate' => 1.day.from_now.iso8601, 'enddate' => 2.days.from_now.iso8601
      }
      result = service.sync_event(event_data)
      expect(result.billetto_id).to eq('123')
    end

    it 'updates existing event' do
      event = create(:event, billetto_id: '123', title: 'Old')
      event_data = {
        'id' => '123', 'title' => 'Updated', 'location' => { 'city' => 'Boston' },
        'startdate' => 1.day.from_now.iso8601, 'enddate' => 2.days.from_now.iso8601
      }
      result = service.sync_event(event_data)
      expect(result.title).to eq('Updated')
    end

    it 'returns nil when event invalid' do
      event_data = { 'id' => '123', 'title' => nil, 'location' => 'NY',
                     'startdate' => 1.day.from_now.iso8601, 'enddate' => 2.days.from_now.iso8601 }
      expect(service.sync_event(event_data)).to be_nil
    end
  end
end
