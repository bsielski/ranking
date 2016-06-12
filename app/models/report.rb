class Report < ActiveRecord::Base
  belongs_to :scenario
  belongs_to :reporter, foreign_key: 'reporter_id', class_name: 'Profile'
  belongs_to :confirmer, foreign_key: 'confirmer_id', class_name: 'Profile'
  belongs_to :reporters_faction, foreign_key: 'reporters_faction_id', class_name: 'Faction'
  belongs_to :confirmers_faction, foreign_key: 'confirmers_faction_id', class_name: 'Faction'
  has_many :rankings
  has_many :report_comments
  belongs_to :result, foreign_key: 'result_id', class_name: 'PossibleResult'

  attr_accessor :confirmers_name, :result_description

  validates :scenario_id, presence: true
  validates :reporter_id, presence: {message: "Your name can't be blank"}
  validates :confirmer_id, presence: {message: "Name of your opponent can't be blank"}
  validates :reporters_faction_id, presence: {message: "Your faction can't be blank"}
  validates :confirmers_faction_id, presence: {message: "Faction of your opponent can't be blank"}
  validates :result, presence: true

  validate :profiles_are_from_different_users


  def profiles_are_from_different_users
    if reporter_id and confirmer_id
      if self.reporter.user_id == self.confirmer.user_id
        # self.errors.add(:confirmer, "profile belongs to you. Are you trying to cheat?")
        self.errors[:base] << "Your opponent's profile belongs to YOU!"
      end
    end
  end

  def original_report
    number_of_hours = DefaultLadderConfig.first.hours_to_confirm
    Report.where(confirmed: false).where(scenario_id: scenario_id).where("created_at > ?", number_of_hours.hours.ago).where({reporter_id: confirmer_id, confirmer_id: reporter_id}).where({reporters_faction_id: confirmers_faction_id, confirmers_faction_id: reporters_faction_id}).where(result: add_inv(result)).first
  end

  private

  def add_inv(number)
    if number > 0
      return number - (2 * number)
    else
      return number.abs
    end
  end

end
