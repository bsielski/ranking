require 'rails_helper'

RSpec.describe Report, type: :model do

  describe 'validations' do
    before do
      @user1 = User.create!(email:"qweasd@qwe.pl", password:'asdqwe123123')
      @user2 = User.create!(email:"1212qweasd@qwe.pl", password:'wasdqwe123123')
      @profile1 = Profile.create! user_id: @user1.id, name: "User1", description: "Some description", color: '#ffffff'
      @profile2 = Profile.create! user_id: @user2.id, name: "User2", description: "Some description", color: '#111111'
    end

    subject { Report.new(scenario_id: 1, reporter_id: @profile1.id, confirmer_id: @profile2.id,
      reporters_faction_id: 1, confirmers_faction_id: 2,
      result_id: 1, status: "unconfirmed") }

    it 'is valid when every field is OK' do
      expect(subject).to be_valid
    end

    it 'is invalid without scenario_id' do
      subject.scenario_id = nil
      expect(subject).to be_invalid
    end

    it 'is invalid without reporter_id' do
      subject.reporter_id = nil
      expect(subject).to be_invalid
    end

    it 'is invalid without confirmer_id' do
      subject.confirmer_id = nil
      expect(subject).to be_invalid
    end

    it 'is invalid without reporters_faction_id' do
      subject.reporters_faction_id = nil
      expect(subject).to be_invalid
    end

    it 'is invalid without confirmers_faction_id' do
      subject.confirmers_faction_id = nil
      expect(subject).to be_invalid
    end

    it 'is invalid without result' do
      subject.result = nil
      expect(subject).to be_invalid
    end

    it 'is invalid when reporter and confirmer are the same user\'s profiles' do
      user1 = User.create!(email:"q555weasd@qwe.pl", password:'asdqwe123123')
      profile1 = Profile.create! user_id: user1.id, name: "Cheater1", description: "Some description", color: '#ffffff'
      profile2 = Profile.create! user_id: user1.id, name: "Cheater2", description: "Some description", color: '#111111'
      report = Report.new(scenario_id: 1, reporter_id: profile1.id, confirmer_id: profile2.id, reporters_faction_id: 1, confirmers_faction_id: 2, result_id: 1, status: "unconfirmed")
      expect(report).to be_invalid
    end

  end


  describe '#original_report' do

    before(:context) do
      @game = Game.create!(full_name: 'The Battle for Wesnoth',
                  short_name: 'Wesnoth',
                  description: 'The Battle for Wesnoth is a Free, turn-based tactical strategy game with a high fantasy theme, featuring both single-player, and online/hotseat multiplayer combat. More on www.wesnoth.org',
                  simultaneous_turns: false)
      @ladder = Ladder.create!(name: 'Wesnoth Blitz Test Ladder',
                  description: 'This is fake Ladder. All results are fake here',
                  game_id: @game.id)
      @scenario1 = Scenario.create!(full_name: 'The Freelands',
                      short_name: 'The Freelands',
                      description: 'The Freelands is a map with three ways to the enemy castle.',
                      mirror_matchups_allowed: true,
                      ladder_id: @ladder.id,
                      map_size: nil,
                      map_random_generated: false)
      @scenario2 = Scenario.create!(full_name: 'Caves of the Basilisk',
                      short_name: 'Caves of the Basilisk',
                      description: 'Caves of the Basilisk is a map.',
                      mirror_matchups_allowed: true,
                      ladder_id: @ladder.id,
                      map_size: nil,
                      map_random_generated: false)

      @victory = PossibleResult.create!(description: "Victory!", score_factor: 100, game_id: @game.id)
      @defeat = PossibleResult.create!(description: "Defeat!", score_factor: 0, game_id: @game.id)
      @draw = PossibleResult.create!(description: "Draw!", score_factor: 50, game_id: @game.id)

      @user1 = User.create!(email:"qweasd@qwe.pl", password:'asdqwe123123')
      @user2 = User.create!(email:"1212qweasd@qwe.pl", password:'wasdqwe123123')
      @profile1 = Profile.create! user_id: @user1.id, name: "Profile1", description: "Some description", color: '#ffffff'
      @profile2 = Profile.create! user_id: @user2.id, name: "Profile2", description: "Some description", color: '#ffffff'
      @config = DefaultLadderConfig.create!(default_ranking: 1500, max_distance_between_players: 10, min_points_to_gain: 10, disproportion_factor: 10, unexpected_result_bonus: 50, hours_to_confirm: 49, ladder_id: @ladder.id)
    end

    after(:context) do
      @config.destroy if @config
      @profile1.destroy if @profile1
      @profile2.destroy if @profile2
      @user1.destroy if @user1
      @user2.destroy if @user2
      @victory.destroy if @victory
      @defeat.destroy if @defeat
      @draw.destroy if @draw
      @scenario1.destroy if @scenario1
      @scenario2.destroy if @scenario2
      @ladder.destroy if @ladder
      @game.destroy if @game
      # DefaultLadderConfig.destroy_all
      # Profile.destroy_all
      # User.destroy_all
      # PossibleResult.destroy_all
      # Scenario.destroy_all
      # Ladder.destroy_all
      # Game.destroy_all

    end

    it 'returns nil if the scenarios are different' do
      different_scenario_report = Report.create!(scenario_id: @scenario1.id, reporter_id: @profile1.id, confirmer_id: @profile2.id, reporters_faction_id: 1, confirmers_faction_id: 2, result_id: @victory.id, status: "unconfirmed")
      different_scenario_report.created_at = 40.hours.ago
      different_scenario_report.save!
      subject = Report.new(scenario_id: @scenario2.id, reporter_id: @profile2.id, confirmer_id: @profile1.id, reporters_faction_id: 2, confirmers_faction_id: 1, result_id: @defeat.id, status: "unconfirmed")

      expect(subject.original_report).to be_nil
    end

    it 'returns the previous report if all conditions are ok' do
      first_scenario_report = Report.create!(scenario_id: @scenario1.id, reporter_id: @profile1.id, confirmer_id: @profile2.id, reporters_faction_id: 1, confirmers_faction_id: 2, result_id: @victory.id, status: "unconfirmed")

      first_scenario_report.created_at = 48.hours.ago
      first_scenario_report.save!

      subject = Report.new(scenario_id: @scenario1.id, reporter_id: @profile2.id, confirmer_id: @profile1.id, reporters_faction_id: 2, confirmers_faction_id: 1, result_id: @defeat.id, status: "unconfirmed")

      expect(subject.original_report).to eql first_scenario_report
    end

    it 'returns nil if the previous report is too old' do
      first_scenario_report = Report.create!(scenario_id: @scenario1.id, reporter_id: @profile1.id, confirmer_id: @profile2.id, reporters_faction_id: 1, confirmers_faction_id: 2, result_id: @victory.id, status: "unconfirmed")
      first_scenario_report.created_at = 50.hours.ago
      first_scenario_report.save!
      subject = Report.new(scenario_id: @scenario1.id, reporter_id: @profile2.id, confirmer_id: @profile1.id, reporters_faction_id: 2, confirmers_faction_id: 1, result_id: @defeat.id, status: "unconfirmed")

      expect(subject.original_report).to be_nil
    end

    it 'returns nil if the profiles don\'t match' do
      first_scenario_report = Report.create!(scenario_id: @scenario1.id, reporter_id: @profile1.id, confirmer_id: @profile2.id, reporters_faction_id: 1, confirmers_faction_id: 2, result_id: @victory.id, status: "unconfirmed")
      first_scenario_report.created_at = 47.hours.ago
      first_scenario_report.save!
      subject = Report.new(scenario_id: @scenario1.id, reporter_id: @profile1.id, confirmer_id: @profile1.id, reporters_faction_id: 2, confirmers_faction_id: 1, result_id: @defeat.id, status: "unconfirmed")

      expect(subject.original_report).to be_nil
    end

    it 'returns nil if the factions don\'t match' do
      first_scenario_report = Report.create!(scenario_id: @scenario1.id, reporter_id: @profile1.id, confirmer_id: @profile2.id, reporters_faction_id: 1, confirmers_faction_id: 2, result_id: @victory.id, status: "unconfirmed")
      first_scenario_report.created_at = 48.hours.ago
      first_scenario_report.save!
      subject = Report.new(scenario_id: @scenario1.id, reporter_id: @profile2.id, confirmer_id: @profile1.id, reporters_faction_id: 1, confirmers_faction_id: 1, result_id: @defeat.id, status: "unconfirmed")

      expect(subject.original_report).to be_nil
    end

    it 'returns nil if the results don\'t match' do
      first_scenario_report = Report.create!(scenario_id: @scenario1.id, reporter_id: @profile1.id, confirmer_id: @profile2.id, reporters_faction_id: 1, confirmers_faction_id: 2, result_id: @victory.id, status: "unconfirmed")
      first_scenario_report.created_at = 48.hours.ago
      first_scenario_report.save!
      subject = Report.new(scenario_id: @scenario1.id, reporter_id: @profile2.id, confirmer_id: @profile1.id, reporters_faction_id: 2, confirmers_faction_id: 1, result_id: @victory.id, status: "unconfirmed")

      expect(subject.original_report).to be_nil
    end

    it 'returns the older report if there are more than one ok reports' do
      first_scenario_report = Report.create!(scenario_id: @scenario1.id, reporter_id: @profile1.id, confirmer_id: @profile2.id, reporters_faction_id: 1, confirmers_faction_id: 2, result_id: @victory.id, status: "unconfirmed")
      first_scenario_report.created_at = 48.hours.ago
      first_scenario_report.save!

      second_scenario_report = Report.create!(scenario_id: @scenario1.id, reporter_id: @profile1.id, confirmer_id: @profile2.id, reporters_faction_id: 1, confirmers_faction_id: 2, result_id: @victory.id, status: "unconfirmed")
      second_scenario_report.created_at = 46.hours.ago
      second_scenario_report.save!

      subject = Report.new(scenario_id: @scenario1.id, reporter_id: @profile2.id, confirmer_id: @profile1.id, reporters_faction_id: 2, confirmers_faction_id: 1, result_id: @defeat.id, status: "unconfirmed")

      expect(subject.original_report).to eql first_scenario_report
    end

    it 'cheks if confirmed is false' do
      first_scenario_report = Report.create!(scenario_id: @scenario1.id, reporter_id: @profile1.id, confirmer_id: @profile2.id, reporters_faction_id: 1, confirmers_faction_id: 2, result_id: @victory.id, status: "confirmed")
      first_scenario_report.created_at = 48.hours.ago
      first_scenario_report.save!
      subject = Report.new(scenario_id: @scenario1.id, reporter_id: @profile2.id, confirmer_id: @profile1.id, reporters_faction_id: 2, confirmers_faction_id: 1, result_id: @defeat.id, status: "unconfirmed")

      expect(subject.original_report).to be_nil
    end

  end

end
