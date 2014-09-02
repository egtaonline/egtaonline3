require File.expand_path('../config/environment', __FILE__)

module Clockwork
  every(1.day, 'DailyCleanup', at: '01:00') { DailyCleanup.perform_async }
  every(3.minutes, 'SimulationQueuer') { SimulationQueuer.perform_async }
  every(5.minutes, 'SimulationChecker') { SimulationChecker.perform_async }
  every(5.minutes, 'AnalysisQueuer') { AnalysisQueuer.perform_async }
  every(5.minutes, 'AnalysisChecker') { AnalysisChecker.perform_async }
end
