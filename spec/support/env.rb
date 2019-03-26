require 'rack'

DEFAULT_ENV = {
  Rack::RACK_VERSION      => Rack::VERSION,
  Rack::RACK_INPUT        => StringIO.new,
  Rack::RACK_ERRORS       => StringIO.new,
  Rack::RACK_MULTITHREAD  => true,
  Rack::RACK_MULTIPROCESS => true,
  Rack::RACK_RUNONCE      => false,
  Rack::RACK_URL_SCHEME   => 'http',

  # PEP333
  Rack::REQUEST_METHOD    => Rack::GET,
  Rack::QUERY_STRING      => '',
  Rack::SERVER_NAME       => 'www.example.org',
  Rack::SERVER_PORT       => '80'
}