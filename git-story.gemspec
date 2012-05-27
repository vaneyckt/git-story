Gem::Specification.new do |s|
  s.name        = 'git-story'
  s.version     = '0.0.1'
  s.date        = '2012-05-27'
  s.summary     = "A Ruby script for git to find how a given commit made it into a particular branch."
  s.description = "A Ruby script for git to find how a given commit made it into a particular branch."
  s.authors     = ["Tom Van Eyck"]
  s.email       = 'tomvaneyck@gmail.com'
  s.files       = ["lib/git-story"]
  s.homepage    = 'https://github.com/vaneyckt/git-story'

  s.add_runtime_dependency 'grit'
  s.add_runtime_dependency 'trollop'
end
