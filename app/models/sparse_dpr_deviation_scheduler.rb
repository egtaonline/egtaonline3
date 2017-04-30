class SparseDprDeviationScheduler < DeviationScheduler
  def profile_space
    return [] if invalid_role_partition?
    reduced_assignments = SubgameCreator.subgame_assignments(roles)
    reduced_dev_assignments = DeviationCreator.deviation_assignments(roles)
    expanded_pure_assignments = DprCreator.expand_assignments(reduced_assignments, roles)
    expanded_dev_assignments = DprCreator.sparse_expand_assignments(reduced_dev_assignments, roles)
    AssignmentFormatter.format_assignments((expanded_pure_assignments + expanded_dev_assignments).uniq)
  end
end
