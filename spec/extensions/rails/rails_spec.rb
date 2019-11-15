# frozen_string_literal: true

require 'spec_helper'
require 'support/conn'
require 'web_pipe/conn'

RSpec.describe WebPipe::Conn do
  before do
    WebPipe.load_extensions(:rails)
  end

  before(:all) do
    module ActionController
      module Base
        def self.renderer
          Renderer.new
        end

        def self.helpers
          {
            helper1: 'foo'
          }
        end
      end

      class Renderer
        def render(*args)
          action = args[0]
          case action
          when 'show'
            'Show'
          else
            'Not found'
          end
        end
      end
    end
  end

  after(:all) { Object.send(:remove_const, :ActionController) }

  describe '#render' do
    it 'sets rendered as response body' do
      conn = build_conn(default_env)

      new_conn = conn.render('show')

      expect(new_conn.response_body).to eq(['Show'])
    end

    it 'uses configured controller' do
      module MyController
        def self.renderer
          Renderer.new
        end

        class Renderer
          def render(*args)
            'Rendered from MyController'
          end
        end
      end
      conn = build_conn(default_env)

      new_conn = conn
        .add_config(:rails_controller, MyController)
        .render(:whatever)

      expect(new_conn.response_body).to eq(['Rendered from MyController'])

      Object.send(:remove_const, :MyController)
    end
  end

  describe '#helpers' do
    it 'returns controller helpers' do
      conn = build_conn(default_env)

      expect(conn.helpers).to eq(helper1: 'foo')
    end

    it 'uses configured controller' do
      module MyController
        def self.helpers
          { helper1: 'bar' }
        end
      end
      conn = build_conn(default_env)

      new_conn = conn.add_config(:rails_controller, MyController)

      expect(new_conn.helpers).to eq(helper1: 'bar')

      Object.send(:remove_const, :MyController)
    end
  end
end
