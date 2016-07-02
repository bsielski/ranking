class ReportsToCalculateFinderService

  def initialize(ladder)
    @ladder = ladder
  end

  def tag_reports
    @ladder.reports.first.update(status: :to_calculate) if @ladder.reports.any?
  end

end
