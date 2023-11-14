# frozen_string_literal: true

RSpec.describe WebPipe do
  it "has a version number" do
    expect(WebPipe::VERSION).not_to be nil
  end

  it "configures loader" do
    expect do
      WebPipe.loader.eager_load(force: true)
    end.not_to raise_error
  end
end
