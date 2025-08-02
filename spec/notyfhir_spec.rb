# frozen_string_literal: true

RSpec.describe Notyfhir do
  it "has a version number" do
    expect(Notyfhir::VERSION).not_to be nil
  end

  describe ".configure" do
    it "yields configuration block" do
      expect { |b| Notyfhir.configure(&b) }.to yield_with_args(Notyfhir::Configuration)
    end

    it "sets configuration values" do
      Notyfhir.configure do |config|
        config.vapid_public_key = "test_public_key"
        config.vapid_private_key = "test_private_key"
        config.user_class_name = "CustomUser"
      end

      expect(Notyfhir.configuration.vapid_public_key).to eq("test_public_key")
      expect(Notyfhir.configuration.vapid_private_key).to eq("test_private_key")
      expect(Notyfhir.configuration.user_class_name).to eq("CustomUser")
    end
  end

  describe ".reset_configuration!" do
    it "resets configuration to defaults" do
      Notyfhir.configure do |config|
        config.user_class_name = "CustomUser"
      end

      Notyfhir.reset_configuration!

      expect(Notyfhir.configuration.user_class_name).to eq("User")
    end
  end
end
