Experiment.prepare!

defProperty('confine_experiment_file', '', 'The experiment to prepare...')

OConfig.load(property.confine_experiment_file.value, true, '.rb', 
             Confine::OEDLPreprocessor.instance.get_binding)



puts "I PREPARED... #{property.confine_experiment_file}"

Confine::OEDLPreprocessor.instance.printOverview

Experiment.done
