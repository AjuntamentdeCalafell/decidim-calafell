# frozen_string_literal: true

require "rails_helper"
require "tempfile"

unless defined?(RotateFileAuthorizationHandlerCensus) || Rake::Task.task_defined?("rotate_secret:file_census")
  load Rails.root.join("lib/tasks/rotate_secret/file_authorization_census.rake")
end

RSpec.describe RotateFileAuthorizationHandlerCensus do
  describe ".options_from_env!" do
    around do |example|
      original_env = ENV.to_hash
      example.run
      ENV.replace(original_env)
    end

    it "parses required options" do
      ENV["ORGANIZATION_ID"] = "7"
      ENV["CSV_PATH"] = "/tmp/census.csv"
      ENV["DRY_RUN"] = "true"
      ENV["RESET_AUTHORIZATIONS"] = "true"

      expect(described_class.options_from_env!).to eq(
        organization_id: 7,
        csv_path: "/tmp/census.csv",
        dry_run: true,
        reset_authorizations: true
      )
    end

    it "aborts when ORGANIZATION_ID is not numeric" do
      ENV["ORGANIZATION_ID"] = "abc"
      ENV["CSV_PATH"] = "/tmp/census.csv"

      expect { described_class.options_from_env! }.to raise_error(SystemExit)
    end
  end

  describe ".load_csv_data!" do
    it "loads valid rows and tracks invalid ones" do
      file = Tempfile.new(["census", ".csv"])
      file.write("ID_NUMBER,BIRTH_DATE,DISTRICT\n")
      file.write("00000000Z,07/03/2014,17600\n")
      file.write("BAD_DATE,31/99/2014,17600\n")
      file.flush

      data = described_class.load_csv_data!(file.path)

      expect(data.values.count).to eq(1)
      expect(data.errors.count).to eq(1)
      expect(data.headers[0..1]).to eq(%w(ID_NUMBER BIRTH_DATE))
    ensure
      file.close!
    end

    it "aborts when CSV_PATH is not a CSV file" do
      file = Tempfile.new(["census", ".txt"])
      file.write("test")
      file.flush

      expect { described_class.load_csv_data!(file.path) }.to raise_error(SystemExit)
    ensure
      file.close!
    end
  end
end
