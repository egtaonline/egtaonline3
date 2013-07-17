jQuery ->
  $("#selector_simulator_id").change ->
    Simulator = $('select#selector_simulator_id :selected').val()
    path = '/schedulers/update_configuration'
    jQuery.post path, {simulator_id: Simulator}