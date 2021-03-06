class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.return_due_date(project)
    project.date.strftime("Campaign ends: %m-%d-%y")
  end

  def self.get_countdown_time(project)
    current_time = (Time.new).strftime('%m-%d-%y')
    due_date = self.return_due_date(project)[15,9]

    year_difference = due_date[6,2].to_i - current_time[6,2].to_i
    day_difference = due_date[3,2].to_i - current_time[3,2].to_i
    month_difference = due_date[0,2].to_i - current_time[0,2].to_i

    if (year_difference <= 0) && (month_difference <= 0) && day_difference <= 0
      return 'The Project is Expired'
    end

    if (year_difference ) == 0 && day_difference >= 0
      months_left = month_difference
      days_left = day_difference
      return "the Project has #{months_left} months and #{days_left} days left"

    elsif (year_difference) == 0 && day_difference < 0
      months_left = (month_difference) - 1
      days_left = (day_difference) + 30
      return "the Project has #{months_left} months and #{days_left} days left"

    elsif (year_difference ) >= 1 && day_difference >= 0
      months_left = (month_difference) + (12 * year_difference)
      days_left = (day_difference)
      return "the Project has #{months_left} months and #{days_left} days left"

    elsif(year_difference) >= 1 && day_difference < 0
      months_left = (month_difference) + (12 * year_difference - 1)
      days_left = (day_difference) + 30
      return "the Project has #{months_left} months and #{days_left} days left"
    end
  end

  def self.destroy_pledges(project_id)
    pledges = self.where(project_id: project_id)
    pledges.each do |pledge|
      pledge.destroy
    end
  end

  def self.count(project_id)
    pledges = Pledge.where(project_id: project_id)
    count = 0
    pledges.each do |pledge|
      puts pledge
      count += pledge.amount
    end
    return count
  end

  def self.find_rewards(project_id)
    self.where(project_id: project_id)
  end

  def self.reached_goal?(project)
    target_goal = project.goal
    total_raised = self.count(project.id)
    if total_raised >= target_goal
      return true
    end
    while self.get_countdown_time(project) != 'The Project is Expired'
      return "there is still time"
    end
    return false
  end

  def self.user_rewards(user, projects)
    user_rewards_hash = {}
    projects.each do |project|
      reward = Reward.find_by(project_id: project.id)
      puts "this is the reward"
      if reward == nil
        user_rewards_hash = user_rewards_hash
      else
        pledges = Pledge.where(user_id: user.id)

        pledges.each do |pledge|
          if reward.project_id == pledge.project_id && pledge.amount >= reward.amount
            user_rewards_hash[pledge.user_id] = reward.description
          end
        end
      end
    end
    return user_rewards_hash
  end



end
