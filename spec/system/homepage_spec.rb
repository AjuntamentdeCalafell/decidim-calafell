# frozen_string_literal: true

require "rails_helper"

describe "Visit the home page", :perform_enqueued, type: :system do
  let(:organization) { create(:organization) }

  before do
    create(:content_block, organization:, scope_name: :homepage, manifest_name: :hero)
    create(:content_block, organization:, scope_name: :homepage, manifest_name: :sub_hero)
    switch_to_host(organization.host)
  end

  it "renders the home page" do
    visit decidim.root_path
    expect(page).to have_content(/Welcome to .* participatory platform/i)
  end
end
