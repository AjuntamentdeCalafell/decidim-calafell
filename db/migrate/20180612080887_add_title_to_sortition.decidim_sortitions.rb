# frozen_string_literal: true

# This migration comes from decidim_sortitions (originally 20180103082645)
# This file has been modified by `decidim upgrade:migrations` task on 2026-02-13 12:20:24 UTC
class AddTitleToSortition < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_module_sortitions_sortitions, :title, :jsonb
  end
end
