require 'billetto/errors'

class BillettoEventSyncService
  def initialize(client = nil)
    @client = client || Billetto::Client.new
    @logger = Rails.logger
  end

  def sync_all_events(limit: 50)
    @logger.info("Starting Billetto events sync with limit: #{limit}")
    
    begin
      response_data = @client.fetch_events(limit: limit)
      events_list = extract_events_data(response_data)
      
      @logger.info("Fetched #{events_list.length} events from Billetto API")
      
      synced_count = 0
      failed_count = 0

      events_list.each do |event_data|
        begin
          sync_event(event_data)
          synced_count += 1
        rescue StandardError => e
          @logger.error("Failed to sync event: #{e.message}")
          failed_count += 1
        end
      end

      result = {
        synced: synced_count,
        failed: failed_count,
        total: events_list.count
      }

      @logger.info("Successfully synced #{synced_count} events (#{failed_count} failed)")
      result
    rescue Billetto::ClientError => e
      @logger.error("Failed to sync events: #{e.message}")
      raise
    end
  end

  def sync_event(event_data)
    billetto_id = event_data['id']
    
    begin
      event = Event.find_or_initialize_by(billetto_id: billetto_id)
      
      event.assign_attributes(
        title: event_data['title'],
        description: event_data['description'],
        location: format_location(event_data),
        start_date: parse_datetime(event_data['startdate']),
        end_date: parse_datetime(event_data['enddate']),
        price: extract_price(event_data),
        currency: extract_currency(event_data),
        organizer: event_data.dig('organiser', 'name') || 'Unknown Organizer',
        image_url: event_data['image_link'],
        fetched_at: Time.current
      )
      
      if event.save
        @logger.debug("Synced event: #{event.title} (#{billetto_id})")
        event
      else
        @logger.warn("Failed to save event #{billetto_id}: #{event.errors.full_messages.join(', ')}")
        nil
      end
    rescue StandardError => e
      @logger.error("Error syncing event #{billetto_id}: #{e.message}")
      raise
    end
  end

  private

  def extract_events_data(response)
    return [] unless response.is_a?(Hash) || response.is_a?(Array)
    
    if response.is_a?(Array)
      response
    elsif response['data'].is_a?(Array)
      response['data']
    elsif response['events'].is_a?(Array)
      response['events']
    else
      [response]
    end
  end

  def format_location(event_data)
    location = event_data['location'] || {}
    location_parts = []
    
    location_parts << location['location_name'] if location['location_name'].present?
    location_parts << location['address_line'] if location['address_line'].present?
    location_parts << location['city'] if location['city'].present?
    location_parts << location['postal_code'] if location['postal_code'].present?
    location_parts << location['country'] if location['country'].present?
    
    location_parts.compact.join(', ')
  end

  def parse_datetime(datetime_str)
    return nil if datetime_str.blank?
    
    Time.iso8601(datetime_str)
  rescue ArgumentError
    # Try alternative format
    begin
      Time.parse(datetime_str)
    rescue StandardError
      nil
    end
  end

  def extract_price(event_data)
    minimum_price = event_data.dig('minimum_price', 'amount_in_cents')
    if minimum_price.present?
      (minimum_price / 100.0).round(2)
    else
      nil
    end
  end

  def extract_currency(event_data)
    event_data.dig('minimum_price', 'currency')
  end
end


