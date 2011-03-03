Sass::Engine::DEFAULT_OPTIONS[:load_paths].push *Compass.configuration.sass_load_paths
Sass::Plugin.options[:never_update] = true #letting sprockets do it
