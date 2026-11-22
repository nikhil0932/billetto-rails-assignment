class SyncBillettoEventsJob < ApplicationJob
  queue_as :default

  def perform(params = {})
    logger.info("Starting Billetto events sync job with params: #{params}")
    
    sync_service = BillettoEventSyncService.new
    result = sync_service.sync_all_events(**params)
    
    logger.info("Job completed. Synced #{result[:synced]} events (#{result[:failed]} failed)")
    
    result
  rescue StandardError => e
    logger.error("SyncBillettoEventsJob failed: #{e.message}\n#{e.backtrace.first(10).join("\n")}")
    raise
  end
end
