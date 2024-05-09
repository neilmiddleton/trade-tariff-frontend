module GreenLanes
  class CheckMovingRequirementsForm
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveRecord::AttributeAssignment

    attribute :commodity_code, :string
    attribute :country_of_origin, :string
    attribute :moving_date, :date

    validates :commodity_code, length: { is: 10 }
    validates :country_of_origin, presence: true
    validates :moving_date, presence: true
  end
end
