# frozen_string_literal: true

require "web_pipe/version"

RSpec.describe WebPipe do
  it "has a version number" do
    expect(WebPipe::VERSION).not_to be nil
  end
end
