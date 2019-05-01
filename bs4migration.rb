RULES = {
  '.panel-heading' => '.card-header',
  '.panel.panel-default' => '.card',
  '.panel-title' => '.card-title',
  '.panel-body' => '.card-body',
  '.panel-footer' => '.card-footer',
  '.panel-primary' => '.card.bg-primary.text-white',
  '.panel-success' => '.card.bg-success.text-white',
  '.panel-info' => '.card.text-white.bg-info',
  '.panel-warning' => '.card.bg-warning',
  '.panel-danger' => '.card.bg-danger.text-white',
  '.pull-right' => '.float-right',
  '.pull-left' => '.float-left',
  '.hidden-xs' => '.d-none',
  '.hidden-sm' => '.d-sm-none',
  '.hidden-md' => '.d-md-none',
  '.hidden-lg' => '.d-lg-none',
  '.visible-xs' => '.d-block.d-sm-none',
  '.visible-sm' => '.d-none.d-sm-block.d-md-none',
  '.visible-md' => '.d-none.d-md-block.d-lg-none',
  '.visible-lg' => '.d-none.d-lg-block.d-xl-none',
  '.badge' => '.badge.badge-pill',
  '.label' => '.badge',
  '.col-xs-' => 'col',
  '.table-condensed' =>	'.table-sm',
  '.well' => '.card.card-body',
  '.thumbnail' =>	'.card.card-body',
  '.btn-default' =>	'.btn-secondary',
  '.img-responsive' =>	'.img-fluid',
  '.img-circle' => '.rounded-circle',
  '.img-rounded' =>	'.rounded',
}.freeze

paths = [
  'app/views/**/*.slim',
  'app/views/**/*.haml',
  'app/views/**/*.erb',
  'app/assets/**/*.scss',
  'app/assets/**/*.js',
  'app/assets/**/*.sass',
  'app/assets/**/*.coffee',
]
uses_dot_syntax = /slim|haml|css|sass/
Dir[*paths].each do |view_file|
  input = File.read(view_file)
  work = input.dup
  RULES.each do |from, to|
    if view_file[uses_dot_syntax]
      unless view_file[to]
        work.gsub!(from, to)
      end
    else
      work.gsub!(from.sub('.', ''), to.gsub('.', ' ').strip)
    end
  end
  if work != input
    puts "migrated #{view_file}"
    File.write(view_file, work)
  end
end
