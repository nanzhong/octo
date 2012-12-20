Gem::Specification.new do |s|
  s.name         = 'octo'
  s.summary      = 'Run commands in parallel on multiple hosts'
  s.description  = 'A lightweight script that allows you to run commands in parallel on multiple hosts'
  s.version      = '0.0.1'
  s.author       = 'Nan Zhong'
  s.email        = 'nan@nine27.com'
  s.homepage     = 'https://github.com/nanzhong/octo'
  s.files        = `git ls-files`.split($\)

  s.executables << 'octo'

  s.add_dependency 'net-ssh-multi'
  s.add_dependency 'gli'
  s.add_dependency 'term-ansicolor'
end
