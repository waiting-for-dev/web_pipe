# frozen_string_literal: true

require 'spec_helper'
require 'web_pipe/extensions/params/params/transf'

RSpec.describe WebPipe::Params::Transf do
  describe '.id' do
    it 'returns same value' do
      expect(described_class[:id].call(1)).to be(1)
    end
  end
end
