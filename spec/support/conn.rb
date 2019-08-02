require 'rack'
require 'web_pipe/conn_support/builder'

# Minimal rack's env.
#
# @return [Hash]
def default_env
  {
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
end

# Helper to build a `Conn` from rack's env.
#
# @param env [Hash]
# @return Conn [WebPipe::Conn]
def build_conn(env)
  WebPipe::ConnSupport::Builder.(env)
end