require 'api_entity'

class Chapter
  include ApiEntity

  attr_accessor :id, :code, :description, :headings, :short_code

  has_one :section
  has_many :headings

  def self.find(id)
    new(get("/chapters/#{id}"))
  end

  def to_s
    description
  end

  def long_desc
    "CHAPTER #{short_code} - #{description}"
  end

  def to_param
    short_code
  end
end
