require 'spec_helper'

def mock_it_up(file, uri)
  auth_header = {'Authorization': 'bearer xyz'}
  mock_result = File.open("spec/fixtures/#{file}.json").read

  response = {}
  allow(response).to receive(:body).and_return(mock_result)

  allow(RestClient).to receive(:get).with(uri, auth_header).and_return(response)
end

def mock_main_logs_command
  mock_it_up('total_requests', "http://lululemon.loggly.com/apiv2/search?q=requests_query&from=-10m&until=now")
  mock_it_up('rsid', "http://lululemon.loggly.com/apiv2/events?rsid=86162304")
  mock_it_up('mock_result_json', "https://lululemon.loggly.com/apiv2/events/iterate?q=main_query&from=-10m&until=&size=1000")
  mock_it_up('mock_next_result', 'https://lululemon.loggly.com/apiv2/events/iterate?next=9cb4b38a-37d7-43d3-ad79-063cf2d1c43c')
end

def mock_rollup_command
  mock_main_logs_command
  mock_it_up('mock_result_json', "https://lululemon.loggly.com/apiv2/events/iterate?q=%22translation--prod%22+%22fault%3Dstuffystuff%22&from=-10m&until=&size=1000")
end

describe Lita::Handlers::OnewheelLoggly, lita_handler: true do

  before(:each) do
    registry.configure do |config|
      config.handlers.onewheel_loggly.api_key = 'xyz'
      config.handlers.onewheel_loggly.base_uri = 'https://lululemon.loggly.com/apiv2/events'
      config.handlers.onewheel_loggly.query = 'main_query'
      config.handlers.onewheel_loggly.requests_query = 'requests_query'
    end
  end

  it { is_expected.to route_command('logs -10m') }
  it { is_expected.to route_command('logs') }

  it 'does neat loggly things' do
    mock_main_logs_command

    send_command 'logs 10m'
    expect(replies.last).to include('Counted 20 (0.038%): call.timeout')
  end

  it 'gets the oneoff report' do
    mock_it_up('oneoff', 'https://lululemon.loggly.com/apiv2/events/iterate?q=%22translation--prod-%22+%22status%3D404%22+-%22return+to+FE%22&from=2017-11-02T10:00:00Z&until=2017-11-03T16:00:00Z&size=1000')

    send_command 'oneoff'
    expect(replies.last).to include('oneoff_report.csv created.')
  end

  it 'does a total event count' do
    mock_main_logs_command

    send_command 'logs'
    expect(replies[1]).to include('53137 requests')
  end

  it 'checks the events percentage' do
    mock_main_logs_command

    send_command 'logs 10m'
    expect(replies.last).to include('58 events (0.109%)')
  end

  it 'rolls up logs by req_url' do
    mock_rollup_command

    send_command 'rollup fault=stuffystuff 10m'    # fault=endeca_yo 10m'
    expect(replies.last).to include('Counted 4: https://ecom-mock-atg.lllapi.vision/p/women-shorts/Run-Speed-Short-32138-MD/_/prod3860019')
  end

  it 'timeboxes a command' do
    mock_main_logs_command

    send_command 'logs 10m 0430'
    expect(replies.last).to include('58 events (0.109%)')
  end
end
