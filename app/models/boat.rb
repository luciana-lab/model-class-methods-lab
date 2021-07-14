class Boat < ActiveRecord::Base
  belongs_to  :captain
  has_many    :boat_classifications
  has_many    :classifications, through: :boat_classifications

  # limit: specify the number of records (boats) to be retrieved
  def self.first_five
    all.limit(5)
  end

  # where: accepts conditions, filtering the current relation according to the condition in the arguments
  # https://api.rubyonrails.org/v6.1.4/classes/ActiveRecord/QueryMethods.html#method-i-where
  # In this case, will return boats with less than 20 length
  def self.dinghy
    where("length < 20")
  end

  # In this case, will return boats with more or igual 20 length
  def self.ship
    where("length >= 20")
  end

  # order: specify an order attribute
  # https://api.rubyonrails.org/v6.1.4/classes/ActiveRecord/QueryMethods.html#method-i-order
  # In this case, the result is the first 3 boats order alphabetically descendant (Z-A)
  def self.last_three_alphabetically
    all.order(name: :desc).limit(3)
  end

  # It'll return the boats that don't have a captain assigned to it
  def self.without_a_captain
    where(captain_id: nil)
  end

  # includes: specify relationships to be included in the result set
  # conditions: add string conditions to your included models, you need to explicity reference them
  # In this case, the condition is to include "classifications" and the classification name value needs to be 'Sailboat'
  def self.sailboats
    includes(:classifications).where(classifications: { name: 'Sailboat' })
  end

  def self.with_three_classifications
    # This is really complex! It's not common to write code like this
    # regularly. Just know that we can get this out of the database in
    # milliseconds whereas it would take whole seconds for Ruby to do the same.
    
    joins(:classifications).group("boats.id").having("COUNT(*) = 3").select("boats.*")
  end

  # not in: not include - https://guides.rubyonrails.org/active_record_querying.html#not-conditions
  # pluck: shortcut to select one or more attributes - https://apidock.com/rails/ActiveRecord/Calculations/pluck
  # In this case, will return all boats that don't have the sailboats id on it
  def self.non_sailboats
    where("id NOT IN (?)", self.sailboats.pluck(:id))
  end

  # It'll return the longest boat (DESC = higher to smaller)
  def self.longest
    order('length DESC').first
  end
end
