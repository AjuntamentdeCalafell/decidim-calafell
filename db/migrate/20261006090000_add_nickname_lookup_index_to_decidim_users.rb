# frozen_string_literal: true

# The existing unique index on (nickname, decidim_organization_id) is partial
# (WHERE deleted_at IS NULL AND managed = false), so Decidim's own nickname
# lookups (uniqueness validation, /profiles/:nickname, GraphQL) fall back to a
# sequential scan. This plain index serves those reads.
class AddNicknameLookupIndexToDecidimUsers < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :decidim_users,
              [:nickname, :decidim_organization_id],
              name: "index_decidim_users_on_nickname_org_lookup",
              algorithm: :concurrently,
              if_not_exists: true
  end
end
