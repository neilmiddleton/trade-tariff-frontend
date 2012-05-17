require 'spec_helper'

describe CommoditiesController, "GET to #index" do
  let!(:section) { create :section }
  let!(:chapter) { create :chapter, section: section }
  let!(:heading) { create :heading, chapter: chapter }

  before(:each) do
    get :index, section_id: section.id,
                chapter_id: chapter.id,
                heading_id: heading.id
  end

  it { should respond_with(:success) }
  it { should assign_to(:section) }
  it { should assign_to(:chapter) }
  it { should assign_to(:heading) }
  it { should assign_to(:commodities) }
end

describe CommoditiesController, "GET to #show" do
  let!(:section)   { create :section }
  let!(:chapter)   { create :chapter, section: section }
  let!(:heading)   { create :heading, chapter: chapter }
  let!(:commodity) { create :commodity, chapter: chapter, heading: heading }

  before(:each) do
    get :show, section_id: section.id,
               chapter_id: chapter.id,
               heading_id: heading.id,
               id: commodity.id
  end

  it { should respond_with(:success) }
  it { should assign_to(:section) }
  it { should assign_to(:chapter) }
  it { should assign_to(:heading) }
  it { should assign_to(:commodity) }
end
