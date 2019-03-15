require 'rack'

DEFAULT_ENV = {
  Rack::RACK_VERSION      => Rack::VERSION,
  Rack::RACK_INPUT        => StringIO.new,
  Rack::RACK_ERRORS       => StringIO.new,
  Rack::RACK_MULTITHREAD  => true,
  Rack::RACK_MULTIPROCESS => true,
  Rack::RACK_RUNONCE      => false,
  'REQUEST_METHOD'        => 'GET',
  'SERVER_NAME'           => 'www.example.org',
  'rack.url_scheme'       => 'http'
}