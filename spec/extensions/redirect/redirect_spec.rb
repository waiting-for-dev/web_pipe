require 'spec_helper'
require 'support/conn'
require 'web_pipe/conn_support/builder'

RSpec.describe WebPipe::Conn do
  before { WebPipe.load_extensions(:redirect) }

  describe '#redirect' do
    let(:conn) { WebPipe::ConnSupport::Builder.(default_env) }
    let(:new_conn) { conn.redirect('/here') }

    it 'uses 302 as default status code' do
      expect(new_conn.status).to be(302)
    end

    it 'sets given path as Location header' do
      expect(new_conn.response_headers['Location']).to eq('/here')
    end
  end
end