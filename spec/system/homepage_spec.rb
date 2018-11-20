# frozen_string_literal: true

require 'rails_helper'

describe 'Visit the home page', type: :system, perform_enqueued: true do
  let(:organization) { create :organization }

  before do
    create :content_block, organization: organization, scope: :homepage, manifest_name: :hero
    create :content_block, organization: organization, scope: :homepage, manifest_name: :sub_hero
    switch_to_host(organization.host)
  end

  it 'renders the home page' do
    visit decidim.root_path
    expect(page).to have_content('Welcome')
  end
end
