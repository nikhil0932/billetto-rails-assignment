namespace :billetto do
  desc "Sync events from Billetto API"
  task :sync_events, [:limit] => :environment do |t, args|
    limit = (args[:limit] || 50).to_i
    
    puts "🔄 Starting Billetto event sync (limit: #{limit})..."
    
    begin
      service = BillettoEventSyncService.new
      result = service.sync_all_events(limit: limit)
      
      puts "\n✅ Sync completed!"
      puts "  Synced: #{result[:synced]}"
      puts "  Failed: #{result[:failed]}"
      puts "  Total:  #{result[:total]}"
    rescue Billetto::ClientError => e
      puts "\n❌ Sync failed: #{e.message}"
      exit 1
    rescue StandardError => e
      puts "\n❌ Unexpected error: #{e.message}"
      puts e.backtrace.join("\n")
      exit 1
    end
  end

  desc "Fetch and display sample events from Billetto API"
  task :fetch_sample => :environment do
    puts "🔍 Fetching sample events from Billetto API..."
    
    begin
      client = Billetto::Client.new
      response_data = client.fetch_events(limit: 5)
      
      events_list = response_data.is_a?(Array) ? response_data : response_data['data'] || []
      
      if events_list.empty?
        puts "⚠️  No events found in response"
      else
        puts "\n📋 Found #{events_list.count} events:\n\n"
        
        events_list.each_with_index do |event, idx|
          puts "Event #{idx + 1}:"
          puts "  ID:        #{event['id']}"
          puts "  Title:     #{event['title']}"
          puts "  Starts:    #{event['startdate']}"
          puts "  Ends:      #{event['enddate']}"
          puts "  Price:     #{event.dig('minimum_price', 'amount_in_cents')} #{event.dig('minimum_price', 'currency')}"
          puts "  Organizer: #{event.dig('organiser', 'name')}"
          puts "  Location:  #{event.dig('location', 'location_name')}, #{event.dig('location', 'city')}"
          puts ""
        end
      end
    rescue Billetto::ClientError => e
      puts "❌ Error: #{e.message}"
      exit 1
    rescue StandardError => e
      puts "❌ Unexpected error: #{e.message}"
      puts e.backtrace.join("\n")
      exit 1
    end
  end

  desc "Show current Billetto API configuration"
  task :config => :environment do
    config = Billetto.config
    
    puts "📋 Billetto API Configuration:"
    puts "  API Base URL: #{Billetto::Client::API_BASE_URL}"
    puts "  API Key:      #{config.api_key.present? ? '✅ Configured' : '❌ Missing'}"
    puts "  API Secret:   #{config.api_secret.present? ? '✅ Configured' : '❌ Missing'}"
    puts "  Timeout:      #{config.timeout}s"
    puts "  Max Retries:  #{config.max_retries}"
    puts "  Retry Delay:  #{config.retry_delay}s"
    
    if config.api_key.present? && config.api_secret.present?
      puts "\n✅ Configuration is ready to use!"
    else
      puts "\n⚠️  Configuration is incomplete. Add credentials to config/credentials.yml.enc"
    end
  end

  desc "Clear all synced events from database"
  task :clear_events => :environment do
    count = Event.count
    puts "🗑️  Deleting #{count} events from database..."
    
    Event.destroy_all
    
    puts "✅ Done! All events have been cleared."
  end
end

