class Event < ActiveRecord::Base
  has_many :event_groupships
  has_many :groups, :through => :event_groupships
  has_many :attendees
  validates_presence_of :name
  belongs_to :category
  has_one :location
  accepts_nested_attributes_for :location, :allow_destroy => true, :reject_if => :all_blank
end
