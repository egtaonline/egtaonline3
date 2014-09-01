class AnalysisPresenter
  def initialize(analysis)
    @analysis = analysis
  end

  def get_output(options = {})
    case options[:output]
    when 'subgame'
      File.open("#{Rails.root}/public/analysis/#{@analysis.game_id}-subgame-#{@analysis.id}.json", 'w', 0770) do |f|
        f.write(@analysis.subgame.to_json)
        f.chmod(0770)
      end
      "#{Rails.root}/public/analysis/#{@analysis.game_id}-subgame-#{@analysis.id}.json"
    when 'nd'
      File.open("#{Rails.root}/public/analysis/#{@analysis.game_id}-nd-#{@analysis.id}.json", 'w', 0770) do |f|
        f.write(@analysis.dominance_script.output.to_json)
        f.chmod(0770)
      end
      "#{Rails.root}/public/analysis/#{@analysis.game_id}-nd-#{@analysis.id}.json"
    when 'reduced'
      File.open("#{Rails.root}/public/analysis/#{@analysis.game_id}-reduction-#{@analysis.id}.json", 'w', 0770) do |f|
        f.write(@analysis.reduction_script.output.to_json)
        f.chmod(0770)
      end
      "#{Rails.root}/public/analysis/#{@analysis.game_id}-reduction-#{@analysis.id}.json"
    else
      File.open("#{Rails.root}/public/analysis/#{@analysis.game_id}-analysis-#{@analysis.id}.txt", 'w', 0770) do |f|
        f.write(@analysis.output)
        f.chmod(0770)
      end
      "#{Rails.root}/public/analysis/#{@analysis.game_id}-analysis-#{@analysis.id}.txt"
    end
  end
end