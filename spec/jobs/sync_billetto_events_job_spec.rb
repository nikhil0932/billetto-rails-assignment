require 'rails_helper'

RSpec.describe SyncBillettoEventsJob, type: :job do
  let(:sync_service) { instance_double('BillettoEventSyncService') }
  let(:result) { { synced: 2, failed: 0, total: 2 } }

  before do
    allow(BillettoEventSyncService).to receive(:new).and_return(sync_service)
    allow(sync_service).to receive(:sync_all_events).and_return(result)
  end

  it 'calls sync service' do
    described_class.perform_now
    expect(sync_service).to have_received(:sync_all_events)
  end

  it 'passes parameters to sync service' do
    described_class.perform_now(limit: 50)
    expect(sync_service).to have_received(:sync_all_events).with(limit: 50)
  end

  it 'queues on default queue' do
    expect(described_class.new.queue_name).to eq('default')
  end

  it 'returns sync result' do
    result_value = described_class.perform_now
    expect(result_value).to eq(result)
  end

  it 'raises on sync service error' do
    allow(sync_service).to receive(:sync_all_events)
      .and_raise(Billetto::ClientError.new('API Error'))
    
    expect {
      described_class.perform_now
    }.to raise_error(Billetto::ClientError)
  end
end
