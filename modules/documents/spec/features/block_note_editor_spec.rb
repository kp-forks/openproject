# frozen_string_literal: true

#-- copyright
# OpenProject is an open source project management software.
# Copyright (C) the OpenProject GmbH
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See COPYRIGHT and LICENSE files for more details.
#++

require "rails_helper"

RSpec.describe "BlockNote editor rendering", :js, with_flag: { block_note_editor: true } do
  let(:admin) { create(:admin) }
  let(:type) { create(:document_type, :experimental) }
  let(:document) { create(:document, type:) }
  let(:editor) { FormFields::Primerized::BlockNoteEditorInput.new }

  before do
    login_as(admin)
  end

  it "renders the BlockNote editor when editting a document" do
    visit edit_document_path(document)

    expect(page).to have_field("Type", required: true)
    expect(page).to have_field("Title", required: true)

    expect(page).to have_test_selector("blocknote-document-description")
    expect(page).to have_css(".block-note-editor-container")

    description_field = page.find_test_selector("blocknote-document-description")
    description_field.click
    description_field.send_keys("Additional text")

    click_on("Save")

    visit edit_document_path(document)

    expect(page).to have_test_selector("blocknote-document-description", text: "Additional text")
  end

  it "renders the BlockNote editor in the users locale" do
    admin.update!(language: "de")
    visit edit_document_path(document)

    expect(page).to have_test_selector("blocknote-document-description")
    expect(page).to have_no_content("Überschrift")

    editor.open_command_dialog
    expect(page).to have_content("Überschrift")
  end

  it "renders the BlockNote editor in english if the users locale is not available for BlockNote" do
    admin.update!(language: "af")
    visit edit_document_path(document)

    expect(page).to have_test_selector("blocknote-document-description")
    expect(page).to have_no_content("Heading")

    editor.open_command_dialog
    expect(page).to have_content("Heading")
  end

  it "renders the BlockNote editor with custom menu entries for work package linking" do
    visit edit_document_path(document)

    expect(page).to have_test_selector("blocknote-document-description")
    editor.send_keys("/openproject")
    expect(page).to have_content("Search and link an existing Work Package")
  end
end
