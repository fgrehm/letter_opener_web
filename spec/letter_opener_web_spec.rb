# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LetterOpenerWeb do
  subject { described_class }
  after(:each) { described_class.reset! }

  describe '.config' do
    it 'sets defaults' do
      expected = Rails.root.join('tmp', 'letter_opener')
      expect(subject.config.letters_location).to eq(expected)
      expect(subject.config.authentication_enabled).to eq(false)
    end
  end

  describe '.configure' do
    it 'yields config to the block' do
      subject.configure do |config|
        expect(config).to eq(subject.config)
      end
    end

    it 'retains settings set within the block' do
      subject.configure do |config|
        config.letters_location = 'tmp/test_path'
      end

      expect(subject.config.letters_location).to eq('tmp/test_path')
    end
  end

  describe '.reset!' do
    it 'resets configuration' do
      subject.configure do |config|
        config.letters_location = 'tmp/test_path'
      end

      subject.reset!

      expected = Rails.root.join('tmp', 'letter_opener')
      expect(subject.config.letters_location).to eq(expected)
    end
  end

  describe 'basic auth config' do
    it 'basic_auth_enabled? is false when authentication_enabled is false' do
      subject.configure do |config|
        config.authentication_enabled = false
        config.username = 'admin'
        config.password = 'secret'
      end
      expect(subject.config.basic_auth_enabled?).to eq(false)
    end

    it 'basic_auth_enabled? is false when username or password are blank' do
      subject.configure do |config|
        config.authentication_enabled = true
        config.username = ''
        config.password = 'secret'
      end
      expect(subject.config.basic_auth_enabled?).to eq(false)

      subject.configure do |config|
        config.authentication_enabled = true
        config.username = 'admin'
        config.password = ''
      end
      expect(subject.config.basic_auth_enabled?).to eq(false)
    end

    it 'basic_auth_enabled? is true when authentication_enabled and both username and password are set' do
      subject.configure do |config|
        config.authentication_enabled = true
        config.username = 'admin'
        config.password = 'secret'
      end
      expect(subject.config.basic_auth_enabled?).to eq(true)
    end

    it 'logs a warning when authentication_enabled is true but credentials are missing' do
      expect(Rails.logger).to receive(:warn).with(/authentication_enabled is true but username or password is blank/)
      subject.configure do |config|
        config.authentication_enabled = true
        config.username = 'admin'
        config.password = ''
      end
    end
  end
end
